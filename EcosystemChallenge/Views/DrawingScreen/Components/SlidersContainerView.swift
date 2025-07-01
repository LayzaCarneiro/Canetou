//
//  SlidersContainerView.swift
//  DrawingExample
//
//  Created by [Seu Nome] em [Data]
//

import UIKit

final class SlidersContainerView: UIView {
    let toolButtonsView = ToolButtonsView()
    
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
        
        toolButtonsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toolButtonsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            toolButtonsView.topAnchor.constraint(equalTo: topAnchor),
            toolButtonsView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
}
