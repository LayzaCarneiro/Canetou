//
//  ToolSetManager.swift
//  PocPencilKitSharePlay
//
//  Created by Leticia Bezerra on 16/06/25.
//

import PencilKit

final class ToolManager {
    static let shared = ToolManager()
    
    private init() {}
    
    private(set) var currentInkingTool: PKInkingTool!
    private(set) var currentEraserTool: PKEraserTool!
    
    var inkType: PKInkingTool.InkType = .pen
    var color: UIColor = .black
    var opacity: CGFloat = 1.0
    var inkingWidth: CGFloat = 15
    var eraserWidth: CGFloat = 20
    
    func updateInkingTool() {
        let colorWithOpacity = color.withAlphaComponent(opacity)
        currentInkingTool = PKInkingTool(inkType, color: colorWithOpacity, width: inkingWidth)
    }
    
    func updateEraserTool() {
        currentEraserTool = PKEraserTool(.bitmap, width: eraserWidth)
    }
    
    func setupInitialTools() {
        updateInkingTool()
        updateEraserTool()
    }
}

import SwiftUI

#Preview {
    VStack {
        Circle()
            .frame(height: 5)
        Circle()
            .frame(height: 20)
        Circle()
            .frame(height: 30)
    }
}
