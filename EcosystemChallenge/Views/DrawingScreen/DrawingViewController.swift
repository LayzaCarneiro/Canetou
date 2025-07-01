//  ViewController.swift
//  DrawingExample
//
//  Created by Leticia Bezerra on 04/06/25.
//

import Combine
import UIKit
import PencilKit
import GroupActivities
import Contacts

final class DrawingViewController: UIViewController {
    
    // SharePlay
    var subscriptions = Set<AnyCancellable>()
    var tasks = Set<Task<Void, Never>>()
    var groupSession: GroupSession<DrawTogether>?
    var messenger: GroupSessionMessenger?
    var groupStateObserver = GroupStateObserver()
    
    // Tempo da sessão
    var connectSharePlayTimer: Timer?
    var countdownTimer: Timer?
    var secondsLeft = 10 {
        didSet {
            updateTime()
        }
    }
    var sessionCount = 1
    
    // Definição do canvas(posso personalizar também)
    let canvasView: PKCanvasView = {
        let cv = PKCanvasView()
        cv.drawingPolicy = .anyInput
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private var customToolbar: UIToolbar!

    // State
    private var currentToolSet: ToolSet!
    private var currentOpacity: CGFloat = 1.0
    private var currentInkingWidth: CGFloat = 5
    private var currentEraserWidth: CGFloat = 5
    private var currentColor: UIColor!
    private var currentInkType: PKInkingTool.InkType!

    // Tools
    private var inkingTool: PKInkingTool!
    private var eraserTool: PKEraserTool!

    // Dot grid view
    private let gridView = DotGridView()
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        canvasView.backgroundColor = .white
        canvasView.minimumZoomScale = 1.0
        canvasView.maximumZoomScale = 5.0
        canvasView.bouncesZoom = true

        setupCanvas()
        setupSliders()
        setupToolbar()
        setupInitialToolSet()
        setupButtonSharePlay()
        startConnectSharePlayTimer()
    }
    
