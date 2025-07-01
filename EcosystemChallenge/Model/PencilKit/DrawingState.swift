//
//  DrawingState.swift
//  EcosystemChallenge
//
//  Created by Leticia Bezerra on 29/06/25.
//

import UIKit
import PencilKit

struct DrawingState {
    var currentToolSet: ToolSet
    var currentColor: UIColor
    var currentInkType: PKInkingTool.InkType
    var currentOpacity: CGFloat
    var currentInkingWidth: CGFloat
    var currentEraserWidth: CGFloat
    
    static var initial: DrawingState {
        let randomToolSet = ToolSetGenerator.randomToolSet()
        print("ToolSet gerado - Tipo: \(randomToolSet.inkType), Cor1: \(randomToolSet.color1.accessibilityName), Cor2: \(randomToolSet.color2.accessibilityName)")
        
        return DrawingState(
            currentToolSet: randomToolSet,
            currentColor: randomToolSet.color1,
            currentInkType: randomToolSet.inkType,
            currentOpacity: 1.0,
            currentInkingWidth: 15,
            currentEraserWidth: 20
        )
    }
}
