//
//  ToolSetManager.swift
//  PocPencilKitSharePlay
//
//  Created by Leticia Bezerra on 16/06/25.
//

import PencilKit
import UIKit

enum ToolSetManager {

    // Tipos de pincel
//    private static let inkTypes: [PKInkingTool.InkType] = [
//        .pen, .pencil, .marker, .monoline,
//        .fountainPen, .watercolor, .crayon
//    ]
    
    private static let inkTypes: [PKInkingTool.InkType] = [
        .pen, .pencil, .marker
    ]

    // Cores 
    private static let colors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemYellow, .systemOrange,
        .systemPurple, .systemPink, .systemTeal, .systemIndigo, .systemBrown,
        .systemMint, .systemCyan, .systemGray, .black
    ]

    static func random() -> ToolSet {
        let inkType = inkTypes.randomElement() ?? .pen
        let randomColors = Array(colors.shuffled().prefix(2))
        print(inkType)
        print(randomColors)
        
        return ToolSet(
            inkType: inkType,
            color1: randomColors[0],
            color2: randomColors[1]
        )
    }
}

