//
//  ToolsContainerView.swift
//  EcosystemChallenge
//
//  Created by Leticia Bezerra on 29/06/25.
//

import UIKit

// Container para os botões de ferramentas de desenho (ToolButtonsView)
final class ToolsContainerView: UIView {
    let toolButtonsView = ToolButtonsView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // Configura o layout visual e adiciona ToolButtonsView ao container
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
            toolButtonsView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            toolButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            toolButtonsView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -12)
        ])
    }
}

//#Preview {
//    DrawingViewController()
//}
