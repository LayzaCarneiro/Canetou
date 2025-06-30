//
//  PopupBubbleView.swift
//  EcosystemChallenge
//
//  Created by Leticia Bezerra on 29/06/25.
//

import UIKit

enum ToolType {
    case pen
    case eraser
}

final class PopupBubbleView: UIView {
    
    var toolType: ToolType = .pen
    
    private let opacitySlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.1
        slider.maximumValue = 1.0
        slider.value = 1.0
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        return slider
    }()
    
    private let sizeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let sizes: [(size: CGFloat, name: String, visualSize: CGFloat)] = [
        (10, "Pequeno", 20),
        (20, "Médio", 30),
        (30, "Grande", 50)
    ]
    
    var onThicknessChanged: ((CGFloat) -> Void)?
    var onOpacityChanged: ((CGFloat) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        createSizeButtons()
        updateSelectedSize(sizes[0].size)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        createSizeButtons()
        updateSelectedSize(sizes[0].size)
    }
    
    private func setupView() {
        backgroundColor = UIColor.systemGray6.withAlphaComponent(0.95)
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        let mainStack = UIStackView(arrangedSubviews: [opacitySlider, sizeStack])
        mainStack.axis = .horizontal
        mainStack.spacing = -50
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -20),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            opacitySlider.widthAnchor.constraint(equalToConstant: 180),
        ])
        
        opacitySlider.addTarget(self, action: #selector(opacityChanged), for: .valueChanged)
    }
    
    private func createSizeButtons() {
        for sizeInfo in sizes {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .systemGray4
            button.layer.cornerRadius = sizeInfo.visualSize / 2
            button.tag = Int(sizeInfo.size)
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: sizeInfo.visualSize),
                button.heightAnchor.constraint(equalToConstant: sizeInfo.visualSize)
            ])
            
            button.addAction(UIAction { [weak self] _ in
                self?.updateSelectedSize(sizeInfo.size)
            }, for: .touchUpInside)
            
            sizeStack.addArrangedSubview(button)
        }
    }
    
    private func updateSelectedSize(_ size: CGFloat) {
        for case let button as UIButton in sizeStack.arrangedSubviews {
            button.backgroundColor = CGFloat(button.tag) == size ? .systemBlue : .systemGray4
        }
        
        if toolType == .pen {
            onThicknessChanged?(size)
        } else {
            onThicknessChanged?(size)
        }
    }
    
    @objc private func opacityChanged() {
        onOpacityChanged?(CGFloat(opacitySlider.value))
    }
    
    func setOpacitySliderHidden(_ hidden: Bool) {
        opacitySlider.isHidden = hidden
    }
}

#Preview {
    let popup = PopupBubbleView()
    popup.frame = CGRect(x: 0, y: 0, width: 300, height: 150)
    return popup
}
