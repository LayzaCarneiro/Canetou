//
//  Model.swift
//  PocPencilKitSharePlay
//
//  Created by Leticia Bezerra on 16/06/25.
//

import PencilKit
import UIKit

struct ToolSet {
    let inkType: PKInkingTool.InkType
    let color1: UIColor
    var color2: UIColor 
    
    static let initial = ToolSet(
        inkType: .pen,
        color1: .systemBlue,
        color2: .systemRed
    )
}
