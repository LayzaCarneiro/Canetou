//
//  DrawingViewController.swift
//  DrawingExample
//
//  Created by Leticia Bezerra on 04/06/25.
//

import Combine
import UIKit
import PencilKit
import GroupActivities
import Contacts

final class DrawingViewController: UIViewController, UIGestureRecognizerDelegate, PKCanvasViewDelegate, UndoRedoControlsViewDelegate {
    
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
    
    var finalImages: [UIImage] = []
    
    private struct LayoutConstants {
        static let slidersWidth: CGFloat = 150
        static let slidersHeight: CGFloat = 420
        static let slidersLeading: CGFloat = 20
        static let headerTop: CGFloat = 45
        static let headerHeight: CGFloat = 80
        static let headerLeading: CGFloat = 250
    }
    
    // UI Elements
    let canvasView = PKCanvasView()
    private let slidersContainer = SlidersContainerView()
    private var penOptionsPopup: PopupBubbleView!
    private var eraserOptionsPopup: PopupBubbleView!
    
    // State Management
    private let toolManager = ToolManager.shared
    private var drawingState = DrawingState.initial
    private var isPenOptionsVisible = false
    private var isEraserOptionsVisible = false
    private var isUsingEraser = false
    
    private let dotGridView = DotGridView()
    private let headerView = DrawingHeaderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light

        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        canvasView.backgroundColor = .white
        canvasView.minimumZoomScale = 1.0
        canvasView.maximumZoomScale = 5.0
        canvasView.bouncesZoom = true
        
        configureView()
        setupHeader()
        setupCanvas()
        setupSliders()
        setupInitialToolSet()
        setupGestureRecognizers()
        setupPopups()
        setupButtonActions()
        
