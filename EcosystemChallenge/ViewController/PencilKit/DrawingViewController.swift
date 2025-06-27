//  ViewController.swift
//  DrawingExample
//
//  Created by Leticia Bezerra on 04/06/25.
//

import UIKit
import PencilKit

final class DrawingViewController: UIViewController, UIGestureRecognizerDelegate, PKCanvasViewDelegate {
    // Definição do canvas
    private let canvasView: PKCanvasView = {
        let cv = PKCanvasView()
        cv.drawingPolicy = .anyInput
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    // State
    private var currentToolSet: ToolSet!
    private var currentOpacity: CGFloat = 1.0
    private var currentInkingWidth: CGFloat = ToolSizes.medium
    private var currentEraserWidth: CGFloat = ToolSizes.medium
    private var currentColor: UIColor!
    private var currentInkType: PKInkingTool.InkType!

    // Tools
    private var inkingTool: PKInkingTool!
    private var eraserTool: PKEraserTool!
    
    // Propriedades do pop-up da caneta
    private var penOptionsPopup: PopupBubbleView!
    private var isPenOptionsVisible = false
    
    // Propriedades do pup-up borracha
    private var eraserOptionsPopup: PopupBubbleView!
    private var isEraserOptionsVisible = false

    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        view.backgroundColor = .white
        canvasView.backgroundColor = .white

        setupCanvas()
        setupSliders()
        setupInitialToolSet()
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTapOutsidePopup(_:))
        )
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    // Setup
    private func setupCanvas() {
        view.addSubview(canvasView)
        canvasView.delegate = self
        canvasView.isExclusiveTouch = false
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupInitialToolSet() {
        currentToolSet = ToolSetManager.random()
        apply(toolSet: currentToolSet)
        showToolsetInfo()
    }
    
    private enum ToolSizes {
        static let small: CGFloat = 10
        static let medium: CGFloat = 20
        static let large: CGFloat = 30
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

        NSLayoutConstraint.activate([
            slidersContainer.centerYAnchor
                .constraint(equalTo: view.centerYAnchor),
            slidersContainer.widthAnchor.constraint(equalToConstant: 150),
            slidersContainer.heightAnchor.constraint(equalToConstant: 350),
        ])

        slidersContainer.addSubview(penButton)
        slidersContainer.addSubview(eraserButton)
        slidersContainer.addSubview(color1Button)
        slidersContainer.addSubview(color2Button)

        NSLayoutConstraint.activate([
            penButton.centerXAnchor
                .constraint(equalTo: slidersContainer.centerXAnchor),
            penButton.widthAnchor.constraint(equalToConstant: 50),
            penButton.heightAnchor.constraint(equalToConstant: 90),
            
            eraserButton.centerXAnchor
                .constraint(equalTo: slidersContainer.centerXAnchor),
            eraserButton.topAnchor
                .constraint(equalTo: penButton.bottomAnchor, constant: -22),
            eraserButton.widthAnchor.constraint(equalToConstant: 50),
            eraserButton.heightAnchor.constraint(equalToConstant: 90),

            color1Button.centerXAnchor
                .constraint(equalTo: slidersContainer.centerXAnchor),
            color1Button.topAnchor
                .constraint(equalTo: eraserButton.bottomAnchor, constant: -1),
            color1Button.widthAnchor.constraint(equalToConstant: 70),
            color1Button.heightAnchor.constraint(equalToConstant: 70),

            color2Button.centerXAnchor
                .constraint(equalTo: slidersContainer.centerXAnchor),
            color2Button.topAnchor
                .constraint(equalTo: color1Button.bottomAnchor, constant: -1),
            color2Button.widthAnchor.constraint(equalToConstant: 70),
            color2Button.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        penButton
            .addTarget(self, action: #selector(selectPen), for: .touchUpInside)
        eraserButton
            .addTarget(
                self,
                action: #selector(selectEraser),
                for: .touchUpInside
            )
        color1Button
            .addTarget(
                self,
                action: #selector(selectColor1),
                for: .touchUpInside
            )
        color2Button
            .addTarget(
                self,
                action: #selector(selectColor2),
                for: .touchUpInside
            )

        // Esconde sliders inicialmente
        opacitySlider.isHidden = true
        opacityIcon.isHidden = true
        widthSlider.isHidden = true
        widthIcon.isHidden = true

        addDragGesture(to: slidersContainer)
    }

    // Configura o pop-up do penButton
    private func setupToolPopup(
        for button: UIButton,
        isForPen: Bool,
        currentSize: CGFloat,
        onSizeTap: @escaping (CGFloat) -> Void,
        sliderValue: Float? = nil,
        onSliderChange: ((Float) -> Void)? = nil
    ) -> PopupBubbleView {
        let popup = PopupBubbleView()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.alpha = 0
        view.addSubview(popup)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        popup.addSubview(stackView)

        // Slider -> Caneta
        if isForPen, let sliderValue = sliderValue {
            let slider = UISlider()
            slider.minimumValue = 0.1
            slider.maximumValue = 1.0
            slider.value = sliderValue
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.widthAnchor.constraint(equalToConstant: 160).isActive = true
                
            slider
                .addTarget(
                    self,
                    action: #selector(opacitySliderChanged(_:)),
                    for: .valueChanged
                )
                
            stackView.addArrangedSubview(slider)
        }

        // Tamanhos da caneta/borracha
        let sizeStack = UIStackView()
        sizeStack.axis = .horizontal
        sizeStack.spacing = 24
        sizeStack.distribution = .fillEqually
        sizeStack.alignment = .center

        let sizes: [(size: CGFloat, name: String, visualSize: CGFloat)] = [
            (ToolSizes.small, "Small", 30),
            (ToolSizes.medium, "Medium", 50),
            (ToolSizes.large, "Large", 70)
        ]

        for sizeInfo in sizes {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
                    
            // Tamanho visual do círculo (independente do tamanho real)
            button.widthAnchor
                .constraint(
                    equalToConstant: sizeInfo.visualSize
                ).isActive = true
            button.heightAnchor
                .constraint(
                    equalToConstant: sizeInfo.visualSize
                ).isActive = true
            button.layer.cornerRadius = sizeInfo.visualSize / 2
                    
            button.backgroundColor = currentColor
            button.accessibilityLabel = sizeInfo.name
                    
            button.addAction(UIAction(handler: { _ in
                print("Selecionado tamanho \(sizeInfo.name): \(sizeInfo.size)")
                onSizeTap(sizeInfo.size)
            }), for: .touchUpInside)
                    
            sizeStack.addArrangedSubview(button)
        }


        stackView.addArrangedSubview(sizeStack)

        NSLayoutConstraint.activate([
            popup.trailingAnchor
                .constraint(
                    equalTo: slidersContainer.leadingAnchor,
                    constant: -20
                ),
            popup.centerYAnchor.constraint(equalTo: button.centerYAnchor),

            stackView.topAnchor
                .constraint(equalTo: popup.topAnchor, constant: 20),
            stackView.bottomAnchor
                .constraint(equalTo: popup.bottomAnchor, constant: -20),
            stackView.leadingAnchor
                .constraint(equalTo: popup.leadingAnchor, constant: 20),
            stackView.trailingAnchor
                .constraint(equalTo: popup.trailingAnchor, constant: -20)
        ])

        return popup
    }
    
    private func setupPenOptionsPopup() {
        penOptionsPopup = setupToolPopup(
            for: penButton,
            isForPen: true,
            currentSize: currentInkingWidth,
            onSizeTap: { [weak self] size in
                guard let self = self else { return }
                print("Aplicando tamanho da caneta: \(size)")
                self.currentInkingWidth = size
                self.inkingTool = PKInkingTool(
                    self.currentInkType,
                    color: self.currentColor,
                    width: size
                )
                self.canvasView.tool = self.inkingTool
            },
            sliderValue: Float(currentOpacity),
            onSliderChange: { [weak self] value in
                guard let self = self else { return }
                self.currentOpacity = CGFloat(value)
                self.updateOpacity()
            }
        )
        view.bringSubviewToFront(penOptionsPopup)
    }

    private func setupEraserOptionsPopup() {
        eraserOptionsPopup = setupToolPopup(
            for: eraserButton,
            isForPen: false,
            currentSize: currentEraserWidth,
            onSizeTap: { [weak self] size in
                guard let self = self else { return }
                print("Aplicando tamanho da borracha: \(size)")
                self.currentEraserWidth = size
                self.eraserTool = PKEraserTool(.bitmap, width: size)
                self.canvasView.tool = self.eraserTool
            }
        )
        view.bringSubviewToFront(eraserOptionsPopup)
    }
    
    private func updatePopupCircleColors() {
        if let popup = penOptionsPopup {
            for case let button as UIButton in popup.subviews
                .flatMap({ $0.subviews }) {
                if button.tag == 100 || button.tag == 200 || button.tag == 300 {
                    button.backgroundColor = currentColor.withAlphaComponent(1)
                }
            }
        }
        
        if let slider = penOptionsPopup?.viewWithTag(999) as? UISlider {
            slider.value = Float(currentOpacity)
        }
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        currentOpacity = CGFloat(sender.value)
        updateOpacity()
    }

    @objc private func animateButtonDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }

    @objc private func animateButtonUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = .identity
        }
    }
    
    private func togglePenOptionsPopup() {
        if penOptionsPopup == nil {
            setupPenOptionsPopup()
            view.bringSubviewToFront(penOptionsPopup)
        }

        isPenOptionsVisible.toggle()

        UIView.animate(withDuration: 0.3) {
            self.penOptionsPopup.alpha = self.isPenOptionsVisible ? 1 : 0
            self.penOptionsPopup.isUserInteractionEnabled = self.isPenOptionsVisible
        }
    }
    
    private func toggleEraserOptionsPopup() {
        if eraserOptionsPopup == nil {
            setupEraserOptionsPopup()
            view.bringSubviewToFront(eraserOptionsPopup)
        }

        isEraserOptionsVisible.toggle()

        UIView.animate(withDuration: 0.3) {
            self.eraserOptionsPopup.alpha = self.isEraserOptionsVisible ? 1 : 0
            self.eraserOptionsPopup.isUserInteractionEnabled = self.isEraserOptionsVisible
        }
    }

    @objc private func handleTapOutsidePopup(
        _ gesture: UITapGestureRecognizer
    ) {
        let location = gesture.location(in: view)

        if isPenOptionsVisible, let popup = penOptionsPopup {
            let tappedInside = popup.frame.contains(location) || slidersContainer.frame.contains(
                location
            )
            if !tappedInside {
                togglePenOptionsPopup()
            }
        }

        if isEraserOptionsVisible, let popup = eraserOptionsPopup {
            let tappedInside = popup.frame.contains(location) || slidersContainer.frame.contains(
                location
            )
            if !tappedInside {
                toggleEraserOptionsPopup()
            }
        }
    }

    private func addDragGesture(to view: UIView) {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleDrag(_:))
        )
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

            frame.origin.x = max(
                safeArea.minX,
                min(frame.origin.x, safeArea.maxX - frame.width)
            )
            frame.origin.y = max(
                safeArea.minY,
                min(frame.origin.y, safeArea.maxY - frame.height)
            )

            UIView.animate(withDuration: 0.3) {
                draggedView.frame = frame
            }
        }

        if isPenOptionsVisible {
            updatePopupPosition()
        }
    }
    
    private func updatePopupPosition() {
        guard let popup = penOptionsPopup else { return }
        
        UIView.animate(withDuration: 0.2) {
            popup.center.y = self.penButton.center.y
        }
        
        if isEraserOptionsVisible {
            UIView.animate(withDuration: 0.2) {
                self.eraserOptionsPopup.center.y = self.eraserButton.center.y
            }
        }
    }
    
    // UI Elements
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
        let imageView = UIImageView(
            image: UIImage(systemName: "circle.lefthalf.filled")
        )
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
    
    private let penButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "pen")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.transform = CGAffineTransform(rotationAngle: .pi/2)
        return button
    }()
    
    private let eraserButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "eraser")?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.transform = CGAffineTransform(rotationAngle: .pi/2)
        return button
    }()

    private let color1Button: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(
            pointSize: 40,
            weight: .regular
        )
        button
            .setImage(
                UIImage(systemName: "circle.fill", withConfiguration: config),
                for: .normal
            )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let color2Button: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(
            pointSize: 40,
            weight: .regular
        )
        button
            .setImage(
                UIImage(systemName: "circle.fill", withConfiguration: config),
                for: .normal
            )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // Tool handling
    private func apply(toolSet: ToolSet) {
        currentInkType = toolSet.inkType
        currentColor = toolSet.color1
        currentOpacity = 1.0
        currentInkingWidth = ToolSizes.medium
        currentEraserWidth = ToolSizes.medium
            
        inkingTool = PKInkingTool(
            currentInkType,
            color: currentColor,
            width: currentInkingWidth
        )
        eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
        canvasView.tool = inkingTool

        opacitySlider.value = Float(currentOpacity)
        widthSlider.value = Float(currentInkingWidth)

        updateToolbarColors()
    }

    private func updateToolbarColors() {
        color1Button.tintColor = currentToolSet.color1
        color2Button.tintColor = currentToolSet.color2
    }
    
    private func updateInkingTool() {
        inkingTool = PKInkingTool(
            currentInkType,
            color: currentColor.withAlphaComponent(currentOpacity),
            width: currentInkingWidth
        )
        if canvasView.tool is PKInkingTool {
            canvasView.tool = inkingTool
        }
    }

    private func updateEraserTool() {
        eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
        if canvasView.tool is PKEraserTool {
            canvasView.tool = eraserTool
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

    @objc private func selectColor1() {
        currentColor = currentToolSet.color1.withAlphaComponent(currentOpacity)
        inkingTool = PKInkingTool(
            currentInkType,
            color: currentColor,
            width: currentInkingWidth
        )
        canvasView.tool = inkingTool
        
        updatePopupCircleColors()
    }

    @objc private func selectColor2() {
        currentColor = currentToolSet.color2
            .withAlphaComponent(currentOpacity)
        inkingTool = PKInkingTool(
            currentInkType,
            color: currentColor,
            width: currentInkingWidth
        )
        canvasView.tool = inkingTool
        
        updatePopupCircleColors()
    }
    
    @objc private func selectPen() {
        print("Selecionando caneta. Tamanho atual: \(currentInkingWidth)")
        canvasView.tool = inkingTool
        togglePenOptionsPopup()
        
        if let slider = penOptionsPopup?.viewWithTag(999) as? UISlider {
            slider.value = Float(currentOpacity)
        }
        
        opacitySlider.isHidden = true
        opacityIcon.isHidden = true
        widthSlider.isHidden = true
        widthIcon.isHidden = true
    }

    @objc private func selectEraser() {
        print("Selecionando borracha. Tamanho atual: \(currentEraserWidth)")
        canvasView.tool = eraserTool
        
        widthSlider.isHidden = true
        widthIcon.isHidden = true
        opacitySlider.isHidden = true
        opacityIcon.isHidden = true

        if isPenOptionsVisible {
            togglePenOptionsPopup()
        }

        toggleEraserOptionsPopup()
    }


    @objc private func opacitySliderChanged(_ sender: UISlider) {
        currentOpacity = CGFloat(sender.value)
        
        let baseColor = (
            currentColor == currentToolSet.color1 ? currentToolSet.color1 : currentToolSet.color2
        )
        currentColor = baseColor.withAlphaComponent(currentOpacity)
        
        inkingTool = PKInkingTool(
            currentInkType,
            color: currentColor,
            width: currentInkingWidth
        )
        canvasView.tool = inkingTool
        
        if !opacitySlider.isHidden {
            opacitySlider.value = sender.value
        }
    }
       
    @objc private func widthSliderChanged(_ sender: UISlider) {
        if canvasView.tool is PKInkingTool {
            currentInkingWidth = CGFloat(sender.value)
            inkingTool = PKInkingTool(
                currentInkType,
                color: currentColor,
                width: currentInkingWidth
            )
            canvasView.tool = inkingTool
        } else {
            currentEraserWidth = CGFloat(sender.value)
            eraserTool = PKEraserTool(.bitmap, width: currentEraserWidth)
            canvasView.tool = eraserTool
        }
    }

    private func updateOpacity() {
        let baseColor = (
            currentColor == currentToolSet.color1 ? currentToolSet.color1 : currentToolSet.color2
        )
        currentColor = baseColor.withAlphaComponent(currentOpacity)
        inkingTool = PKInkingTool(
            currentInkType,
            color: currentColor,
            width: currentInkingWidth
        )
        canvasView.tool = inkingTool
        
        opacitySlider.value = Float(currentOpacity)
        if let popupSlider = penOptionsPopup?.viewWithTag(999) as? UISlider {
            popupSlider.value = Float(currentOpacity)
        }
    }
    
    @objc private func undoTapped() {
        canvasView.undoManager?.undo()
    }

    @objc private func redoTapped() {
        canvasView.undoManager?.redo()
    }
    
    internal func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        if isPenOptionsVisible {
            togglePenOptionsPopup()
        }
        
        if isEraserOptionsVisible {
            toggleEraserOptionsPopup()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard let touch = touches.first else { return }

        if (touch.type == .pencil || touch.type == .stylus) && canvasView.frame
            .contains(touch.location(in: view)) {
            if isPenOptionsVisible {
                togglePenOptionsPopup()
            }
            if isEraserOptionsVisible {
                toggleEraserOptionsPopup()
            }
        }
    }
}

final class PopupBubbleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        let bubbleColor = UIColor.systemGray6.withAlphaComponent(0.95)

        let path = UIBezierPath()
        let cornerRadius: CGFloat = 12
        let arrowWidth: CGFloat = 20
        let arrowHeight: CGFloat = 10
        _ = CGPoint(x: bounds.width, y: bounds.midY - arrowWidth/2)

        path.move(to: CGPoint(x: bounds.width - cornerRadius, y: 0))
        path
            .addLine(
                to: CGPoint(x: bounds.width, y: bounds.midY - arrowWidth/2)
            )
        path.addLine(to: CGPoint(x: bounds.width - arrowHeight, y: bounds.midY))
        path
            .addLine(
                to: CGPoint(x: bounds.width, y: bounds.midY + arrowWidth/2)
            )
        path
            .addLine(
                to: CGPoint(x: bounds.width - cornerRadius, y: bounds.height)
            )

        path
            .addArc(
                withCenter: CGPoint(
                    x: cornerRadius,
                    y: bounds.height - cornerRadius
                ),
                radius: cornerRadius,
                startAngle: .pi/2,
                endAngle: .pi,
                clockwise: true
            )
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
                    radius: cornerRadius, startAngle: .pi, endAngle: .pi*3/2, clockwise: true)

        path.close()
        bubbleColor.setFill()
        path.fill()

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowPath = path.cgPath
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 200, height: 150)
    }
}

#Preview {
    DrawingViewController()
}
