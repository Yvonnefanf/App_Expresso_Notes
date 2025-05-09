import Foundation

struct BrewRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var coffeeWeight: String
    var waterTemperature: Int
    var grindSize: Int
    var preInfusionTime: String
    var extractionTime: String
    var yieldAmount: String
    
    // 计算比例
    var ratio: String {
        if let coffee = Double(coffeeWeight), let yield = Double(yieldAmount), coffee > 0 {
            return String(format: "1:%.1f", yield / coffee)
        }
        return "N/A"
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