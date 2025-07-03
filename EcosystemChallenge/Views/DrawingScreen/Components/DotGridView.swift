//
//  DotGridView.swift
//  EcosystemChallenge
//
//  Created by Leticia Bezerra on 29/06/25.
//

import UIKit

final class DotGridView: UIView {
    let dotSpacing: CGFloat = 30
    let dotRadius: CGFloat = 1.5
    let dotColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5)
    
    override func draw(_ rect: CGRect) {
        // Desenha a grade de pontos na view
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.white.cgColor)
               context.fill(rect)
        
        context.setFillColor(dotColor.cgColor)
        
        let firstCol = Int((rect.minX) / dotSpacing)
        let lastCol = Int((rect.maxX) / dotSpacing) + 1
        let firstRow = Int((rect.minY) / dotSpacing)
        let lastRow = Int((rect.maxY) / dotSpacing) + 1
        
        for row in firstRow...lastRow {
            for col in firstCol...lastCol {
                let x = CGFloat(col) * dotSpacing
                let y = CGFloat(row) * dotSpacing
                let dotRect = CGRect(x: x - dotRadius, y: y - dotRadius,
                                     width: dotRadius * 2, height: dotRadius * 2)
                context.fillEllipse(in: dotRect)
            }
        }
    }
}

//#Preview {
//    DotGridView()
//}
