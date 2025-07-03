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

final class ThickSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.trackRect(forBounds: bounds)
        return CGRect(x: original.origin.x, y: original.origin.y, width: original.width, height: 12)
    }
}

final class PopupBubbleView: UIView {

    var toolType: ToolType = .pen

    private let opacitySlider: ThickSlider = {
        let slider = ThickSlider()
        slider.minimumValue = 0.1
        slider.maximumValue = 1.0
        slider.value = 1.0
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.transform = .identity
        slider.minimumTrackTintColor = .systemOrange
        slider.maximumTrackTintColor = .systemGray3
        return slider
    }()

    private let opacityControlsContainer = UIStackView()

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
        (30, "Grande", 40)
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

    // Botões aumenta e diminuir opacidade
    private func makeControlButton(systemName: String, action: Selector) -> UIButton {
        var config = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        config.image = UIImage(systemName: systemName, withConfiguration: symbolConfig)
        let button = UIButton(configuration: config)
        button.tintColor = .systemGray4
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func setupView() {
        backgroundColor = UIColor.white.withAlphaComponent(0.9)
        layer.cornerRadius = 24
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6

        let decreaseButton = makeControlButton(systemName: "minus.circle.fill", action: #selector(decreaseOpacity))
        let increaseButton = makeControlButton(systemName: "plus.circle.fill", action: #selector(increaseOpacity))

        // Slider horizontal
        opacitySlider.transform = .identity

        // Opacity controls (slider + botões)
        opacityControlsContainer.axis = .horizontal
        opacityControlsContainer.alignment = .center
        opacityControlsContainer.translatesAutoresizingMaskIntoConstraints = false
        opacityControlsContainer.addArrangedSubview(decreaseButton)
        opacityControlsContainer.addArrangedSubview(opacitySlider)
        opacityControlsContainer.addArrangedSubview(increaseButton)
        opacityControlsContainer.setCustomSpacing(7, after: opacitySlider)

        // Size buttons (bolinhas)
        sizeStack.axis = .horizontal
        sizeStack.spacing = 50
        
        if toolType == .eraser {
            sizeStack.layoutMargins = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
            sizeStack.isLayoutMarginsRelativeArrangement = true
        }

        let mainStack = UIStackView(arrangedSubviews: [sizeStack, opacityControlsContainer])
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            opacitySlider.widthAnchor.constraint(equalToConstant: 200)
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
            button.backgroundColor = CGFloat(button.tag) == size ? .systemOrange : .systemGray4
        }

        onThicknessChanged?(size)
    }

    @objc private func opacityChanged() {
        onOpacityChanged?(CGFloat(opacitySlider.value))
    }

    @objc private func increaseOpacity() {
        let step: Float = 0.05
        let newValue = min(opacitySlider.maximumValue, opacitySlider.value + step)
        opacitySlider.setValue(newValue, animated: true)
        opacityChanged()
    }

    @objc private func decreaseOpacity() {
        let step: Float = 0.05
        let newValue = max(opacitySlider.minimumValue, opacitySlider.value - step)
        opacitySlider.setValue(newValue, animated: true)
        opacityChanged()
    }

    func setOpacitySliderHidden(_ hidden: Bool) {
        opacityControlsContainer.isHidden = hidden
    }
}

//#Preview {
//    DrawingViewController()
//}
//