    // Setup
    private func setupCanvas() {
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        gridView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridView)

        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: canvasView.topAnchor),
            gridView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
            gridView.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor),
        ])

        gridView.isUserInteractionEnabled = false
    }
    
    private func setupToolbar() {
        customToolbar = UIToolbar()
        customToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customToolbar)

        NSLayoutConstraint.activate([
            customToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        buildToolbarItems()
    }
    
    private func setupInitialToolSet() {
        // recebe do Model
        currentToolSet = ToolSetManager.random()
        apply(toolSet: currentToolSet)
        showToolsetInfo()
    }
    
    // Setup Sliders
    private let slidersContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.9)
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        return view
    }()

    private func setupSliders() {
        view.addSubview(slidersContainer)
        
        // Configuração do container principal
        NSLayoutConstraint.activate([
            slidersContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            slidersContainer.widthAnchor.constraint(equalToConstant: 100),
            slidersContainer.heightAnchor.constraint(equalToConstant: 550)
        ])
        
        // Adiciona os elementos diretamente no container
        slidersContainer.addSubview(opacityIcon)
        slidersContainer.addSubview(opacitySlider)
        slidersContainer.addSubview(widthIcon)
        slidersContainer.addSubview(widthSlider)
        
        NSLayoutConstraint.activate([
            opacityIcon.centerXAnchor.constraint(equalTo: slidersContainer.centerXAnchor),
            opacityIcon.topAnchor.constraint(equalTo: slidersContainer.topAnchor, constant: 40),
            opacityIcon.widthAnchor.constraint(equalToConstant: 24),
            opacityIcon.heightAnchor.constraint(equalToConstant: 24),
            
            widthIcon.centerXAnchor.constraint(equalTo: slidersContainer.centerXAnchor),
            widthIcon.bottomAnchor.constraint(equalTo: slidersContainer.bottomAnchor, constant: -40),
            widthIcon.widthAnchor.constraint(equalToConstant: 24),
            widthIcon.heightAnchor.constraint(equalToConstant: 24)
        ])
            
        NSLayoutConstraint.activate([
            opacitySlider.centerXAnchor.constraint(equalTo: slidersContainer.centerXAnchor),
            opacitySlider.centerYAnchor.constraint(equalTo: slidersContainer.centerYAnchor, constant: -100),
            opacitySlider.widthAnchor.constraint(equalToConstant: 240),
            opacitySlider.heightAnchor.constraint(equalToConstant: 30),
        
            widthSlider.centerXAnchor.constraint(equalTo: slidersContainer.centerXAnchor),
            widthSlider.centerYAnchor.constraint(equalTo: slidersContainer.centerYAnchor, constant: 100),
            widthSlider.widthAnchor.constraint(equalToConstant: 240),
            widthSlider.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        opacitySlider.addTarget(self, action: #selector(opacitySliderChanged(_:)), for: .valueChanged)
        widthSlider.addTarget(self, action: #selector(widthSliderChanged(_:)), for: .valueChanged)

        addDragGesture(to: slidersContainer)
    }

    // Método auxiliar que cria stacks de slider
    private func createSliderStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }

    private func positionFloatingView(_ view: UIView, initialPosition: CGPoint) {
        view.frame = CGRect(x: initialPosition.x,
                            y: initialPosition.y,
                            width: 100,
                            height: 320)
    }

    private func addDragGesture(to view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        view.addGestureRecognizer(panGesture)
        view.isUserInteractionEnabled = true
    }

    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let draggedView = gesture.view else { return }
        let translation = gesture.translation(in: self.view)
        
        draggedView.center = CGPoint(
            x: draggedView.center.x + translation.x,
            y: draggedView.center.y + translation.y
        )
        
        gesture.setTranslation(.zero, in: self.view)
        
        if gesture.state == .ended {
            var frame = draggedView.frame
            let safeArea = view.safeAreaLayoutGuide.layoutFrame
            
            frame.origin.x = max(safeArea.minX, min(frame.origin.x, safeArea.maxX - frame.width))
            frame.origin.y = max(safeArea.minY, min(frame.origin.y, safeArea.maxY - frame.height))
            
            UIView.animate(withDuration: 0.3) {
                draggedView.frame = frame
            }
        }
    }

    
    private lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let opacitySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.1
        slider.maximumValue = 1.0
        slider.value = 1.0
        slider.transform = CGAffineTransform(rotationAngle: -.pi/2)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.widthAnchor.constraint(equalToConstant: 200).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return slider
    }()
    
    private let widthSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 2
        slider.maximumValue = 500
        slider.value = 5
        slider.transform = CGAffineTransform(rotationAngle: -.pi/2)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.widthAnchor.constraint(equalToConstant: 200).isActive = true
        slider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return slider
    }()
    
    private let opacityIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "circle.lefthalf.filled"))
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let widthIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "lineweight"))
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // Toolbar items
    private func buildToolbarItems() {
        let color1Item = UIBarButtonItem(
            image: UIImage(systemName: "circle.fill"),
            style: .plain,
            target: self,
            action: #selector(selectColor1))

        let color2Item = UIBarButtonItem(
            image: UIImage(systemName: "circle.fill"),
            style: .plain,
            target: self,
            action: #selector(selectColor2))

        let penItem = UIBarButtonItem(
            image: UIImage(systemName: "pencil.tip"),
            style: .plain,
            target: self,
            action: #selector(selectPen))

        let eraserItem = UIBarButtonItem(
            image: UIImage(systemName: "eraser"),
            style: .plain,
            target: self,
            action: #selector(selectEraser))
        
        let shareItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareButtonTapped))
        
        let undoButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.uturn.left"),
            style: .plain,
            target: self,
            action: #selector(undoTapped))
        
        let redoButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.uturn.right"),
            style: .plain,
            target: self,
            action: #selector(redoTapped))


        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        customToolbar.items = [
            eraserItem,
            space,
            undoButton, redoButton,
            space,
            penItem,
            color1Item, color2Item,
            space,
            shareItem
        ]
    }

    // Tool handling
    private func apply(toolSet: ToolSet) {
        currentInkType = toolSet.inkType
        currentColor = toolSet.color1
        currentOpacity = 1.0           // Garante que a opacidade seja reiniciada
        currentInkingWidth = 5         // Define um tamanho padrão para o pincel
        
        inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
        if #available(iOS 16.4, *) {
            eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
        } else {
            eraserTool = PKEraserTool(.bitmap)
        }
        canvasView.tool = inkingTool
            
        // Sincroniza os sliders com os valores atuais
        opacitySlider.value = Float(currentOpacity)
        widthSlider.value = Float(currentInkingWidth)
            
        updateToolbarColors()
    }

    private func updateToolbarColors() {
        guard let items = customToolbar.items else { return }
        for item in items {
            if item.action == #selector(selectColor1) {
                item.image = UIImage(systemName: "circle.fill")?
                    .withTintColor(currentToolSet.color1, renderingMode: .alwaysOriginal)
            } else if item.action == #selector(selectColor2) {
                item.image = UIImage(systemName: "circle.fill")?
                    .withTintColor(currentToolSet.color2, renderingMode: .alwaysOriginal)
            }
        }
    }

    private func showToolsetInfo() {
        let inkName: String
        switch currentToolSet.inkType {
        case .pen:          inkName = "Caneta"
        case .pencil:       inkName = "Lápis"
        case .marker:       inkName = "Marcador"
        case .monoline:     inkName = "Monolinha"
        case .fountainPen:  inkName = "Caneta tinteiro"
        case .watercolor:   inkName = "Aquarela"
        case .crayon:       inkName = "Giz de cera"
        @unknown default:   inkName = "Ferramenta"
        }

        let alert = UIAlertController(
            title: "Ferramentas Selecionadas",
            message: "Tipo: \(inkName)\nCor 1: \(currentToolSet.color1.accessibilityName)\nCor 2: \(currentToolSet.color2.accessibilityName)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: Toolbar actions -
    @objc private func selectColor1() {
        currentColor = currentToolSet.color1
        inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
        canvasView.tool = inkingTool
    }

    @objc private func selectColor2() {
        currentColor = currentToolSet.color2
        inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
        canvasView.tool = inkingTool
    }

    @objc private func selectPen() {
        canvasView.tool = inkingTool
    }

    @objc private func selectEraser() {
        canvasView.tool = eraserTool
    }

    // MARK: WIDTH -
    @objc private func increaseStrokeWidth() {
        if canvasView.tool is PKInkingTool {
            currentInkingWidth = min(currentInkingWidth + 2, 500)
            widthSlider.value = Float(currentInkingWidth)
            inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
            canvasView.tool = inkingTool
        } else {
            currentEraserWidth = min(currentEraserWidth + 2, 500)
            widthSlider.value = Float(currentEraserWidth)
            if #available(iOS 16.4, *) {
                eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
            } else {
                eraserTool = PKEraserTool(.bitmap)
            }
            canvasView.tool = eraserTool
        }
    }
    
    @objc private func decreaseStrokeWidth() {
        if canvasView.tool is PKInkingTool {
            currentInkingWidth = max(currentInkingWidth - 2, 2)
            widthSlider.value = Float(currentInkingWidth)
            inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
            canvasView.tool = inkingTool
        } else {
            currentEraserWidth = max(currentEraserWidth - 2, 2)
            widthSlider.value = Float(currentEraserWidth)
            if #available(iOS 16.4, *) {
                eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
            } else {
                eraserTool = PKEraserTool(.bitmap)
            }
            canvasView.tool = eraserTool
        }
    }
    
       
    @objc private func widthSliderChanged(_ sender: UISlider) {
        if canvasView.tool is PKInkingTool {
            currentInkingWidth = CGFloat(sender.value)
            inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
            canvasView.tool = inkingTool
        } else {
            currentEraserWidth = CGFloat(sender.value)
            if #available(iOS 16.4, *) {
                eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
            } else {
                eraserTool = PKEraserTool(.bitmap)
            }
            canvasView.tool = eraserTool
        }
    }

    // MARK: OPACITY -
    @objc private func opacitySliderChanged(_ sender: UISlider) {
        currentOpacity = CGFloat(sender.value)
        updateOpacity()
    }

    @objc private func increaseOpacity() {
        currentOpacity = min(currentOpacity + 0.1, 1.0)
        updateOpacity()
    }

    @objc private func decreaseOpacity() {
        currentOpacity = max(currentOpacity - 0.1, 0.1)
        updateOpacity()
    }
    
    private func updateOpacity() {
        currentColor = currentColor.withAlphaComponent(currentOpacity)
        inkingTool = PKInkingTool(currentInkType, color: currentColor, width: currentInkingWidth)
        canvasView.tool = inkingTool
        opacitySlider.value = Float(currentOpacity)
    }
    
    // MARK: SHARE -
    @objc func shareButtonTapped() {
        let drawingBounds = canvasView.bounds
        let image = canvasView.drawing.image(from: drawingBounds, scale: UIScreen.main.scale)
        
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        activityVC.setValue("Drawing", forKey: "subject")

        if let popoverController = activityVC.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.leftBarButtonItem
        }

        present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: REDO and UNDO -
    @objc private func undoTapped() {
        canvasView.undoManager?.undo()
    }

    @objc private func redoTapped() {
        canvasView.undoManager?.redo()
    }
    
    // MARK: SHAREPLAY -
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("Inicie gameplay", for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
}
