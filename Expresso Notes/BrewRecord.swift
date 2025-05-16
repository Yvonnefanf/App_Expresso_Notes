import Foundation

struct BrewRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var coffeeBean: CoffeeBeanReference? // 添加咖啡豆引用
    var coffeeWeight: String
    var waterTemperature: Int
    var grindSize: Int
    var preInfusionTime: String
    var extractionTime: String
    var yieldAmount: String
    var rating: Double? // 修改为小数评分
    var ratingDescription: String? // 添加评分描述
    
    // 计算比例
    var ratio: String {
        if let coffee = Double(coffeeWeight), let yield = Double(yieldAmount), coffee > 0 {
            return String(format: "1:%.1f", yield / coffee)
        }
        return "N/A"
    }
}

// 用于在记录中存储咖啡豆引用的结构体
struct CoffeeBeanReference: Codable, Identifiable {
    var id: UUID
    var name: String
    var brand: String
    var roastLevel: String
    
    init(from coffeeBean: CoffeeBean) {
        self.id = coffeeBean.id
        self.name = coffeeBean.name
        self.brand = coffeeBean.brand
        self.roastLevel = coffeeBean.roastLevel.rawValue
    }
}

class BrewRecordStore: ObservableObject {
    @Published var records: [BrewRecord] = []
    
    private let saveKey = "savedBrewRecords"
    
    init() {
        loadRecords()
    }
    
    func addRecord(_ record: BrewRecord) {
        records.append(record)
        saveRecords()
    }
    
    func deleteRecord(at indexSet: IndexSet) {
        records.remove(atOffsets: indexSet)
        saveRecords()
    }
    
    private func saveRecords() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadRecords() {
        if let savedRecords = UserDefaults.standard.data(forKey: saveKey) {
            if let decodedRecords = try? JSONDecoder().decode([BrewRecord].self, from: savedRecords) {
                records = decodedRecords
                return
            }
        }
        
        records = [] // 如果没有保存的记录或解码失败，创建一个空数组
    }
} 