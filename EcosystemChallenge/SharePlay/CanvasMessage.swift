//
//  CanvasMessage.swift
//  UiKitProject
//
//  Created by Vinicius Gabriel on 13/06/25.
//

import Foundation
import PencilKit

struct CanvasMessage: Codable {
    let drawingData: Data
    // Define se é o último desenho da sessão
    let isFinalDrawing: Bool
    // Define o id de cada usuário na sessão
    var senderID: String
}
