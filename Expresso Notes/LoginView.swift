import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering: Bool
    @State private var errorMessage = ""
    @State private var verificationMessage = ""
    @State private var showForgetPasswordAlert = false
    @State private var resetPasswordEmail = ""
    @State private var resetPasswordMessage = ""
    @State private var showCloseButton = false
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
            ZStack {
                // 添加透明背景，确保整个区域都能响应点击
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                // 忘记密码弹窗 - 设置最高层级
                if showForgetPasswordAlert {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                // 防止点击背景关闭
                            }
                        
                        VStack(spacing: 20) {
                            // 标题行，包含关闭按钮
                            HStack {
                                Spacer()
                                MixedFontText(content: "重置密码", fontSize: 20)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.theme.textColorForTitle)
                                Spacer()
                                
                                // 关闭按钮 - 只在发送成功后显示
                                if showCloseButton {
                                    Button(action: {
                                        print("用户点击关闭按钮")
                                        showForgetPasswordAlert = false
                                        resetPasswordMessage = ""
                                        showCloseButton = false
                                    }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color(UIColor.systemGray))
                                            .frame(width: 24, height: 24)
                                            .background(Color(UIColor.systemGray6))
                                            .clipShape(Circle())
                                    }
                                } else {
                                    // 占位，保持布局一致
                                    Color.clear
                                        .frame(width: 24, height: 24)
                                }
                            }
                            
                            Text("请输入您的邮箱地址，我们将发送重置密码的链接")
                                .font(.system(size: 14))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.theme.textColor)
                            
                            // 邮箱输入框
                            TextField("请输入邮箱", text: $resetPasswordEmail)
                                .font(.system(size: 14))
                                .padding(12)
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            // 结果消息显示
                            if !resetPasswordMessage.isEmpty {
                                Text(resetPasswordMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(resetPasswordMessage.contains("发送成功") ? .green : .red)
                                    .multilineTextAlignment(.center)
                            }
                            
                            HStack(spacing: 15) {
                                Button(action: {
                                    print("取消重置密码")
                                    showForgetPasswordAlert = false
                                    resetPasswordMessage = ""
                                    showCloseButton = false
                                }) {
                                    MixedFontText(content: "取消", fontSize: 16)
                                        .foregroundColor(Color.theme.textColor)
                                        .padding(.horizontal, 25)
                                        .padding(.vertical, 12)
                                        .background(Color(UIColor.systemGray5))
                                        .cornerRadius(25)
                                }
                                
                                Button(action: {
                                    print("发送重置密码邮件")
                                    sendPasswordResetEmail()
                                }) {
                                    MixedFontText(content: "发送", fontSize: 16)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 25)
                                        .padding(.vertical, 12)
                                        .background(resetPasswordEmail.isEmpty ? Color.theme.disableColor : Color.theme.buttonColor)
                                        .cornerRadius(25)
                                }
                                .disabled(resetPasswordEmail.isEmpty)
                                .opacity(resetPasswordEmail.isEmpty ? 0.3 : 1.0)
                            }
                        }
                        .padding(30)
                        .background(Color(red: 1, green: 1, blue: 1))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.horizontal, 40)
                    }
                    .zIndex(1000) // 设置最高层级
                    .transition(.scale.combined(with: .opacity))
                }

                
                VStack(spacing: 30) {
                // Logo图片
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .padding(.top, 40)
                
                // 模式标题 - 保持固定高度，确保位置一致
                VStack(spacing: 8) {
                    if isRegistering {
                        MixedFontText(content: "创建新账户", fontSize: 24)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.textColorForTitle)
                    }
                }
                .frame(height: 40) // 固定高度，保持位置一致
                .animation(.easeInOut(duration: 0.3), value: isRegistering)
                
                VStack(spacing: 20) {
                    // 验证邮件提示信息（只显示验证邮件提示，不显示错误信息）
                    if !verificationMessage.isEmpty {
                        Text(verificationMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 5)
                    }
                    
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
                        if !isRegistering {
                            Button(action: {
                                print("切换到注册模式")
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isRegistering = true
                                }
                                errorMessage = "" // 清空错误信息
                                verificationMessage = "" // 清空验证提示
                            }) {
                                HStack(spacing: 4) {
                                    Text("还没有账户？")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(UIColor.systemGray))
                                    Text("注册")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.theme.textColor)
                                }
                            }
                        } else {
                            Button(action: {
                                print("切换到登录模式")
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isRegistering = false
                                }
                                errorMessage = "" // 清空错误信息
                                verificationMessage = "" // 清空验证提示
                            }) {
                                HStack(spacing: 4) {
                                    Text("已有账户？")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(UIColor.systemGray))
                                    Text("登录")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.theme.textColor)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if !isRegistering {
                            Button(action: {
                                print("点击忘记密码")
                                resetPasswordEmail = email // 预填充当前输入的邮箱
                                resetPasswordMessage = "" // 清空之前的消息
                                showCloseButton = false // 重置关闭按钮状态
                                showForgetPasswordAlert = true
                            }) {
                                Text("忘记密码")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(UIColor.systemGray))
                            }
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
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 14)
                        .background(isFormValid ? Color.theme.buttonColor : Color.theme.disableColor)
                        .cornerRadius(25)
                        .animation(.easeInOut(duration: 0.3), value: isRegistering)
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
                .ignoresSafeArea(.keyboard, edges: .bottom) // 忽略键盘对界面的影响
            }
            .navigationBarTitleDisplayMode(.inline)

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
        print("🔥 开始注册流程")
        print("📧 尝试注册，邮箱：\(email)")
        print("🔐 密码长度：\(password.count)")
        
        // 设置注册状态，防止跳转到主界面
        authManager.isRegistering = true
        print("🚫 设置注册状态，阻止界面跳转")
        
        // 清空之前的错误信息和验证提示
        errorMessage = ""
        verificationMessage = ""
        
        // 验证邮箱格式
        guard email.contains("@") && email.contains(".") else {
            print("❌ 邮箱格式验证失败")
            authManager.isRegistering = false
            errorMessage = "请输入有效的邮箱地址"
            return
        }
        print("✅ 邮箱格式验证通过")
        
        // 验证密码长度
        guard password.count >= 6 else {
            print("❌ 密码长度验证失败")
            authManager.isRegistering = false
            errorMessage = "密码长度至少为6位"
            return
        }
        print("✅ 密码长度验证通过")
        
        print("🚀 开始调用Firebase创建用户...")
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ 注册失败：\(error.localizedDescription)")
                print("🔍 错误详情：\(error)")
                print("🔢 错误代码：\(error._code)")
                print("🏷️ 错误域：\(error._domain)")
                
                // 使用Firebase错误码翻译显示中文错误信息
                DispatchQueue.main.async {
                    self.authManager.isRegistering = false
                    self.errorMessage = self.translateFirebaseError(error)
                }
            } else if let user = result?.user {
                print("✅ 用户创建成功，用户ID：\(user.uid)")
                print("📧 开始发送验证邮件...")
                
                // 立即登出用户，防止跳转到主界面
                print("🚪 立即登出用户，防止跳转到主界面")
                try? Auth.auth().signOut()
                
                // 发送验证邮件
                user.sendEmailVerification { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("❌ 发送验证邮件失败：\(error.localizedDescription)")
                            self.authManager.isRegistering = false
                            self.errorMessage = "发送验证邮件失败"
                        } else {
                            print("✅ 验证邮件发送成功！")
                            print("📱 设置验证邮件提示信息")
                            
                            // 重置注册状态
                            self.authManager.isRegistering = false
                            
                            // 设置验证邮件发送成功提示
                            self.verificationMessage = "验证邮件已发送，请查看邮箱"
                            
                            // 切换回登录模式
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.isRegistering = false
                            }
                        
                            // 将用户信息存储到 Firestore
                            let db = Firestore.firestore()
                            let userData: [String: Any] = [
                                "email": self.email,
                                "createdAt": FieldValue.serverTimestamp(),
                                "isVerified": false
                            ]
                            
                            db.collection("users").document(user.uid).setData(userData) { error in
                                if let error = error {
                                    print("❌ 存储用户数据失败：\(error.localizedDescription)")
                                } else {
                                    print("✅ 用户数据存储成功")
                                }
                            }
                        }
                    }
                }
            } else {
                print("⚠️ 未知错误：result 和 error 都为 nil")
                DispatchQueue.main.async {
                    self.authManager.isRegistering = false
                    self.errorMessage = "注册失败，请重试"
                }
            }
        }
    }
    
    // 发送重置密码邮件
    private func sendPasswordResetEmail() {
        print("🔄 开始发送重置密码邮件")
        print("📧 目标邮箱：\(resetPasswordEmail)")
        
        // 验证邮箱格式
        guard resetPasswordEmail.contains("@") && resetPasswordEmail.contains(".") else {
            print("❌ 邮箱格式验证失败")
            resetPasswordMessage = "请输入有效的邮箱地址"
            return
        }
        
        // 清空之前的消息
        resetPasswordMessage = ""
        
        Auth.auth().sendPasswordReset(withEmail: resetPasswordEmail) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ 发送重置密码邮件失败：\(error.localizedDescription)")
                    print("🔍 错误详情：\(error)")
                    
                    // 处理常见错误
                    let nsError = error as NSError
                    if let errCode = AuthErrorCode(rawValue: nsError.code) {
                        switch errCode {
                        case .userNotFound:
                            self.resetPasswordMessage = "该邮箱尚未注册"
                        case .invalidEmail:
                            self.resetPasswordMessage = "邮箱格式错误"
                        case .tooManyRequests:
                            self.resetPasswordMessage = "请求过于频繁，请稍后再试"
                        case .networkError:
                            self.resetPasswordMessage = "网络错误，请检查网络连接"
                        default:
                            self.resetPasswordMessage = "发送失败，请稍后重试"
                        }
                    } else {
                        self.resetPasswordMessage = "发送失败，请稍后重试"
                    }
                } else {
                    print("✅ 重置密码邮件发送成功")
                    self.resetPasswordMessage = "重置密码邮件发送成功"
                    
                    // 显示关闭按钮，让用户手动关闭
                    self.showCloseButton = true
                }
            }
        }
    }
} 
