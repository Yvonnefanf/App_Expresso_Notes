import Foundation
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var username: String = ""
    @Published var email: String = ""
    
    init() {
        print("AuthManager 初始化")
        loadUserData()
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("认证状态变化，用户: \(user?.email ?? "nil")")
            self?.isLoggedIn = user != nil
            
            if let user = user {
                self?.email = user.email ?? ""
                // 如果没有设置用户名，生成默认用户名
                if self?.username.isEmpty == true {
                    self?.generateDefaultUsername(from: user.email ?? "")
                }
            } else {
                self?.email = ""
                self?.username = ""
            }
        }
    }
    
    private func loadUserData() {
        if let savedName = UserDefaults.standard.string(forKey: "username") {
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
        UserDefaults.standard.set(newName, forKey: "username")
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
} 