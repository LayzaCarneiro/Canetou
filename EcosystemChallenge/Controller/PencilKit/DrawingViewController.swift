//
//  DrawingViewController.swift
//  DrawingExample
//
//  Created by Leticia Bezerra on 04/06/25.
//

import UIKit
import PencilKit

final class DrawingViewController: UIViewController, UIGestureRecognizerDelegate, PKCanvasViewDelegate, UndoRedoControlsViewDelegate {
    
    // UI Elements
    private let canvasView = PKCanvasView()
    private let slidersContainer = SlidersContainerView()
    private var penOptionsPopup: PopupBubbleView!
    private var eraserOptionsPopup: PopupBubbleView!
    
    // State Management
    private let toolManager = ToolManager.shared
    private var drawingState = DrawingState.initial
    private var isPenOptionsVisible = false
    private var isEraserOptionsVisible = false
    
    private let dotGridView = DotGridView()
    
    private let headerView = DrawingHeaderView()

    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupHeader()
        setupCanvas()
        setupSliders()
        setupInitialToolSet()
        setupGestureRecognizers()
        setupPopups()
        setupButtonActions()
        setupUndoRedoControls()
    }
    
    // View Configuration
    private func configureView() {
        overrideUserInterfaceStyle = .light
        view.backgroundColor = .white
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 180),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 80)
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
            slidersContainer.widthAnchor.constraint(equalToConstant: 150),
            slidersContainer.heightAnchor.constraint(equalToConstant: 400),
            slidersContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        ])

        addDragGesture(to: slidersContainer)
    }
    
    private func setupUndoRedoControls() {
        slidersContainer.undoRedoView.delegate = self
    }
    
    // Tool Management
    private func setupInitialToolSet() {
        drawingState = DrawingState.initial
        toolManager.inkType = drawingState.currentToolSet.inkType
        toolManager.color = drawingState.currentToolSet.color1
        toolManager.setupInitialTools()
        updateColorButtons()
        updateCanvasTool()
        
        // Debug
        print("Configuração atual:",
              "\nTipo: \(drawingState.currentToolSet.inkType)",
              "\nCor 1: \(drawingState.currentToolSet.color1.accessibilityName)",
              "\nCor 2: \(drawingState.currentToolSet.color2.accessibilityName)")
    }
    
    private func updateColorButtons() {
        slidersContainer.toolButtonsView.color1Button.backgroundColor = drawingState.currentToolSet.color1
        slidersContainer.toolButtonsView.color2Button.backgroundColor = drawingState.currentToolSet.color2
    }
    
    private func apply(toolSet: ToolSet) {
        drawingState.currentToolSet = toolSet
        toolManager.inkType = toolSet.inkType
        toolManager.color = toolSet.color1
        toolManager.setupInitialTools()
        updateCanvasTool()
    }
    
    private func updateCanvasTool() {
        if canvasView.tool is PKEraserTool {
            print(toolManager.currentEraserTool.width)
            canvasView.tool = toolManager.currentEraserTool
        } else {
            canvasView.tool = toolManager.currentInkingTool
        }
        updateUndoRedoButtons()
    }
    
    private func updateUndoRedoButtons() {
        slidersContainer.undoRedoView.updateButtonsState(
            canUndo: canvasView.undoManager?.canUndo ?? false,
            canRedo: canvasView.undoManager?.canRedo ?? false
        )
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsidePopup(_:)))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func addDragGesture(to view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleTapOutsidePopup(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if isPenOptionsVisible, !penOptionsPopup.frame.contains(location) {
            togglePenOptionsPopup()
        }
        if isEraserOptionsVisible, !eraserOptionsPopup.frame.contains(location) {
            toggleEraserOptionsPopup()
        }
    }
    
    @objc private func handleDrag(_ gesture: UIPanGestureRecognizer) {
        guard let draggedView = gesture.view else { return }
        let translation = gesture.translation(in: view)
        draggedView.center = CGPoint(
            x: draggedView.center.x + translation.x,
            y: draggedView.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: view)
    }
    
    // Popup Management
    private func setupPopups() {
        setupPenOptionsPopup()
        setupEraserOptionsPopup()
    }
    
    private func setupPenOptionsPopup() {
        penOptionsPopup = PopupBubbleView()
        penOptionsPopup.translatesAutoresizingMaskIntoConstraints = false
        penOptionsPopup.alpha = 0
        penOptionsPopup.isUserInteractionEnabled = false
        
        view.addSubview(penOptionsPopup)
        
        NSLayoutConstraint.activate([
            penOptionsPopup.bottomAnchor.constraint(equalTo: slidersContainer.toolButtonsView.penButton.topAnchor, constant: -10),
            penOptionsPopup.leadingAnchor.constraint(equalTo: slidersContainer.leadingAnchor),
            penOptionsPopup.widthAnchor.constraint(equalToConstant: 250),
            penOptionsPopup.heightAnchor.constraint(equalToConstant: 280)
        ])
        
        penOptionsPopup.onThicknessChanged = { [weak self] newSize in
            self?.toolManager.inkingWidth = newSize
            self?.toolManager.updateInkingTool()
            self?.updateCanvasTool()
        }
        
        penOptionsPopup.onOpacityChanged = { [weak self] newOpacity in
            self?.toolManager.opacity = newOpacity
            self?.toolManager.updateInkingTool()
            self?.updateCanvasTool()
        }
    }
    
    private func setupEraserOptionsPopup() {
        eraserOptionsPopup = PopupBubbleView()
        eraserOptionsPopup.translatesAutoresizingMaskIntoConstraints = false
        eraserOptionsPopup.alpha = 0
        eraserOptionsPopup.isUserInteractionEnabled = false
        eraserOptionsPopup.setOpacitySliderHidden(true)
        
        view.addSubview(eraserOptionsPopup)
        
        NSLayoutConstraint.activate([
            eraserOptionsPopup.bottomAnchor.constraint(equalTo: slidersContainer.toolButtonsView.eraserButton.topAnchor, constant: -10),
            eraserOptionsPopup.leadingAnchor.constraint(equalTo: slidersContainer.leadingAnchor),
            eraserOptionsPopup.widthAnchor.constraint(equalToConstant: 120), // Reduzido de 280
            eraserOptionsPopup.heightAnchor.constraint(equalToConstant: 280)  // Reduzido de 280
        ])
        
        eraserOptionsPopup.onThicknessChanged = { [weak self] newSize in
            self?.toolManager.eraserWidth = newSize
            print("Eraser Width: \(newSize)")
            self?.toolManager.updateEraserTool()
            self?.updateCanvasTool()
        }
    }
    
    private func togglePenOptionsPopup() {
        isPenOptionsVisible.toggle()
        UIView.animate(withDuration: 0.3) {
            self.penOptionsPopup.alpha = self.isPenOptionsVisible ? 1 : 0
            self.penOptionsPopup.isUserInteractionEnabled = self.isPenOptionsVisible
        }
    }
    
    private func toggleEraserOptionsPopup() {
        isEraserOptionsVisible.toggle()
        UIView.animate(withDuration: 0.3) {
            self.eraserOptionsPopup.alpha = self.isEraserOptionsVisible ? 1 : 0
            self.eraserOptionsPopup.isUserInteractionEnabled = self.isEraserOptionsVisible
        }
    }
    
    // Button Actions
    private func setupButtonActions() {
        let buttons = slidersContainer.toolButtonsView
        buttons.penButton.addTarget(self, action: #selector(selectPen), for: .touchUpInside)
        buttons.eraserButton.addTarget(self, action: #selector(selectEraser), for: .touchUpInside)
        buttons.color1Button.addTarget(self, action: #selector(selectColor1), for: .touchUpInside)
        buttons.color2Button.addTarget(self, action: #selector(selectColor2), for: .touchUpInside)
    }
    
    @objc private func selectPen() {
        canvasView.tool = toolManager.currentInkingTool
        if isEraserOptionsVisible { toggleEraserOptionsPopup() }
        togglePenOptionsPopup()
    }
    
    @objc private func selectEraser() {
        canvasView.tool = toolManager.currentEraserTool
        if isPenOptionsVisible { togglePenOptionsPopup() }
        toggleEraserOptionsPopup()
    }
    
    @objc private func selectColor1() {
        toolManager.color = drawingState.currentToolSet.color1
        
        if !(canvasView.tool is PKEraserTool) {
            toolManager.updateInkingTool()
            canvasView.tool = toolManager.currentInkingTool
        }
        
        // Debug
        print("Cor 1 selecionada - Botão: \(drawingState.currentToolSet.color1.accessibilityName), Caneta: \(toolManager.color.accessibilityName)")
    }

    @objc private func selectColor2() {
        var newToolSet = drawingState.currentToolSet
        
        if newToolSet.color2.isEqual(newToolSet.color1) {
            newToolSet.color2 = .black
        }
        
        drawingState.currentToolSet = newToolSet
        updateColorButtons()
        
        toolManager.color = newToolSet.color2
        
        if !(canvasView.tool is PKEraserTool) {
            toolManager.updateInkingTool()
            canvasView.tool = toolManager.currentInkingTool
        }
        
        // Debug
        print("Cor 2 selecionada - Botão: \(newToolSet.color2.accessibilityName), Caneta: \(toolManager.color.accessibilityName)")
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
    }
}

#Preview {
    DrawingViewController()
}
