import Foundation
import FirebaseAuth
import FirebaseFirestore


struct BrewRecord: Identifiable, Codable {
    @DocumentID var documentID: String?    // Firestore 文档 ID（可选）
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
    
//    private let saveKey = "savedBrewRecords"
    private var saveKey: String? {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }
        return "savedBrewRecords_\(uid)"
    }
    // 监听 Auth 状态
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // 先 load 一次
        loadRecords()
        
        // 然后监听登录/登出
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
                // 当用户切换或登出/登录时，刷新一遍本地记录
            self?.loadRecords()
        }
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func addRecord(_ record: BrewRecord) {
        records.append(record)
        saveRecords()
    }
    
    func deleteRecord(at indexSet: IndexSet) {
        guard saveKey != nil else { return }
        
        records.remove(atOffsets: indexSet)
        saveRecords()
    }
    
//    private func saveRecords() {
//        if let encoded = try? JSONEncoder().encode(records) {
//            UserDefaults.standard.set(encoded, forKey: saveKey)
//        }
//    }
    
    private func saveRecords() {
        guard let key = saveKey else { return }
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func loadRecords() {
        // 先清空当前数组
        records = []
        
        guard let key = saveKey else {
            // 如果用户未登录，records 保持空数组
            return
        }
        
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([BrewRecord].self, from: savedData) {
            records = decoded
        } else {
            // 如果没有任何保存数据或解码失败，依然保持空数组
            records = []
        }
    }

//    private func loadRecords() {
//        if let savedRecords = UserDefaults.standard.data(forKey: saveKey) {
//            if let decodedRecords = try? JSONDecoder().decode([BrewRecord].self, from: savedRecords) {
//                records = decodedRecords
//                return
//            }
//        }
//        
//        records = [] // 如果没有保存的记录或解码失败，创建一个空数组
//    }
} 
