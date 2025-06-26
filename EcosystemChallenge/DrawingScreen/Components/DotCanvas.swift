//
//  DotCanas.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 24/06/25.
//

import UIKit

class DotGridView: UIView {
    var gridSpacing: CGFloat = 20.0
    var dotSize: CGFloat = 1.5
    var dotColor: UIColor = .lightGray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setFillColor(dotColor.cgColor)

        for x in stride(from: 0, to: bounds.width, by: gridSpacing) {
            for y in stride(from: 0, to: bounds.height, by: gridSpacing) {
                let dotRect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                context.fillEllipse(in: dotRect)
            }
        }
    }
}
