import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var isFirstLogin = false
    
    // 注册过程中的标志，用于避免跳转到主界面
    var isRegistering = false
    
    // 数据管理器引用
    weak var brewRecordStore: BrewRecordStore?
    weak var beanManager: CoffeeBeanManager?
    weak var purchaseManager: PurchaseManager?
    
    private var userListener: ListenerRegistration?
    
    init() {
        print("AuthManager 初始化")
        loadUserData()
        setupAuthListener()
    }
    
    // 设置数据管理器引用
    func setDataManagers(brewRecordStore: BrewRecordStore, beanManager: CoffeeBeanManager, purchaseManager: PurchaseManager) {
        self.brewRecordStore = brewRecordStore
        self.beanManager = beanManager
        self.purchaseManager = purchaseManager
    }
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("认证状态变化，用户: \(user?.email ?? "nil")")
            print("当前注册状态: \(self?.isRegistering ?? false)")
            
            // 如果正在注册过程中，忽略状态变化避免跳转
            if self?.isRegistering == true {
                print("正在注册中，忽略此次状态变化")
                return
            }
            
            self?.isLoggedIn = user != nil
            
            if let user = user {
                self?.email = user.email ?? ""
                self?.checkFirstLogin(userId: user.uid)
                self?.startUserListener() // 实时监听 Firestore 用户名
                self?.reloadDataForCurrentUser()
            } else {
                self?.email = ""
                self?.username = ""
                self?.isFirstLogin = false
                self?.userListener?.remove() // 登出时移除监听
                self?.reloadDataForCurrentUser()
            }
        }
    }
    
    // 重新加载当前用户的数据
    private func reloadDataForCurrentUser() {
        DispatchQueue.main.async {
            // self.brewRecordStore?.reloadForCurrentUser() // 已废弃，移除
            self.beanManager?.reloadForCurrentUser()
            self.purchaseManager?.reloadForCurrentUser()
        }
    }
    
    private func loadUserData() {
        let userId = Auth.auth().currentUser?.uid ?? "anonymous"
        let userKey = "username_\(userId)"
        if let savedName = UserDefaults.standard.string(forKey: userKey) {
            username = savedName
        }
    }
    
    private func generateDefaultUsername(from email: String) {
        if email.isEmpty { return }
        
        // 从邮箱生成默认用户名
        let emailPrefix = email.components(separatedBy: "@").first ?? ""
        let cleanPrefix = emailPrefix.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "", options: .regularExpression)
        
        if !cleanPrefix.isEmpty {
            let defaultName = cleanPrefix.prefix(1).uppercased() + cleanPrefix.dropFirst()
            updateUsername(String(defaultName))
        } else {
            updateUsername("用户")
        }
    }
    
    func updateUsername(_ newName: String) {
        username = newName
        let userId = Auth.auth().currentUser?.uid ?? "anonymous"
        let userKey = "username_\(userId)"
        UserDefaults.standard.set(newName, forKey: userKey)
    }
    
    func signOut() {
        print("尝试登出")
        do {
            try Auth.auth().signOut()
            print("登出成功")
        } catch {
            print("登出失败：\(error.localizedDescription)")
        }
    }
    
    // 检查是否是首次登录
    private func checkFirstLogin(userId: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    // 用户数据存在，获取用户信息
                    let data = document.data()
                    let hasCompletedSetup = data?["hasCompletedSetup"] as? Bool ?? false
                    let savedUsername = data?["username"] as? String ?? ""
                    
                    self?.username = savedUsername
                    self?.isFirstLogin = !hasCompletedSetup
                    
                    // 如果没有设置用户名，生成默认用户名
                    if self?.username.isEmpty == true {
                        self?.generateDefaultUsername(from: self?.email ?? "")
                    }
                    
                    print("用户数据存在，hasCompletedSetup: \(hasCompletedSetup)")
                } else {
                    // 用户数据不存在或出错，视为首次登录
                    print("用户数据不存在，视为首次登录")
                    self?.isFirstLogin = true
                    // 生成默认用户名
                    self?.generateDefaultUsername(from: self?.email ?? "")
                }
            }
        }
    }
    
    // Firestore 用户名实时监听
    func startUserListener() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        userListener?.remove() // 移除旧监听
        let db = Firestore.firestore()
        userListener = db.collection("users").document(userId).addSnapshotListener { [weak self] snapshot, error in
            guard let data = snapshot?.data() else { return }
            let cloudUsername = data["username"] as? String ?? ""
            DispatchQueue.main.async {
                self?.username = cloudUsername
            }
        }
    }
    
    // 保存首次设置信息
    func saveFirstTimeSetup(username: String, coffeeMachine: String, grinder: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ 无法获取用户ID")
            return
        }
        
        print("💾 保存首次设置信息...")
        print("📝 用户名: \(username)")
        print("☕ 咖啡机: \(coffeeMachine)")
        print("⚙️ 磨豆机: \(grinder)")
        
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "email": self.email,
            "username": username,
            "coffeeMachine": coffeeMachine,
            "grinder": grinder,
            "hasCompletedSetup": true,
            "setupCompletedAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(userId).setData(userData, merge: true) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ 保存首次设置失败：\(error.localizedDescription)")
                } else {
                    print("✅ 首次设置保存成功")
                    // 更新本地状态
                    self?.username = username
                    self?.isFirstLogin = false
                    // 保存用户名到UserDefaults
                    self?.updateUsername(username)
                }
            }
        }
    }
} 
