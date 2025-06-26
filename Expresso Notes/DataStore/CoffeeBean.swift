//
//  CoffeeBean.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 26/6/25.
//

import SwiftUI

// Coffee Bean data sturcture
struct CoffeeBean: Identifiable, Codable {
    var id = UUID()
    var name: String
    var brand: String
    var variety: String
    var origin: String
    var processingMethod: String
    var roastLevel: RoastLevel
    var flavors: [String]
    var dateAdded: Date
    
    enum RoastLevel: String, Codable, CaseIterable {
        case light = "浅焙"
        case medium = "中焙"
        case dark = "深焙"
    }
    
}
