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
    
    // 检查表单是否有效
    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo图片
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .padding(.top, 40)
                
                VStack(spacing: 20) {
                    // 邮箱输入框
                    VStack(alignment: .leading, spacing: 8) {
                        MixedFontText(content: "账号邮箱", fontSize: 16)
                            .foregroundColor(Color.theme.textColor)
                        
                        TextField("请输入邮箱", text: $email)
//                            .font(.custom("平方江南体", size: 12))
                            .font(.system(size: 12))
                            .padding(12)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: email) { newValue in
                                print("邮箱输入变化：\(newValue)")
                            }
                    }
                    
                    // 密码输入框
                    VStack(alignment: .leading, spacing: 8) {
                        MixedFontText(content: "输入密码", fontSize: 16)
                            .foregroundColor(Color.theme.textColor)
                        
                        SecureField("请输入密码", text: $password)
//                            .font(.custom("平方江南体", size: 12))
                            .font(.system(size: 12))
                            .padding(12)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: password) { newValue in
                                print("密码输入变化：\(newValue)")
                            }
                    }
                    // 注册和忘记密码链接 - 紧贴密码输入框，无间隙
                    HStack {
                        Button(action: {
                            print("切换到注册模式")
                            isRegistering.toggle()
                        }) {
                            Text("注册")
                                .font(.system(size: 12))
                                .foregroundColor(Color(UIColor.systemGray))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            print("忘记密码")
                            // TODO: 实现忘记密码功能
                        }) {
                            Text("忘记密码")
                                .font(.system(size: 12))
                                .foregroundColor(Color(UIColor.systemGray))
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                
                // 登录按钮 - 变短
                Button(action: {
                    print("点击了\(isRegistering ? "注册" : "登录")按钮")
                    if isRegistering {
                        register()
                    } else {
                        login()
                    }
                }) {
                    MixedFontText(content: isRegistering ? "注册" : "登录", fontSize: 18)
                        .foregroundColor(.white)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 14)
                        .background(isFormValid ? Color.theme.buttonColor : Color.theme.disableColor)
                        .cornerRadius(25)
                }
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.2)
                .padding(.top, 30)
                
                // 错误信息 - 固定位置
                Text(errorMessage.isEmpty ? " " : errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .frame(minHeight: 20)
                
                Spacer()
            }
            .padding()
            .onTapGesture {
                // 点击屏幕收起键盘
                hideKeyboard()
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("邮箱验证", isPresented: $showVerificationAlert) {
                Button("确定") {
                    dismiss()
                }
            } message: {
                Text("验证邮件已发送到您的邮箱，请查收并验证。")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // 隐藏键盘的函数
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // 根据Firebase错误码翻译错误信息为中文
    private func translateFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        if let errCode = AuthErrorCode(rawValue: nsError.code) {
            switch errCode {
            case .invalidEmail:
                return "邮箱格式错误"
            case .userDisabled:
                return "该账户已被禁用"
            case .userNotFound:
                return "用户不存在"
            case .wrongPassword:
                return "密码错误"
            case .tooManyRequests:
                return "尝试次数过多，请稍后再试"
            case .networkError:
                return "网络错误，请检查网络连接"
            case .emailAlreadyInUse:
                return "该邮箱已被注册"
            case .weakPassword:
                return "密码强度不够，至少需要6位"
            case .invalidCredential:
                return "该邮箱未注册"
            case .operationNotAllowed:
                return "该操作不被允许"
            default:
                return "操作失败，请重试"
            }
        } else {
            return "操作失败，请重试"
        }
    }
    
    private func login() {
        print("开始登录流程")
        print("尝试登录，邮箱：\(email)")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("登录失败：\(error.localizedDescription)")
                print("错误详情：\(error)")
                errorMessage = translateFirebaseError(error)
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
                
                // 使用Firebase错误码翻译显示中文错误信息
                errorMessage = translateFirebaseError(error)
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
