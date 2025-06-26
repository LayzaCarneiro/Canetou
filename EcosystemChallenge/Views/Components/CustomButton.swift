//
//  CustomButton.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 26/06/25.
//

import UIKit

class CustomButton: UIView {

    private let titleLabel = UILabel()
    private let buttonFrontView = UIView()
    private let shadowView = UIView()

    private var frontTopConstraint: NSLayoutConstraint!

    var title: String
    var onTap: (() -> Void)?

    private let shadowHeight: CGFloat = 50.0
    private let initialShadowOffset: CGFloat = -40.0
    
    // Retorno tátil
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupViews()
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false

        // Sombra
        shadowView.backgroundColor = UIColor(named: "indigodark") ?? .darkGray
        shadowView.layer.cornerRadius = 10
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shadowView)

        // Frente
        buttonFrontView.backgroundColor = UIColor(named: "indigo") ?? .systemBlue
        buttonFrontView.layer.cornerRadius = 10
        buttonFrontView.translatesAutoresizingMaskIntoConstraints = false
        buttonFrontView.clipsToBounds = true
        addSubview(buttonFrontView)

        // Título
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 27, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonFrontView.addSubview(titleLabel)

        frontTopConstraint = buttonFrontView.topAnchor.constraint(equalTo: self.topAnchor)

        NSLayoutConstraint.activate([
            // Sombra
            shadowView.topAnchor.constraint(equalTo: buttonFrontView.bottomAnchor, constant: initialShadowOffset),
            shadowView.centerXAnchor.constraint(equalTo: centerXAnchor),
            shadowView.widthAnchor.constraint(equalTo: widthAnchor),
            shadowView.heightAnchor.constraint(equalToConstant: shadowHeight),

            // Frente
            frontTopConstraint,
            buttonFrontView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonFrontView.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonFrontView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Título
            titleLabel.centerXAnchor.constraint(equalTo: buttonFrontView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: buttonFrontView.centerYAnchor)
        ])
    }

    // MARK: - Interação

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonFrontView.transform = CGAffineTransform(translationX: 0, y: 5)
        
        hapticFeedback.prepare()
        hapticFeedback.impactOccurred()

        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonFrontView.transform = .identity

        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.onTap?()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        buttonFrontView.transform = .identity

        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
}
