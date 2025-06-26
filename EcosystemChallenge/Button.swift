//
//  Button.swift
//  EcosystemChallenge
//
//  Created by Hadassa Vitoria on 26/06/25.
//

import UIKit

class Button: UIButton {
    let buttonShadowView = UIView()
    private var shadowViewTopConstraint: NSLayoutConstraint!
    
    private let initialShadowOffset: CGFloat = -40.0
    private let animationMoveDistance: CGFloat = 5.0
    
    private var buttonTitle: String
    
    init(title: String, frame: CGRect = .zero){
        self.buttonTitle = title
        super.init(frame: frame)
        setupButton()
        setupButtonShadowView()
        addTargetsForAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(named: "indigo")
        
        let font = UIFont.systemFont(ofSize: 27, weight: .medium)
        let attributedTitle = AttributedString("Criar Sala", attributes: AttributeContainer([
            .font: font,
            .foregroundColor: UIColor.white
               ]))
        config.attributedTitle = attributedTitle
        self.configuration = config
               
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
    }
    
    private func setupButtonShadowView() {
        buttonShadowView.backgroundColor = UIColor(named: "indigodark")
        buttonShadowView.translatesAutoresizingMaskIntoConstraints = false
        buttonShadowView.layer.cornerRadius = 10
        buttonShadowView.clipsToBounds = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = self.superview, buttonShadowView.superview === nil else { return }
        
        superview.insertSubview(buttonShadowView, belowSubview: self)
        
        shadowViewTopConstraint = buttonShadowView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: initialShadowOffset)
        NSLayoutConstraint.activate([
            buttonShadowView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            shadowViewTopConstraint,
            buttonShadowView.widthAnchor.constraint(equalTo: self.widthAnchor),
            buttonShadowView.heightAnchor.constraint(equalToConstant: 50)
                ])
    }
    
    private func addTargetsForAnimation(){
        self.addTarget(self, action: #selector(touchDow), for: .touchDown)
        self.addTarget(self, action: #selector(touchUP), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func touchDow() {
        self.transform = CGAffineTransform(translationX: 0, y: animationMoveDistance)
        shadowViewTopConstraint.constant = initialShadowOffset + animationMoveDistance
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut]) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    @objc private func touchUP() {
        self.transform = .identity
         shadowViewTopConstraint.constant = initialShadowOffset

         UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
             self.superview?.layoutIfNeeded()
         }
    }
    
}
