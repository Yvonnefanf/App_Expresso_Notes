import Foundation
import FirebaseAuth
import FirebaseFirestore


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
    
    // 使用固定的key，不依赖用户登录状态
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
    
    // 测试方法：添加测试记录
    func addTestRecord() {
        let testRecord = BrewRecord(
            date: Date(),
            coffeeWeight: "18",
            waterTemperature: 92,
            grindSize: 4,
            preInfusionTime: "30",
            extractionTime: "120",
            yieldAmount: "36"
        )
        addRecord(testRecord)
    }
    
    // 测试方法：清空所有记录
    func clearAllRecords() {
        records.removeAll()
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
    
    private func saveRecords() {
        do {
            let encoded = try JSONEncoder().encode(records)
            UserDefaults.standard.set(encoded, forKey: saveKey)
            print("✅ 成功保存 \(records.count) 条记录")
        } catch {
            print("❌ 保存失败: \(error)")
        }
    }
    
    private func loadRecords() {
        do {
            if let savedData = UserDefaults.standard.data(forKey: saveKey) {
                let decoded = try JSONDecoder().decode([BrewRecord].self, from: savedData)
                records = decoded
                print("✅ 成功加载 \(records.count) 条记录")
            } else {
                records = []
                print("ℹ️ 没有找到保存的数据，初始化为空数组")
            }
        } catch {
            records = []
            print("❌ 加载失败: \(error)")
        }
    }
} 
