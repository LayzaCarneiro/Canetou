//
//  ToolManager.swift
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
    var inkingWidth: CGFloat = 10
    
    var eraserWidth: CGFloat = 10
    var eraserType: PKEraserTool.EraserType = .bitmap
    
    func updateInkingTool() {
        let colorWithOpacity = color.withAlphaComponent(opacity)
        currentInkingTool = PKInkingTool(inkType, color: colorWithOpacity, width: inkingWidth)
    }
    
    func updateEraserTool() {
        if #available(iOS 16.4, *) {
            currentEraserTool = PKEraserTool(eraserType, width: eraserWidth)
        } else {
            currentEraserTool = PKEraserTool(eraserType)
        }
    }
    
    func setupInitialTools() {
        updateInkingTool()
        updateEraserTool()
    }
}
