//
//  Item.swift
//  Coffe
//
//  Created by Ying Huang on 16/05/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
