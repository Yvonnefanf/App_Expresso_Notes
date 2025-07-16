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
    @State private var isLoading = false
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
                            }
                    }
                    // 注册和忘记密码链接 - 紧贴密码输入框，无间隙
                    HStack {
                        if !isRegistering {
                            Button(action: {
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
                    print("按钮被点击，isFormValid: \(isFormValid)")
                    print("邮箱: '\(email)', 密码: '\(password)'")
                    
                    // 检查表单是否有效
                    if !isFormValid {
                        print("表单无效，显示错误信息")
                        DispatchQueue.main.async {
                            self.errorMessage = "请输入完整的邮箱和密码"
                        }
                        return
                    }
                    
                    print("表单有效，开始登录/注册")
                    // 清空之前的错误信息
                    DispatchQueue.main.async {
                        self.errorMessage = ""
                    }
                    
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
                .opacity(isFormValid && !isLoading ? 1.0 : 0.6)
                .padding(.top, 30)
                
                // 错误信息 - 固定位置
                Text(errorMessage.isEmpty ? " " : errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .frame(minHeight: 20)
                    .animation(.easeInOut(duration: 0.2), value: errorMessage)
                
                Spacer()
                }
                .padding()
                .ignoresSafeArea(.keyboard, edges: .bottom) // 忽略键盘对界面的影响
                
                // Loading 覆盖层
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // 防止点击背景关闭
                        }
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.buttonColor))
                            .scaleEffect(1.5)
                        
                        Text("请稍候...")
                            .font(.system(size: 16))
                            .foregroundColor(Color.theme.textColor)
                    }
                    .padding(30)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)

        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onDisappear {
            // 界面消失时重置loading状态
            isLoading = false
        }
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
                // 对于invalidCredential，我们需要进一步检查是否是邮箱不存在
                // Firebase在邮箱不存在时通常不会直接返回userNotFound，而是invalidCredential
                return "该邮箱未注册"
            case .operationNotAllowed:
                return "该操作不被允许"
            default:
                print("未处理的错误码：\(errCode)")
                return "操作失败，请重试"
            }
        } else {
            print("无法识别的错误码：\(nsError.code)")
            return "操作失败，请重试"
        }
    }
    
    // 专门处理注册错误的函数
    private func getLoginErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        if let errCode = AuthErrorCode(rawValue: nsError.code) {
            switch errCode {
            case .invalidEmail:
                return "邮箱格式错误"
            case .userDisabled:
                return "该账户已被禁用"
            case .userNotFound:
                return "该邮箱未注册"
            case .wrongPassword:
                return "密码错误"
            case .tooManyRequests:
                return "尝试次数过多，请稍后再试"
            case .networkError:
                return "网络错误，请检查网络连接"
            case .invalidCredential:
                // 对于invalidCredential，需要进一步判断
                // 检查错误信息中是否包含特定关键词来区分
                let errorDescription = nsError.localizedDescription.lowercased()
                print("错误描述：\(errorDescription)")
                
                // 如果错误信息包含"malformed"或"expired"，通常是凭据格式问题
                if errorDescription.contains("malformed") || errorDescription.contains("expired") {
                    return "密码错误"
                }
                
                // 检查是否包含"user"和"not"或"found"等关键词，表示用户不存在
                if errorDescription.contains("user") && (errorDescription.contains("not") || errorDescription.contains("found")) {
                    return "该邮箱未注册"
                }
                
                // 检查是否包含"password"、"wrong"、"incorrect"等关键词，表示密码错误
                if errorDescription.contains("password") || errorDescription.contains("wrong") || errorDescription.contains("incorrect") {
                    return "密码错误"
                }
                
                // 检查是否包含"email"、"invalid"等关键词，表示邮箱格式问题
                if errorDescription.contains("email") && errorDescription.contains("invalid") {
                    return "邮箱格式错误"
                }
                
                // 默认情况下，invalidCredential通常表示邮箱不存在
                return "该邮箱未注册"
            case .operationNotAllowed:
                return "该操作不被允许"
            default:
                print("未处理的登录错误码：\(errCode)")
                return "登录失败，请重试"
            }
        } else {
            print("无法识别的登录错误码：\(nsError.code)")
            return "登录失败，请重试"
        }
    }
    
    // 检查邮箱是否已注册（主要用于注册场景）
    private func checkEmailExists(completion: @escaping (Bool) -> Void) {
        print("开始检查邮箱存在性：\(email)")
        
        // 验证邮箱格式
        guard email.contains("@") && email.contains(".") else {
            print("邮箱格式无效")
            completion(false)
            return
        }
        
        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
            if let error = error {
                print("检查邮箱存在性时出错：\(error)")
                // 如果检查失败，假设邮箱不存在
                completion(false)
                return
            }
            
            print("fetchSignInMethods 返回的 signInMethods：\(signInMethods ?? [])")
            
            // 如果signInMethods不为空，说明邮箱已注册
            let emailExists = !(signInMethods?.isEmpty ?? true)
            print("邮箱 \(self.email) 存在性检查结果：\(emailExists)")
            
            completion(emailExists)
        }
    }
    
    private func login() {
        isLoading = true

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    let nsError = error as NSError
                    print("错误码：\(nsError.code)")
                    print("错误信息：\(nsError.localizedDescription)")

                    if let errCode = AuthErrorCode(rawValue: nsError.code) {
                        switch errCode {
                        case .userNotFound:
                            self.errorMessage = "该邮箱未注册"
                        case .wrongPassword:
                            self.errorMessage = "邮箱或密码错误"
                        case .invalidEmail:
                            self.errorMessage = "邮箱格式错误"
                        case .userDisabled:
                            self.errorMessage = "该账户已被禁用"
                        case .tooManyRequests:
                            self.errorMessage = "尝试次数过多，请稍后再试"
                        case .networkError:
                            self.errorMessage = "网络错误，请检查网络连接"
                        case .invalidCredential:
                            // 对于invalidCredential，进一步分析错误描述
                            let errorDescription = nsError.localizedDescription.lowercased()
                            print("错误描述：\(errorDescription)")
                            
                            // 检查是否包含用户不存在的关键词
                            if errorDescription.contains("user") && (errorDescription.contains("not") || errorDescription.contains("found")) {
                                self.errorMessage = "该邮箱未注册"
                            } else {
                                // 默认情况下，invalidCredential通常表示密码错误
                                self.errorMessage = "邮箱或密码错误"
                            }
                        default:
                            self.errorMessage = "登录失败，请重试"
                        }
                    } else {
                        self.errorMessage = "登录失败，请重试"
                    }

                    return
                }

                // ✅ 登录成功逻辑
                if let user = Auth.auth().currentUser {
                    if !user.isEmailVerified {
                        self.errorMessage = "请先验证您的邮箱"
                        try? Auth.auth().signOut()
                    } else {
                        print("登录成功")
                        print("当前用户：\(user.email ?? "nil")")
                        self.dismiss()
                    }
                }
            }
        }
    }
    
    private func register() {
       
        authManager.isRegistering = true
        isLoading = true
        
        // 清空之前的错误信息和验证提示
        errorMessage = ""
        verificationMessage = ""
        
        // 验证邮箱格式
        guard email.contains("@") && email.contains(".") else {
            
            authManager.isRegistering = false
            isLoading = false
            errorMessage = "请输入有效的邮箱地址"
            return
        }
      
        
        // 验证密码长度
        guard password.count >= 6 else {
           
            authManager.isRegistering = false
            isLoading = false
            errorMessage = "密码长度至少为6位"
            return
        }
        
        
      
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
         
                
                // 使用Firebase错误码翻译显示中文错误信息
                DispatchQueue.main.async {
                    self.authManager.isRegistering = false
                    self.isLoading = false
                    self.errorMessage = self.translateFirebaseError(error)
                }
            } else if let user = result?.user {
             
                try? Auth.auth().signOut()
                
                // 发送验证邮件
                user.sendEmailVerification { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            
                            self.authManager.isRegistering = false
                            self.isLoading = false
                            self.errorMessage = "发送验证邮件失败"
                        } else {
                        
                            
                            // 重置注册状态
                            self.authManager.isRegistering = false
                            self.isLoading = false
                            
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
                    self.isLoading = false
                    self.errorMessage = "注册失败，请重试"
                }
            }
        }
    }
    
    // 发送重置密码邮件
    private func sendPasswordResetEmail() {
       
        
        // 验证邮箱格式
        guard resetPasswordEmail.contains("@") && resetPasswordEmail.contains(".") else {
            resetPasswordMessage = "请输入有效的邮箱地址"
            return
        }
        
        // 清空之前的消息
        resetPasswordMessage = ""
        
        Auth.auth().sendPasswordReset(withEmail: resetPasswordEmail) { error in
            DispatchQueue.main.async {
                if let error = error {
                  
                    
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
                    
                    self.resetPasswordMessage = "重置密码邮件发送成功"
                    
                    // 显示关闭按钮，让用户手动关闭
                    self.showCloseButton = true
                }
            }
        }
    }
} 
