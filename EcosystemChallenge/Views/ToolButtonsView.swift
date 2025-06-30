//  ToolButtonsView.swift
//  EcosystemChallenge
//
//  Created by Leticia Bezerra on 29/06/25.
//

import UIKit

final class ToolButtonsView: UIView {
    
    let penButton = UIButton()
    let eraserButton = UIButton()
    let color1Button = UIButton()
    let color2Button = UIButton()
    
    private let penButtonSize = CGSize(width: 80, height: 80)
    private let eraserButtonSize = CGSize(width: 80, height: 80)
    private let colorCircleSize: CGFloat = 50
    private let penEraserSpacing: CGFloat = -20 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        applyRandomColors()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        applyRandomColors()
    }
    
    private func setup() {
        // Configura botões com imagens e rotação
        penButton.setImage(UIImage(named: "pen")?.withRenderingMode(.alwaysOriginal), for: .normal)
        penButton.imageView?.contentMode = .scaleAspectFit
        penButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi / 2)
        
        eraserButton.setImage(UIImage(named: "eraser")?.withRenderingMode(.alwaysOriginal), for: .normal)
        eraserButton.imageView?.contentMode = .scaleAspectFit
        eraserButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi / 2)
        
        // Configura aparência dos botões de cor
        color1Button.clipsToBounds = true
        color2Button.clipsToBounds = true
        color1Button.layer.cornerRadius = colorCircleSize / 2
        color2Button.layer.cornerRadius = colorCircleSize / 2
        
        // Adiciona botões à view
        addSubview(penButton)
        addSubview(eraserButton)
        addSubview(color1Button)
        addSubview(color2Button)
        
        // Auto Layout
        [penButton, eraserButton, color1Button, color2Button].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            penButton.topAnchor.constraint(equalTo: topAnchor),
            penButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            penButton.widthAnchor.constraint(equalToConstant: penButtonSize.width),
            penButton.heightAnchor.constraint(equalToConstant: penButtonSize.height),
            
            eraserButton.topAnchor.constraint(equalTo: penButton.bottomAnchor, constant: penEraserSpacing),
            eraserButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            eraserButton.widthAnchor.constraint(equalToConstant: eraserButtonSize.width),
            eraserButton.heightAnchor.constraint(equalToConstant: eraserButtonSize.height),
            
            color1Button.topAnchor.constraint(equalTo: eraserButton.bottomAnchor, constant: 20),
            color1Button.centerXAnchor.constraint(equalTo: centerXAnchor),
            color1Button.widthAnchor.constraint(equalToConstant: colorCircleSize),
            color1Button.heightAnchor.constraint(equalToConstant: colorCircleSize),
            
            color2Button.topAnchor.constraint(equalTo: color1Button.bottomAnchor, constant: 25),
            color2Button.centerXAnchor.constraint(equalTo: centerXAnchor),
            color2Button.widthAnchor.constraint(equalToConstant: colorCircleSize),
            color2Button.heightAnchor.constraint(equalToConstant: colorCircleSize),
            
            color2Button.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }
    
    func applyRandomColors() {
        let toolSet = ToolSetGenerator.randomToolSet()
        color1Button.backgroundColor = toolSet.color1
        color2Button.backgroundColor = toolSet.color2
    }
}



#Preview {
    DrawingViewController()
}
