import Foundation
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    
    init() {
        print("AuthManager 初始化")
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("认证状态变化，用户: \(user?.email ?? "nil")")
            self?.isLoggedIn = user != nil
        }
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