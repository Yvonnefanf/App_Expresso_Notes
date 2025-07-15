


// CoffeeBean.swift
import Foundation
import FirebaseFirestore   // ← no FirebaseFirestoreSwift

struct CoffeeBean: Identifiable, Codable {
    var id: UUID
    var name: String
    var brand: String
    var variety: String
    var origin: String
    var processingMethod: String
    var roastLevel: RoastLevel
    var flavors: [String]
    var dateAdded: Date

    enum RoastLevel: String, Codable, CaseIterable {
        case light  = "浅焙"
        case medium = "中焙"
        case dark   = "深焙"
    }

    /// Convert to Firestore data
    func toDict() -> [String:Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "brand": brand,
            "variety": variety,
            "origin": origin,
            "processingMethod": processingMethod,
            "roastLevel": roastLevel.rawValue,
            "flavors": flavors,
            "dateAdded": Timestamp(date: dateAdded)
        ]
    }

    /// Init from Firestore data + documentID
    init?(id: String, data: [String:Any]) {
        guard
            let uuid = UUID(uuidString: id),
            let name = data["name"]               as? String,
            let brand = data["brand"]             as? String,
            let variety = data["variety"]         as? String,
            let origin = data["origin"]           as? String,
            let proc = data["processingMethod"]   as? String,
            let roastRaw = data["roastLevel"]     as? String,
            let roast = RoastLevel(rawValue: roastRaw),
            let flavors = data["flavors"]         as? [String],
            let ts = data["dateAdded"]            as? Timestamp
        else { return nil }

        self.id               = uuid
        self.name             = name
        self.brand            = brand
        self.variety          = variety
        self.origin           = origin
        self.processingMethod = proc
        self.roastLevel       = roast
        self.flavors          = flavors
        self.dateAdded        = ts.dateValue()
    }

    init(
        id: UUID = UUID(),
        name: String,
        brand: String,
        variety: String,
        origin: String,
        processingMethod: String,
        roastLevel: RoastLevel,
        flavors: [String],
        dateAdded: Date
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.variety = variety
        self.origin = origin
        self.processingMethod = processingMethod
        self.roastLevel = roastLevel
        self.flavors = flavors
        self.dateAdded = dateAdded
    }
}
