import Foundation
import FirebaseAuth
import FirebaseFirestore


struct BrewRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var coffeeBean: CoffeeBeanReference? // 添加咖啡豆引用
    var coffeeWeight: String
    var waterTemperature: Int
    var grindSize: Double
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
    
    // 自定义初始化器，用于测试
    init(id: UUID, name: String, brand: String, roastLevel: String) {
        self.id = id
        self.name = name
        self.brand = brand
        self.roastLevel = roastLevel
    }
}

class BrewRecordStore: ObservableObject {
    @Published var records: [BrewRecord] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    init() {
        subscribe()
    }

    func subscribe() {
        guard let userId = userId else { return }
        listener?.remove()
        listener = db.collection("users").document(userId).collection("brewRecords")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let docs = snap?.documents else { return }
                self?.records = docs.compactMap { doc in
                    try? doc.data(as: BrewRecord.self)
                }
            }
    }

    func addRecord(_ record: BrewRecord) {
        guard let userId = userId else { return }
        let doc = db.collection("users").document(userId).collection("brewRecords").document(record.id.uuidString)
        do {
            try doc.setData(from: record)
        } catch {
            print("❌ 保存 BrewRecord 失败: \(error)")
        }
    }

    func deleteRecord(_ record: BrewRecord) {
        guard let userId = userId else { return }
        db.collection("users").document(userId).collection("brewRecords").document(record.id.uuidString).delete { err in
            if let err = err {
                print("❌ 删除 BrewRecord 失败: \(err)")
            }
        }
    }

    deinit {
        listener?.remove()
    }
    
    // 获取指定咖啡豆的所有记录
    func getRecordsForCoffeeBean(_ coffeeBeanId: UUID) -> [BrewRecord] {
        return records.filter { $0.coffeeBean?.id == coffeeBeanId }
    }
    
    // 获取指定咖啡豆的最佳记录（评分最高的）
    func getBestRecordForCoffeeBean(_ coffeeBeanId: UUID) -> BrewRecord? {
        let beanRecords = getRecordsForCoffeeBean(coffeeBeanId)
        return beanRecords
            .filter { $0.rating != nil } // 只考虑有评分的记录
            .max { ($0.rating ?? 0) < ($1.rating ?? 0) }
    }
    
    // 获取指定咖啡豆的最佳参数
    func getBestParametersForCoffeeBean(_ coffeeBeanId: UUID) -> BestParameters? {
        guard let bestRecord = getBestRecordForCoffeeBean(coffeeBeanId) else {
            return nil
        }
        
        return BestParameters(
            coffeeWeight: bestRecord.coffeeWeight,
            waterTemperature: bestRecord.waterTemperature,
            grindSize: bestRecord.grindSize,
            preInfusionTime: bestRecord.preInfusionTime,
            extractionTime: bestRecord.extractionTime,
            yieldAmount: bestRecord.yieldAmount,
            ratio: bestRecord.ratio,
            rating: bestRecord.rating ?? 0,
            date: bestRecord.date
        )
    }
    
    // 获取指定咖啡豆的统计信息
    func getStatisticsForCoffeeBean(_ coffeeBeanId: UUID) -> CoffeeBeanStatistics? {
        let beanRecords = getRecordsForCoffeeBean(coffeeBeanId)
        let ratedRecords = beanRecords.filter { $0.rating != nil }
        
        guard !ratedRecords.isEmpty else {
            return nil
        }
        
        let totalRecords = beanRecords.count
        let averageRating = ratedRecords.reduce(0) { $0 + ($1.rating ?? 0) } / Double(ratedRecords.count)
        let bestRating = ratedRecords.map { $0.rating ?? 0 }.max() ?? 0
        let worstRating = ratedRecords.map { $0.rating ?? 0 }.min() ?? 0
        
        return CoffeeBeanStatistics(
            totalRecords: totalRecords,
            ratedRecords: ratedRecords.count,
            averageRating: averageRating,
            bestRating: bestRating,
            worstRating: worstRating
        )
    }
    
    // 获取所有咖啡豆的最佳评分概览
    func getAllCoffeeBeansBestRatings() -> [CoffeeBeanBestRating] {
        let uniqueBeanIds = Set(records.compactMap { $0.coffeeBean?.id })
        
        return uniqueBeanIds.compactMap { beanId in
            guard let bestRecord = getBestRecordForCoffeeBean(beanId),
                  let coffeeBean = bestRecord.coffeeBean else {
                return nil
            }
            
            return CoffeeBeanBestRating(
                coffeeBeanId: beanId,
                coffeeBeanName: coffeeBean.name,
                coffeeBeanBrand: coffeeBean.brand,
                coffeeBeanRoastLevel: coffeeBean.roastLevel,
                bestRating: bestRecord.rating ?? 0,
                bestParameters: getBestParametersForCoffeeBean(beanId),
                totalRecords: getRecordsForCoffeeBean(beanId).count
            )
        }.sorted { $0.bestRating > $1.bestRating } // 按最佳评分排序
    }
    
    // 测试方法：添加测试记录
    func addTestRecord() {
        // 创建测试咖啡豆引用
        let testBean1 = CoffeeBeanReference(
            id: UUID(), // 使用固定ID便于测试
            name: "埃塞俄比亚耶加雪菲",
            brand: "星巴克",
            roastLevel: "浅焙"
        )
        
        let testBean2 = CoffeeBeanReference(
            id: UUID(), // 使用固定ID便于测试
            name: "哥伦比亚圣图安",
            brand: "雀巢",
            roastLevel: "中焙"
        )
        
        // 添加多条测试记录，包含不同评分
        let testRecords = [
            BrewRecord(
                date: Date().addingTimeInterval(-86400), // 1天前
                coffeeBean: testBean1,
                coffeeWeight: "18",
                waterTemperature: 92,
                grindSize: 4.5,
                preInfusionTime: "30",
                extractionTime: "120",
                yieldAmount: "36",
                rating: 8.5,
                ratingDescription: "花香明显，酸度适中"
            ),
            BrewRecord(
                date: Date().addingTimeInterval(-172800), // 2天前
                coffeeBean: testBean1,
                coffeeWeight: "18",
                waterTemperature: 90,
                grindSize: 5.2,
                preInfusionTime: "25",
                extractionTime: "110",
                yieldAmount: "35",
                rating: 7.2,
                ratingDescription: "口感不错，但花香不够突出"
            ),
            BrewRecord(
                date: Date().addingTimeInterval(-259200), // 3天前
                coffeeBean: testBean2,
                coffeeWeight: "20",
                waterTemperature: 88,
                grindSize: 3.8,
                preInfusionTime: "35",
                extractionTime: "130",
                yieldAmount: "40",
                rating: 9.1,
                ratingDescription: "醇厚浓郁，完美萃取"
            ),
            BrewRecord(
                date: Date().addingTimeInterval(-345600), // 4天前
                coffeeBean: testBean2,
                coffeeWeight: "20",
                waterTemperature: 85,
                grindSize: 4.1,
                preInfusionTime: "30",
                extractionTime: "125",
                yieldAmount: "38",
                rating: 8.0,
                ratingDescription: "口感良好，但稍显平淡"
            )
        ]
        
        for record in testRecords {
            addRecord(record)
        }
    }
    
    // 测试方法：清空所有记录
    func clearAllRecords() {
        // 在 Firestore 中，删除用户文档下的所有记录
        guard let userId = userId else { return }
        db.collection("users").document(userId).collection("brewRecords").getDocuments { snap, err in
            if let err = err {
                print("❌ 清空 BrewRecords 失败: \(err)")
                return
            }
            snap?.documents.forEach { doc in
                doc.reference.delete()
            }
            print("✅ 已清空 BrewRecords (用户: \(userId))")
        }
    }
}

// 最佳参数结构体
struct BestParameters {
    let coffeeWeight: String
    let waterTemperature: Int
    let grindSize: Double
    let preInfusionTime: String
    let extractionTime: String
    let yieldAmount: String
    let ratio: String
    let rating: Double
    let date: Date
}

// 咖啡豆统计信息结构体
struct CoffeeBeanStatistics {
    let totalRecords: Int
    let ratedRecords: Int
    let averageRating: Double
    let bestRating: Double
    let worstRating: Double
}

// 咖啡豆最佳评分结构体
struct CoffeeBeanBestRating {
    let coffeeBeanId: UUID
    let coffeeBeanName: String
    let coffeeBeanBrand: String
    let coffeeBeanRoastLevel: String
    let bestRating: Double
    let bestParameters: BestParameters?
    let totalRecords: Int
} 
