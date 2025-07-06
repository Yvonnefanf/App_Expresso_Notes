import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showLogoutAlert = false
    @State private var showSettingsSheet = false
    @State private var showProfileSheet = false
    @State private var showUpgradePopup = false
    // 设备参数
    @State private var coffeeMachine: String = ""
    @State private var grinder: String = ""
    @State private var isSavingDeviceSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.backgroundColor.ignoresSafeArea()
                VStack(spacing: 0) {
                    // 顶部 themeColor 背景
                    ZStack {
                        Color.theme.themeColor2
                            .clipShape(RoundedCorner(radius: 36, corners: [.bottomLeft, .bottomRight]))
                            .edgesIgnoringSafeArea(.top)
                        VStack(spacing: 10) {
                            Spacer().frame(height: 20)
                            ZStack {
                                // 头像
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color.theme.themeColor2))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color(red: 1, green: 1, blue: 1), lineWidth: 4)) // 强制白色边框
                            }
                            .frame(height: 120)
                            // 用户名和邮箱
                            VStack(spacing: 8) {
                                MixedFontText(content: authManager.username, fontSize: 22)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.theme.textColorForTitle)
                                MixedFontText(content: authManager.email, fontSize: 16)
                                    .foregroundColor(Color.theme.disableColor)
                            }
                        }
                    }
                    .frame(height: 240)
                    .padding(.bottom, 20)
                    // 菜单列表
                    ScrollView {
                        VStack(spacing: 0) {
                            menuItem(icon: "gearshape", label: "参数设置") {
                                showSettingsSheet = true
                            }
                            menuItem(icon: "person", label: "个人信息") {
                                showProfileSheet = true
                            }
                            
//                            menuItem(icon: "lock", label: "修改密码") {}
                            Divider().padding(.vertical, 8)
                            menuItem(icon: "questionmark.circle", label: "帮助与支持") {}
                            Button(action: { showLogoutAlert = true }) {
                                HStack {
                                    Image(systemName: "arrowshape.turn.up.left")
                                        .foregroundColor(Color.theme.iconColor)
                                    MixedFontText(content: "退出登录", fontSize: 17)
                                        .foregroundColor(Color.theme.textColor)
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 8)
                            }
                            
                            // 购买状态卡片
                            purchaseStatusCard
                        }
                        .background(Color.theme.backgroundColor)
                        .cornerRadius(16)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        Spacer()
                    }
                }
                .alert("确认登出", isPresented: $showLogoutAlert) {
                    Button("取消", role: .cancel) { }
                    Button("确认", role: .destructive) {
                        authManager.signOut()
                    }
                } message: {
                    Text("确定要退出登录吗？")
                }
                .sheet(isPresented: $showSettingsSheet) {
                    settingsSheet
                }
                .sheet(isPresented: $showProfileSheet) {
                    profileSheet
                }
                .sheet(isPresented: $showUpgradePopup) {
                    upgradeSheet
                }
            }
            .onAppear {
                loadDeviceSettings()
            }
            .navigationBarTitleDisplayMode(.inline) // 设置为中间小标题模式
            .navigationBarItems(
                leading: Button(action: {
                    // 发送通知切换到主页
                    NotificationCenter.default.post(name: .switchToTab, object: 0)
                }) {
                    Image(systemName: "chevron.backward")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20) // 👈 控制大小
                        .fontWeight(.bold)           // 👈 更粗（仅适用于某些系统图标）
                        .foregroundColor(Color.theme.iconColor)
                        .padding(.top, 16)
                }
            )
        }
    }
    
    // MARK: - Purchase Status Card
    @ViewBuilder
    var purchaseStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: purchaseManager.isUnlocked ? "checkmark.circle.fill" : "clock.circle")
                    .foregroundColor(purchaseManager.isUnlocked ? Color.theme.buttonColor : Color.theme.themeColor)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    MixedFontText(
                        content: purchaseManager.isUnlocked ? "完整版已解锁" : "免费版",
                        fontSize: 17
                    )
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.textColor)
                    
                    if !purchaseManager.isUnlocked {
                        MixedFontText(
                            content: "剩余 \(purchaseManager.remainingFreeUsage()) 次免费机会",
                            fontSize: 14
                        )
                        .foregroundColor(Color.theme.textColor.opacity(0.7))
                    } else {
                        MixedFontText(
                            content: "感谢您的支持！",
                            fontSize: 14
                        )
                        .foregroundColor(Color.theme.textColor.opacity(0.7))
                    }
                }
                
                Spacer()
                
                if !purchaseManager.isUnlocked {
                    Button(action: {
                        showUpgradePopup = true
                    }) {
                        MixedFontText(content: "升级", fontSize: 14)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.theme.buttonColor)
                            .cornerRadius(15)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(purchaseManager.isUnlocked ? Color.theme.buttonColor.opacity(0.05) : Color.theme.themeColor.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(purchaseManager.isUnlocked ? Color.theme.buttonColor.opacity(0.15) : Color.theme.themeColor.opacity(0.15), lineWidth: 1)
            )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }
    
    // MARK: - Menu Item
    @ViewBuilder
    func menuItem(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color.theme.iconColor)
                MixedFontText(content: label, fontSize: 17)
                    .foregroundColor(Color.theme.textColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.theme.iconColor)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
        }
    }
    
    // MARK: - 个人信息设置弹窗
    var profileSheet: some View {
        ProfileSettingsView()
            .environmentObject(authManager)
    }
    
    // MARK: - 升级弹窗
    var upgradeSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 标题区域
                VStack(spacing: 16) {
                    Image("nobgbean")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    
                    VStack(spacing: 8) {
                        Text("解锁完整版")
                            .font(.custom("Slideqiuhong", size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.textColor)
                        
                        Text("升级到完整版，享受永久记录")
                            .font(.custom("平方江南体", size: 16))
                            .foregroundColor(Color.theme.textColor.opacity(0.7))
                    }
                }
                .padding(.top, 20)
                
                // 当前状态
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "clock.circle")
                            .foregroundColor(Color.theme.themeColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            MixedFontText(content: "当前：免费版", fontSize: 17)
                                .fontWeight(.medium)
                                .foregroundColor(Color.theme.textColor)
                            
                            MixedFontText(content: "剩余 \(purchaseManager.remainingFreeUsage()) 次免费机会", fontSize: 14)
                                .foregroundColor(Color.theme.textColor.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.theme.themeColor.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.theme.themeColor.opacity(0.15), lineWidth: 1)
                    )
                }
                
                // 完整版特性
                VStack(alignment: .leading, spacing: 16) {
                    MixedFontText(content: "完整版内容", fontSize: 18)
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.textColor)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        featureRow(icon: "checkmark.circle.fill", title: "无限制创建萃取记录", description: " ")
                        featureRow(icon: "checkmark.circle.fill", title: "永久保存所有数据", description: " ")
                        featureRow(icon: "checkmark.circle.fill", title: "一次购买终身使用", description: " ")
                    }
                }
                
                Spacer()
                
                // 价格和购买按钮
                VStack(spacing: 16) {
                    if let product = purchaseManager.products.first {
                        VStack(spacing: 4) {
                            Text(product.displayPrice)
                                .font(.custom("umeboshi", size: 32))
                                .fontWeight(.bold)
                                .foregroundColor(Color.theme.textColor)
                            
                            Text("一次性购买")
                                .font(.custom("平方江南体", size: 14))
                                .foregroundColor(Color.theme.textColor.opacity(0.6))
                        }
                    }
                    
                    // 购买按钮
                    Button(action: {
                        Task {
                            await purchaseManager.purchaseUnlock()
                            if purchaseManager.isUnlocked {
                                showUpgradePopup = false
                            }
                        }
                    }) {
                        HStack {
                            if case .purchasing = purchaseManager.purchaseStatus {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            }
                                                         Text(purchaseButtonText)
                                .font(.custom("平方江南体", size: 18))
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.theme.buttonColor)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                    .disabled(isPurchasing)
                    
                    // 恢复购买
                    Button(action: {
                        Task {
                            await purchaseManager.restorePurchases()
                            if purchaseManager.isUnlocked {
                                showUpgradePopup = false
                            }
                        }
                    }) {
                        Text("恢复购买")
                            .font(.custom("平方江南体", size: 16))
                            .foregroundColor(Color.theme.textColor.opacity(0.7))
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showUpgradePopup = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.gray)
                    }
                }
            }
        }
    }
    
    // MARK: - 特性行组件
    @ViewBuilder
    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color.theme.buttonColor)
                .font(.system(size: 16))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                MixedFontText(content: title, fontSize: 15)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.textColor)
                
                MixedFontText(content: description, fontSize: 13)
                    .foregroundColor(Color.theme.textColor.opacity(0.6))
            }
            
            Spacer()
        }
    }
    
    // MARK: - 设备设置弹窗
    var settingsSheet: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // 咖啡机型号
                VStack(alignment: .leading, spacing: 8) {
                    MixedFontText(content: "咖啡机型号", fontSize: 16)
                        .foregroundColor(Color.theme.textColor)
                    TextField("输入咖啡机型号", text: $coffeeMachine)
                        .font(.custom("平方江南体", size: 16))
                        .padding(12)
                        .foregroundColor(Color.theme.textColor)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            print("🔘 点击咖啡机输入框，当前值: '\(coffeeMachine)'")
                        }
                }
                
                // 磨豆机型号
                VStack(alignment: .leading, spacing: 8) {
                    MixedFontText(content: "磨豆机型号", fontSize: 16)
                        .foregroundColor(Color.theme.textColor)
                    TextField("输入磨豆机型号", text: $grinder)
                        .font(.custom("平方江南体", size: 16))
                        .padding(12)
                        .foregroundColor(Color.theme.textColor)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onTapGesture {
                            print("🔘 点击磨豆机输入框，当前值: '\(grinder)'")
                        }
                }
                
                Spacer()
                
                // 保存按钮
                Button(action: {
                    print("🔘 点击保存按钮")
                    saveDeviceSettings()
                }) {
                    HStack {
                        if isSavingDeviceSettings {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                            MixedFontText(content: "保存中...", fontSize: 18)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        } else {
                            MixedFontText(content: "保存", fontSize: 18)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isSavingDeviceSettings ? Color.theme.disableColor : Color.theme.buttonColor)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .disabled(isSavingDeviceSettings)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("设备设置")
                        .font(.custom("Slideqiuhong", size: 30))
                        .fontWeight(.bold).foregroundColor(Color.theme.textColorForTitle)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    BackButton(action: {
                        showSettingsSheet = false
                    })
                }
            }
            .onAppear {
                loadDeviceSettings()
            }
        }
    }
    
    // MARK: - 计算属性
    private var isPurchasing: Bool {
        if case .purchasing = purchaseManager.purchaseStatus {
            return true
        } else {
            return false
        }
    }
    
    private var purchaseButtonText: String {
        if case .purchasing = purchaseManager.purchaseStatus {
            return "购买中..."
        } else {
            return "立即购买"
        }
    }
    
    // MARK: - 加载设备设置
    private func loadDeviceSettings() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ 无法获取用户ID")
            return
        }
        
        print("📱 加载设备设置...")
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    let data = document.data()
                    let loadedCoffeeMachine = (data?["coffeeMachine"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    let loadedGrinder = (data?["grinder"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    print("✅ 设备设置加载成功")
                    print("☕ 咖啡机原始数据: '\(data?["coffeeMachine"] as? String ?? "nil")'")
                    print("☕ 咖啡机处理后: '\(loadedCoffeeMachine)' (长度: \(loadedCoffeeMachine.count))")
                    print("⚙️ 磨豆机原始数据: '\(data?["grinder"] as? String ?? "nil")'")
                    print("⚙️ 磨豆机处理后: '\(loadedGrinder)' (长度: \(loadedGrinder.count))")
                    
                    // 明确更新UI状态
                    self.coffeeMachine = loadedCoffeeMachine
                    self.grinder = loadedGrinder
                    
                    print("🔄 UI状态更新完成")
                    print("☕ UI咖啡机: '\(self.coffeeMachine)'")
                    print("⚙️ UI磨豆机: '\(self.grinder)'")
                } else {
                    print("❌ 无法加载设备设置: \(error?.localizedDescription ?? "文档不存在")")
                    // 确保为空时UI也是空的
                    self.coffeeMachine = ""
                    self.grinder = ""
                }
            }
        }
    }
    
    // MARK: - 保存设备设置
    private func saveDeviceSettings() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ 无法获取用户ID")
            return
        }
        
        print("💾 保存设备设置...")
        print("☕ 咖啡机: '\(coffeeMachine)'")
        print("⚙️ 磨豆机: '\(grinder)'")
        
        // 设置保存中状态
        isSavingDeviceSettings = true
        
        let db = Firestore.firestore()
        let deviceData: [String: Any] = [
            "coffeeMachine": coffeeMachine.trimmingCharacters(in: .whitespacesAndNewlines),
            "grinder": grinder.trimmingCharacters(in: .whitespacesAndNewlines),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        print("📤 开始上传数据...")
        
        db.collection("users").document(userId).setData(deviceData, merge: true) { error in
            DispatchQueue.main.async {
                // 重置保存状态
                self.isSavingDeviceSettings = false
                
                if let error = error {
                    print("❌ 保存设备设置失败：\(error.localizedDescription)")
                    // TODO: 可以添加错误弹窗提示用户
                } else {
                    print("✅ 设备设置保存成功")
                    print("🚪 关闭设备设置弹窗")
                    // 关闭弹窗
                    self.showSettingsSheet = false
                }
            }
        }
    }
}

