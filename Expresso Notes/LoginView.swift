import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering: Bool
    @State private var errorMessage = ""
    @State private var showVerificationAlert = false
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    init(isRegistering: Bool = false) {
        print("LoginView 初始化，模式：\(isRegistering ? "注册" : "登录")")
        _isRegistering = State(initialValue: isRegistering)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(isRegistering ? "注册" : "登录")
                    .font(.largeTitle)
                    .bold()
                
                TextField("邮箱", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .onChange(of: email) { newValue in
                        print("邮箱输入变化：\(newValue)")
                    }
                
                SecureField("密码", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: password) { newValue in
                        print("密码输入变化：\(newValue)")
                    }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    print("点击了\(isRegistering ? "注册" : "登录")按钮")
                    if isRegistering {
                        register()
                    } else {
                        login()
                    }
                }) {
                    Text(isRegistering ? "注册" : "登录")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    print("切换模式：\(isRegistering ? "注册" : "登录") -> \(!isRegistering ? "注册" : "登录")")
                    isRegistering.toggle()
                }) {
                    Text(isRegistering ? "已有账号？登录" : "没有账号？注册")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .navigationBarItems(leading: Button(action: {
                print("点击返回按钮")
                dismiss()
            }) {
                Text("返回")
                    .foregroundColor(.gray)
            })
            .alert("邮箱验证", isPresented: $showVerificationAlert) {
                Button("确定") {
                    dismiss()
                }
            } message: {
                Text("验证邮件已发送到您的邮箱，请查收并验证。")
            }
        }
    }
    
    private func login() {
        print("开始登录流程")
        print("尝试登录，邮箱：\(email)")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("登录失败：\(error.localizedDescription)")
                print("错误详情：\(error)")
                errorMessage = error.localizedDescription
            } else {
                if let user = Auth.auth().currentUser {
                    if !user.isEmailVerified {
                        errorMessage = "请先验证您的邮箱"
                        try? Auth.auth().signOut()
                    } else {
                        print("登录成功")
                        print("当前用户：\(user.email ?? "nil")")
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func register() {
        print("开始注册流程")
        print("尝试注册，邮箱：\(email)")
        
        // 验证邮箱格式
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "请输入有效的邮箱地址"
            return
        }
        
        // 验证密码长度
        guard password.count >= 6 else {
            errorMessage = "密码长度至少为6位"
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("注册失败：\(error.localizedDescription)")
                print("错误详情：\(error)")
                print("错误代码：\(error._code)")
                print("错误域：\(error._domain)")
                
                // 根据错误类型显示不同的错误信息
                switch error._code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    errorMessage = "该邮箱已被注册"
                case AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "邮箱格式不正确"
                case AuthErrorCode.weakPassword.rawValue:
                    errorMessage = "密码强度不够"
                default:
                    errorMessage = "注册失败：\(error.localizedDescription)"
                }
            } else if let user = result?.user {
                print("注册成功，发送验证邮件")
                
                // 发送验证邮件
                user.sendEmailVerification { error in
                    if let error = error {
                        print("发送验证邮件失败：\(error.localizedDescription)")
                        errorMessage = "发送验证邮件失败"
                    } else {
                        print("验证邮件已发送")
                        showVerificationAlert = true
                        
                        // 将用户信息存储到 Firestore
                        let db = Firestore.firestore()
                        let userData: [String: Any] = [
                            "email": email,
                            "createdAt": FieldValue.serverTimestamp(),
                            "isVerified": false
                        ]
                        
                        db.collection("users").document(user.uid).setData(userData) { error in
                            if let error = error {
                                print("存储用户数据失败：\(error.localizedDescription)")
                            } else {
                                print("用户数据存储成功")
                            }
                        }
                    }
                }
                
                // 登出用户，等待邮箱验证
                try? Auth.auth().signOut()
            }
        }
    }
} 