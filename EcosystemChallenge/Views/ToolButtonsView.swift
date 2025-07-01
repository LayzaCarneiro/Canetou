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
        static let eraserButtonSize = CGSize(width: 120, height: 120)
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
        }
        
        // Add subviews
        [penButton, eraserButton, color1Button, color2Button, undoRedoControlsView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Pen button
            penButton.topAnchor.constraint(equalTo: topAnchor),
            penButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            penButton.widthAnchor.constraint(equalToConstant: Constants.penButtonSize.width),
            penButton.heightAnchor.constraint(equalToConstant: Constants.penButtonSize.height),
            
            // Eraser button
            eraserButton.topAnchor.constraint(equalTo: penButton.bottomAnchor, constant: Constants.penEraserSpacing),
            eraserButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            eraserButton.widthAnchor.constraint(equalToConstant: Constants.eraserButtonSize.width),
            eraserButton.heightAnchor.constraint(equalToConstant: Constants.eraserButtonSize.height),
            
            // Color1 button
            color1Button.topAnchor.constraint(equalTo: eraserButton.bottomAnchor, constant: -15),
            color1Button.centerXAnchor.constraint(equalTo: centerXAnchor),
            color1Button.widthAnchor.constraint(equalToConstant: Constants.colorCircleSize),
            color1Button.heightAnchor.constraint(equalToConstant: Constants.colorCircleSize),
            
            // Color2 button
            color2Button.topAnchor.constraint(equalTo: color1Button.bottomAnchor, constant: 25),
            color2Button.centerXAnchor.constraint(equalTo: centerXAnchor),
            color2Button.widthAnchor.constraint(equalToConstant: Constants.colorCircleSize),
            color2Button.heightAnchor.constraint(equalToConstant: Constants.colorCircleSize),
            
            // Undo/Redo controls
            undoRedoControlsView.topAnchor.constraint(equalTo: color2Button.bottomAnchor, constant: 25),
            undoRedoControlsView.centerXAnchor.constraint(equalTo: centerXAnchor),
            undoRedoControlsView.widthAnchor.constraint(equalToConstant: 150),
            undoRedoControlsView.heightAnchor.constraint(equalToConstant: 60),
            undoRedoControlsView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }
    
    // Helpers
    func applyRandomColors() {
        let toolSet = ToolSetGenerator.randomToolSet()
        color1Button.backgroundColor = toolSet.color1
        color2Button.backgroundColor = toolSet.color2
    }

    func setUndoRedoDelegate(_ delegate: UndoRedoControlsViewDelegate) {
        undoRedoControlsView.delegate = delegate
    }
}


#Preview {
    DrawingViewController()
}
