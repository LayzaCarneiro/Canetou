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
    let undoRedoControlsView = UndoRedoControlsView()
    
    private struct Constants {
        static let penButtonSize = CGSize(width: 130, height: 130)
        static let eraserButtonSize = CGSize(width: 110, height: 110)
        static let colorCircleSize: CGFloat = 50
        static let penEraserSpacing: CGFloat = -60
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        setupButtons()
        setupConstraints()
        applyRandomColors()
    }
    
    private func setupButtons() {
        // Pen button
        penButton.setImage(UIImage(named: "pen")?.withRenderingMode(.alwaysOriginal), for: .normal)
        penButton.imageView?.contentMode = .scaleAspectFit
        penButton.imageView?.translatesAutoresizingMaskIntoConstraints = false
        penButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi / 2)
        penButton.contentHorizontalAlignment = .fill
        penButton.contentVerticalAlignment = .fill

        // Eraser button
        eraserButton.setImage(UIImage(named: "eraser")?.withRenderingMode(.alwaysOriginal), for: .normal)
        eraserButton.imageView?.contentMode = .scaleAspectFit
        eraserButton.imageView?.translatesAutoresizingMaskIntoConstraints = false
        eraserButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi / 2)
        eraserButton.contentHorizontalAlignment = .fill
        eraserButton.contentVerticalAlignment = .fill
        
        // Color buttons style
        [color1Button, color2Button].forEach {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = Constants.colorCircleSize / 2
            
            // Target para clique
            $0.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
        }
        
        // Add subviews
        [penButton, eraserButton, color1Button, color2Button, undoRedoControlsView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            penButton.topAnchor.constraint(equalTo: topAnchor),
            penButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            penButton.widthAnchor.constraint(equalToConstant: Constants.penButtonSize.width),
            penButton.heightAnchor.constraint(equalToConstant: Constants.penButtonSize.height),

            eraserButton.topAnchor.constraint(equalTo: penButton.bottomAnchor, constant: Constants.penEraserSpacing),
            eraserButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            eraserButton.widthAnchor.constraint(equalToConstant: Constants.eraserButtonSize.width),
            eraserButton.heightAnchor.constraint(equalToConstant: Constants.eraserButtonSize.height),

            color1Button.topAnchor.constraint(equalTo: eraserButton.bottomAnchor, constant: -15),
            color1Button.centerXAnchor.constraint(equalTo: centerXAnchor),
            color1Button.widthAnchor.constraint(equalToConstant: Constants.colorCircleSize),
            color1Button.heightAnchor.constraint(equalToConstant: Constants.colorCircleSize),

            color2Button.topAnchor.constraint(equalTo: color1Button.bottomAnchor, constant: 25),
            color2Button.centerXAnchor.constraint(equalTo: centerXAnchor),
            color2Button.widthAnchor.constraint(equalToConstant: Constants.colorCircleSize),
            color2Button.heightAnchor.constraint(equalToConstant: Constants.colorCircleSize),

            undoRedoControlsView.topAnchor.constraint(equalTo: color2Button.bottomAnchor, constant: 25),
            undoRedoControlsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            undoRedoControlsView.widthAnchor.constraint(equalToConstant: 150),
            undoRedoControlsView.heightAnchor.constraint(equalToConstant: 60),
            undoRedoControlsView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }
    
    func highlightSelectedColor(selectedButton: UIButton) {
        let buttons = [color1Button, color2Button]
        
        buttons.forEach { button in
            if button == selectedButton {
                // Botão selecionado maior, com borda maior
                button.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                button.layer.borderWidth = 5
                button.layer.borderColor = button.backgroundColor?.cgColor
                
                // Remove subviews antigas antes de adicionar de novo (anéis)
                button.subviews.filter { $0.tag == 98 || $0.tag == 99 }.forEach { $0.removeFromSuperview() }
                
                // Anel branco maior
                let whiteRing = UIView()
                whiteRing.tag = 98
                whiteRing.backgroundColor = .white
                whiteRing.translatesAutoresizingMaskIntoConstraints = false
                whiteRing.layer.cornerRadius = (Constants.colorCircleSize * 0.8) / 2
                whiteRing.clipsToBounds = true
                button.addSubview(whiteRing)
                
                NSLayoutConstraint.activate([
                    whiteRing.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                    whiteRing.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                    whiteRing.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.8),
                    whiteRing.heightAnchor.constraint(equalTo: button.heightAnchor, multiplier: 0.8)
                ])
                
                // Círculo central maior
                let colorDot = UIView()
                colorDot.tag = 99
                colorDot.backgroundColor = button.backgroundColor
                colorDot.translatesAutoresizingMaskIntoConstraints = false
                colorDot.layer.cornerRadius = (Constants.colorCircleSize * 0.6) / 2
                colorDot.clipsToBounds = true
                button.addSubview(colorDot)
                
                NSLayoutConstraint.activate([
                    colorDot.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                    colorDot.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                    colorDot.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.6),
                    colorDot.heightAnchor.constraint(equalTo: button.heightAnchor, multiplier: 0.6)
                ])
                
            } else {
                // Botão não selecionado volta ao normal
                button.transform = .identity
                button.layer.borderWidth = 0
                button.layer.borderColor = nil
                
                // Remove anéis se tiver
                button.subviews.filter { $0.tag == 98 || $0.tag == 99 }.forEach { $0.removeFromSuperview() }
            }
        }
    }


    @objc private func colorButtonTapped(_ sender: UIButton) {
        highlightSelectedColor(selectedButton: sender)
    }

    func highlightSelectedTool(isPenSelected: Bool) {
        let selectedView = isPenSelected ? penButton : eraserButton
        let unselectedView = isPenSelected ? eraserButton : penButton

        selectedView.layer.borderWidth = 3
        selectedView.layer.borderColor = UIColor.systemOrange.cgColor
        selectedView.layer.shadowColor = UIColor.orange.cgColor
        selectedView.layer.shadowOpacity = 0.4
        selectedView.layer.shadowOffset = CGSize(width: 0, height: 2)
        selectedView.layer.shadowRadius = 4

        unselectedView.layer.borderWidth = 0
        unselectedView.layer.shadowOpacity = 0
    }
    
    func applyRandomColors() {
        let toolSet = ToolSetGenerator.randomToolSet()
        color1Button.backgroundColor = toolSet.color1
        color2Button.backgroundColor = toolSet.color2

        DispatchQueue.main.async {
            self.highlightSelectedColor(selectedButton: self.color1Button)
        }
    }

    func setUndoRedoDelegate(_ delegate: UndoRedoControlsViewDelegate) {
        undoRedoControlsView.delegate = delegate
    }
}

#Preview {
    DrawingViewController()
}
