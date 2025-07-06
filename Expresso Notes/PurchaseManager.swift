import Foundation
import StoreKit
import Combine
import FirebaseAuth

@MainActor
class PurchaseManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isUnlocked = false
    @Published var freeUsageCount = 0
    @Published var canCreateNewRecord = true
    @Published var products: [Product] = []
    @Published var purchaseStatus: PurchaseStatus = .idle
    
    // MARK: - Constants
    private let maxFreeUsage = 3
    private let productID = "com.twinplanet.ExpressoNotes.unlock"
    
    // 获取当前用户的保存key
    private var freeUsageKey: String {
        let userId = Auth.auth().currentUser?.uid ?? "anonymous"
        return "freeUsageCount_\(userId)"
    }
    
    private var unlockStatusKey: String {
        let userId = Auth.auth().currentUser?.uid ?? "anonymous"
        return "isUnlocked_\(userId)"
    }
    
    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    
    enum PurchaseStatus {
        case idle
        case loading
        case purchasing
        case purchased
        case failed(Error)
        case restored
    }
    
    override init() {
        super.init()
        loadStoredData()
        startListeningForTransactions()
        Task {
            await loadProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// 当用户切换时重新加载数据
    func reloadForCurrentUser() {
        loadStoredData()
    }
    
    /// 检查是否可以创建新记录
    func checkCanCreateRecord() {
        if isUnlocked {
            canCreateNewRecord = true
        } else {
            canCreateNewRecord = freeUsageCount < maxFreeUsage
        }
    }
    
    /// 使用一次免费机会
    func useFreeAttempt() {
        guard !isUnlocked && freeUsageCount < maxFreeUsage else { return }
        
        freeUsageCount += 1
        saveStoredData()
        checkCanCreateRecord()
        
        print("📱 使用免费机会: \(freeUsageCount)/\(maxFreeUsage) (用户: \(Auth.auth().currentUser?.uid ?? "anonymous"))")
    }
    
    /// 获取剩余免费次数
    func remainingFreeUsage() -> Int {
        return max(0, maxFreeUsage - freeUsageCount)
    }
    
    /// 购买完整版
    func purchaseUnlock() async {
        guard let product = products.first(where: { $0.id == productID }) else {
            purchaseStatus = .failed(PurchaseError.productNotFound)
            return
        }
        
        purchaseStatus = .purchasing
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                
                isUnlocked = true
                purchaseStatus = .purchased
                saveStoredData()
                checkCanCreateRecord()
                
                print("✅ 购买成功！")
                
            case .userCancelled:
                purchaseStatus = .idle
                print("❌ 用户取消购买")
                
            case .pending:
                purchaseStatus = .idle
                print("⏳ 购买等待中...")
                
            @unknown default:
                purchaseStatus = .failed(PurchaseError.unknown)
            }
            
        } catch {
            purchaseStatus = .failed(error)
            print("❌ 购买失败: \(error)")
        }
    }
    
    /// 恢复购买
    func restorePurchases() async {
        purchaseStatus = .loading
        
        do {
            try await AppStore.sync()
            
            for await result in Transaction.currentEntitlements {
                let transaction = try checkVerified(result)
                
                if transaction.productID == productID {
                    isUnlocked = true
                    purchaseStatus = .restored
                    saveStoredData()
                    checkCanCreateRecord()
                    print("✅ 恢复购买成功！")
                    return
                }
            }
            
            purchaseStatus = .idle
            print("⚠️ 没有找到可恢复的购买记录")
            
        } catch {
            purchaseStatus = .failed(error)
            print("❌ 恢复购买失败: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadProducts() async {
        purchaseStatus = .loading
        
        do {
            let storeProducts = try await Product.products(for: [productID])
            products = storeProducts
            purchaseStatus = .idle
            print("✅ 产品加载成功: \(storeProducts.count) 个产品")
        } catch {
            purchaseStatus = .failed(error)
            print("❌ 产品加载失败: \(error)")
        }
    }
    
    private func startListeningForTransactions() {
        updateListenerTask = Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    
                    if transaction.productID == productID {
                        isUnlocked = true
                        saveStoredData()
                        checkCanCreateRecord()
                    }
                    
                    await transaction.finish()
                } catch {
                    print("❌ 交易验证失败: \(error)")
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func loadStoredData() {
        let defaults = UserDefaults.standard
        freeUsageCount = defaults.integer(forKey: freeUsageKey)
        isUnlocked = defaults.bool(forKey: unlockStatusKey)
        checkCanCreateRecord()
        
        print("📱 加载存储数据 - 免费次数: \(freeUsageCount), 已解锁: \(isUnlocked) (用户: \(Auth.auth().currentUser?.uid ?? "anonymous"))")
    }
    
    private func saveStoredData() {
        let defaults = UserDefaults.standard
        defaults.set(freeUsageCount, forKey: freeUsageKey)
        defaults.set(isUnlocked, forKey: unlockStatusKey)
        
        print("💾 保存数据 - 免费次数: \(freeUsageCount), 已解锁: \(isUnlocked) (用户: \(Auth.auth().currentUser?.uid ?? "anonymous"))")
    }
}

// MARK: - Custom Errors

enum PurchaseError: LocalizedError {
    case productNotFound
    case failedVerification
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "产品未找到"
        case .failedVerification:
            return "购买验证失败"
        case .unknown:
            return "未知错误"
        }
    }
} 