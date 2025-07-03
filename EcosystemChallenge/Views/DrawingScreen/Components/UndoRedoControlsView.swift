//
//  UndoRedoControlsView.swift
//  DrawingExample
//
//  Created by [Seu Nome] em [Data]
//

import UIKit

protocol UndoRedoControlsViewDelegate: AnyObject {
    func didTapUndo()
    func didTapRedo()
}

final class UndoRedoControlsView: UIView {
    
    weak var delegate: UndoRedoControlsViewDelegate?
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = -20
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private(set) lazy var undoButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "arrow.uturn.backward.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 40, weight: .regular))
        config.baseForegroundColor = .systemGray2
        
        let button = UIButton(configuration: config)
        button.isEnabled = false
        button.addTarget(self, action: #selector(undoButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = "Desfazer"
        button.accessibilityHint = "Reverte a última ação de desenho"
        return button
    }()
    
    private(set) lazy var redoButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "arrow.uturn.forward.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 40, weight: .regular))
        config.baseForegroundColor = .systemGray2
        
        let button = UIButton(configuration: config)
        button.isEnabled = false
        button.addTarget(self, action: #selector(redoButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = "Refazer"
        button.accessibilityHint = "Repete a última ação desfeita"
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // Atualiza a aparência e estado de ativação dos botões de desfazer e refazer
    func updateButtonsState(canUndo: Bool, canRedo: Bool) {
        undoButton.isEnabled = canUndo
        redoButton.isEnabled = canRedo

        undoButton.configuration?.baseForegroundColor = canUndo ? .systemGray3 : .systemGray2
        redoButton.configuration?.baseForegroundColor = canRedo ? .systemGray3 : .systemGray2
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(undoButton)
        stackView.addArrangedSubview(redoButton)
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addButtonTouchAnimations()
    }
    
    // Adiciona animações de escala ao pressionar os botões
    private func addButtonTouchAnimations() {
        [undoButton, redoButton].forEach { button in
            button.addTarget(self, action: #selector(animateButtonDown(_:)), for: [.touchDown, .touchDragEnter])
            button.addTarget(self, action: #selector(animateButtonUp(_:)), for: [.touchUpInside, .touchDragExit, .touchCancel])
        }
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
    
    // Informa ao delegate que o botão de desfazer foi tocado
    @objc private func undoButtonTapped() {
        delegate?.didTapUndo()
    }
    
    // Informa ao delegate que o botão de refazer foi tocado
    @objc private func redoButtonTapped() {
        delegate?.didTapRedo()
    }
}

#Preview {
    DrawingViewController()
}
