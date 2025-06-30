//
//  SlidersContainerView.swift
//  DrawingExample
//
//  Created by [Seu Nome] em [Data]
//

import UIKit

final class SlidersContainerView: UIView {
    let toolButtonsView = ToolButtonsView()
    let undoRedoView = UndoRedoControlsView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.9)
        layer.cornerRadius = 24
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        layer.borderColor = UIColor.orange.cgColor
        layer.borderWidth = 2
        
        addSubview(toolButtonsView)
        addSubview(undoRedoView)
        
        toolButtonsView.translatesAutoresizingMaskIntoConstraints = false
        undoRedoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toolButtonsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            toolButtonsView.topAnchor.constraint(equalTo: topAnchor),
            toolButtonsView.widthAnchor.constraint(equalTo: widthAnchor),
            
            undoRedoView.topAnchor.constraint(equalTo: toolButtonsView.bottomAnchor),
            undoRedoView.centerXAnchor.constraint(equalTo: centerXAnchor),
            undoRedoView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            undoRedoView.heightAnchor.constraint(equalToConstant: 80),
            undoRedoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }
}

#Preview {
    SlidersContainerView()
}