        setupButtonSharePlay()
        startConnectSharePlayTimer()
    }
    
    private func configureView() {
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.headerTop),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstants.headerLeading),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: LayoutConstants.headerHeight)
        ])
        
        headerView.configure(
            prompts: ["Desenhe um gato na praia"],
            initialTimeInSeconds: 120
        )
    }

    private func setupCanvas() {
        dotGridView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(dotGridView, at: 0)
        
        NSLayoutConstraint.activate([
            dotGridView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dotGridView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dotGridView.topAnchor.constraint(equalTo: view.topAnchor),
            dotGridView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.delegate = self
        canvasView.isExclusiveTouch = false
        view.insertSubview(canvasView, aboveSubview: dotGridView)
        
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupSliders() {
        view.addSubview(slidersContainer)
        slidersContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            slidersContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            slidersContainer.widthAnchor.constraint(equalToConstant: LayoutConstants.slidersWidth),
            slidersContainer.heightAnchor.constraint(equalToConstant: LayoutConstants.slidersHeight),
            slidersContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: LayoutConstants.slidersLeading)
        ])

        //addDragGesture(to: slidersContainer)
    }

    private func setupInitialToolSet() {
        drawingState = DrawingState.initial
        toolManager.inkType = drawingState.currentToolSet.inkType
        toolManager.color = drawingState.currentToolSet.color1
        toolManager.setupInitialTools()
        updateColorButtons()
        updateCanvasTool()
    }
    
    private func updateColorButtons() {
        slidersContainer.toolButtonsView.color1Button.backgroundColor = drawingState.currentToolSet.color1
        slidersContainer.toolButtonsView.color2Button.backgroundColor = drawingState.currentToolSet.color2
        slidersContainer.toolButtonsView.color1Button.setNeedsLayout()
        slidersContainer.toolButtonsView.color2Button.setNeedsLayout()
    }
    
    private func updateCanvasTool() {
        if isUsingEraser {
            toolManager.updateEraserTool()
            canvasView.tool = toolManager.currentEraserTool
        } else {
            toolManager.updateInkingTool()
            canvasView.tool = toolManager.currentInkingTool
        }
        updateUndoRedoButtons()
    }
    
    private func updateUndoRedoButtons() {
        slidersContainer.toolButtonsView.undoRedoControlsView.updateButtonsState(
            canUndo: canvasView.undoManager?.canUndo ?? false,
            canRedo: canvasView.undoManager?.canRedo ?? false
        )
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)

        // Verifica se o toque foi dentro dos popups
        let touchedPenPopup = isPenOptionsVisible && penOptionsPopup.frame.contains(location)
        let touchedEraserPopup = isEraserOptionsVisible && eraserOptionsPopup.frame.contains(location)

        // Se o popup está visível e o toque foi fora dele, esconde
        if isPenOptionsVisible && !touchedPenPopup {
            togglePenOptionsPopup()
        }

        if isEraserOptionsVisible && !touchedEraserPopup {
            toggleEraserOptionsPopup()
        }
    }

    // Popups
    private func setupPopups() {
        setupPenOptionsPopup()
        setupEraserOptionsPopup()
    }
    
    private func setupPenOptionsPopup() {
        penOptionsPopup = PopupBubbleView()
        penOptionsPopup.translatesAutoresizingMaskIntoConstraints = false
        penOptionsPopup.alpha = 0
        penOptionsPopup.isUserInteractionEnabled = false

        penOptionsPopup.onOpacityChanged = { [weak self] newOpacity in
            self?.toolManager.opacity = newOpacity
            self?.toolManager.updateInkingTool()
            self?.canvasView.tool = self?.toolManager.currentInkingTool ?? PKInkingTool(.pen, color: .black, width: 5)
        }

        penOptionsPopup.onThicknessChanged = { [weak self] newinkingWidth in
            self?.toolManager.inkingWidth = newinkingWidth
            self?.toolManager.updateInkingTool()
            self?.canvasView.tool = self?.toolManager.currentInkingTool ?? PKInkingTool(.pen, color: .black, width: 5)
        }

        view.addSubview(penOptionsPopup)
        
        NSLayoutConstraint.activate([
            penOptionsPopup.topAnchor.constraint(equalTo: slidersContainer.topAnchor),
            penOptionsPopup.leadingAnchor.constraint(equalTo: slidersContainer.trailingAnchor, constant: 8),
            penOptionsPopup.widthAnchor.constraint(equalToConstant: 250),
            penOptionsPopup.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    private func setupEraserOptionsPopup() {
        eraserOptionsPopup = PopupBubbleView()
        eraserOptionsPopup.toolType = .eraser
        eraserOptionsPopup.translatesAutoresizingMaskIntoConstraints = false
        eraserOptionsPopup.alpha = 0
        eraserOptionsPopup.isUserInteractionEnabled = false
        eraserOptionsPopup.setOpacitySliderHidden(true)
        
        // Adicione este callback para escutar mudanças na espessura da borracha:
        eraserOptionsPopup.onThicknessChanged = { [weak self] newWidth in
            guard let self = self else { return }
            self.toolManager.eraserWidth = newWidth
            self.toolManager.updateEraserTool()
            if self.isUsingEraser {
                self.canvasView.tool = self.toolManager.currentEraserTool
            }
        }
        
        view.addSubview(eraserOptionsPopup)
        
        NSLayoutConstraint.activate([
            eraserOptionsPopup.topAnchor.constraint(equalTo: slidersContainer.topAnchor),
            eraserOptionsPopup.leadingAnchor.constraint(equalTo: slidersContainer.trailingAnchor, constant: 8),
            eraserOptionsPopup.widthAnchor.constraint(equalToConstant: 150),
            eraserOptionsPopup.heightAnchor.constraint(equalToConstant: 250),
        ])
        headerView.hideSettingsIfVisible()
    }
    
    private func togglePenOptionsPopup() {
        if isPenOptionsVisible {
            hidePopup(penOptionsPopup)
            isPenOptionsVisible = false
        } else {
            showPopup(penOptionsPopup)
            hidePopup(eraserOptionsPopup)
            isPenOptionsVisible = true
            isEraserOptionsVisible = false
        }
        headerView.hideSettingsIfVisible()
    }
    

    private func toggleEraserOptionsPopup() {
        if isEraserOptionsVisible {
            hidePopup(eraserOptionsPopup)
            isEraserOptionsVisible = false
        } else {
            showPopup(eraserOptionsPopup)
            hidePopup(penOptionsPopup)
            isEraserOptionsVisible = true
            isPenOptionsVisible = false
        }
        headerView.hideSettingsIfVisible()
    }
    
    private func showPopup(_ popup: UIView) {
        popup.isUserInteractionEnabled = true
        popup.alpha = 0
        popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.25, animations: {
                    popup.alpha = 1
                    popup.transform = .identity
        })
    }

    private func hidePopup(_ popup: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            popup.alpha = 0
            popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            popup.isUserInteractionEnabled = false
        }
    }


    // Button Actions
    private func setupButtonActions() {
        let buttons = slidersContainer.toolButtonsView
        buttons.penButton.addTarget(self, action: #selector(selectPen), for: .touchUpInside)
        buttons.eraserButton.addTarget(self, action: #selector(selectEraser), for: .touchUpInside)
        buttons.color1Button.addTarget(self, action: #selector(selectColor1), for: .touchUpInside)
        buttons.color2Button.addTarget(self, action: #selector(selectColor2), for: .touchUpInside)
        
        buttons.setUndoRedoDelegate(self)
    }

    @objc private func selectPen() {
        isUsingEraser = false
        updateCanvasTool()
        if isEraserOptionsVisible { toggleEraserOptionsPopup() }
        togglePenOptionsPopup()
    }
    
    @objc private func selectEraser() {
        isUsingEraser = true
        updateCanvasTool()
        if isPenOptionsVisible { togglePenOptionsPopup() }
        toggleEraserOptionsPopup()
    }
    
    @objc private func selectColor1() {
        headerView.hideSettingsIfVisible()
        toolManager.color = drawingState.currentToolSet.color1
        
        if !(canvasView.tool is PKEraserTool) {
            toolManager.updateInkingTool()
            canvasView.tool = toolManager.currentInkingTool
        }
    }

    @objc private func selectColor2() {
        headerView.hideSettingsIfVisible()
        var newToolSet = drawingState.currentToolSet
        
        if newToolSet.color2.isEqual(newToolSet.color1) {
            newToolSet.color2 = .black
        }
        
        drawingState.currentToolSet = newToolSet
        
        slidersContainer.toolButtonsView.color1Button.backgroundColor = newToolSet.color1
        slidersContainer.toolButtonsView.color2Button.backgroundColor = newToolSet.color2
        
        toolManager.color = newToolSet.color2
        
        if !(canvasView.tool is PKEraserTool) {
            toolManager.updateInkingTool()
            canvasView.tool = toolManager.currentInkingTool
        }
        
        // Importante: só aqui a seleção visual
        slidersContainer.toolButtonsView.highlightSelectedColor(selectedButton: slidersContainer.toolButtonsView.color2Button)
    }

    func didTapUndo() {
        canvasView.undoManager?.undo()
        updateUndoRedoButtons()
    }
    
    func didTapRedo() {
        canvasView.undoManager?.redo()
        updateUndoRedoButtons()
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateUndoRedoButtons()
        
        if isPenOptionsVisible {
            togglePenOptionsPopup()
        }
        if isEraserOptionsVisible {
            toggleEraserOptionsPopup()
        }
        headerView.hideSettingsIfVisible()
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

#Preview {
    DrawingViewController()
}
