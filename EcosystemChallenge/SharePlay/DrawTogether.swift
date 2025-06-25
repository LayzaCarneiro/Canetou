//
//  DrawTogether.swift
//  UiKitProject
//
//  Created by Vinicius Gabriel on 11/06/25.
//

import UIKit
import GroupActivities

struct DrawTogether: GroupActivity {
    var drawingID: String

    static var activityIdentifier: String { "com.Canetou" }
        
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = NSLocalizedString("Desenhem!", comment: "Title of group activity")
        metadata.previewImage = UIImage(named: "CanetouIcon")?.cgImage
        metadata.type = .createTogether
        return metadata
    }
}
