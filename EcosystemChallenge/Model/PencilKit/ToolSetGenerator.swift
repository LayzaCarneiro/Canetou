//
//  ToolSetGenerator.swift
//  EcosystemChallenge
//
//  Created by Leticia Bezerra on 29/06/25.
//

import PencilKit
import UIKit

enum ToolSetGenerator {
    private static let inkTypes: [PKInkingTool.InkType] = [
        .pen, .pencil, .marker, .monoline,
        .fountainPen, .watercolor, .crayon
    ]
    
//    private static let inkTypes: [PKInkingTool.InkType] = [
//        .pen, .pencil, .marker
//    ]
    
    private static let colors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemYellow, .systemOrange,
        .systemPurple, .systemPink, .systemTeal, .systemIndigo, .systemBrown,
        .systemMint, .systemCyan, .systemGray, .black
    ]
    
    static func randomToolSet() -> ToolSet {
        let inkType = inkTypes.randomElement() ?? .pen
        let shuffledColors = colors.shuffled()
        
        // Garante cores diferentes
        let color1 = shuffledColors[0]
        var color2 = shuffledColors[1]
        
        if color1 == color2 {
            color2 = colors.first(where: { $0 != color1 }) ?? .black
        }
        
        return ToolSet(
            inkType: inkType,
            color1: color1,
            color2: color2
        )
    }
}