// MARK: - 个人信息设置视图
struct ProfileSettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var tempUsername: String = ""
    @State private var showSaveAlert = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // 用户名设置
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        MixedFontText(content: "用户名", fontSize: 18)
                            .foregroundColor(Color.theme.textColor)
                        MixedFontText(content: "*", fontSize: 18)
                            .foregroundColor(.red)
                    }
                    
                    ZStack(alignment: .leading) {
                        if tempUsername.isEmpty {
                            Text("请输入用户名")
                                .font(.custom("平方江南体", size: 16))
                                .foregroundColor(Color.theme.disableColor.opacity(0.7))
                                .padding(.leading, 12)
                        }
                        
                        TextField("", text: $tempUsername)
                            .font(.custom("平方江南体", size: 16))
                            .padding(12)
                            .foregroundColor(Color.theme.textColor)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2))
                            )
                    }
                }
                
                // 邮箱显示（只读）
                VStack(alignment: .leading, spacing: 8) {
                    MixedFontText(content: "邮箱", fontSize: 18)
                        .foregroundColor(Color.theme.textColor)
                    
                    HStack {
                        MixedFontText(content: authManager.email, fontSize: 16)
                            .foregroundColor(Color.theme.disableColor)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.theme.disableColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                
                // 保存按钮
                Button(action: {
                    if !tempUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        authManager.updateUsername(tempUsername.trimmingCharacters(in: .whitespacesAndNewlines))
                        showSaveAlert = true
                    }
                }) {
                    MixedFontText(content: "保存", fontSize: 18)
                        .foregroundColor(Color.theme.textColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.theme.buttonColor)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .disabled(tempUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    
                    Text("个人信息")
                        .font(.custom("Slideqiuhong", size: 30))
                        .fontWeight(.bold).foregroundColor(Color.theme.textColorForTitle)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    BackButton(action: {
                        dismiss()
                    })
                }
            }
            .onAppear {
                tempUsername = authManager.username
            }
            .alert("保存成功", isPresented: $showSaveAlert) {
                Button(action: { dismiss() }) {
                    MixedFontText(content: "确定", fontSize: 18)
                }
            } message: {
                MixedFontText(content: "用户名已更新", fontSize: 16)
            }
        }
    }
}

// 圆角 shape
struct RoundedCorner: Shape {
    var radius: CGFloat = 25.0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    let mockPurchaseManager = PurchaseManager()
    let mockAuthManager = AuthManager()
    
    return UserView()
        .environmentObject(mockAuthManager)
        .environmentObject(mockPurchaseManager)
} 
