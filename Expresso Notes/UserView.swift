import SwiftUI
import FirebaseAuth

struct UserView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showLogoutAlert = false
    @State private var showSettingsSheet = false
    @State private var showProfileSheet = false
    // 设备参数
    @State private var coffeeMachine: String = ""
    @State private var grinder: String = ""
    @State private var minGrindSize: String = "1"
    @State private var maxGrindSize: String = "40"
    @State private var grindSizePrecision: String = "1"
    
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
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
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
    
    // MARK: - 设备设置弹窗
    var settingsSheet: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                parameterInputField(title: "咖啡机型号", binding: $coffeeMachine, placeholder: "输入咖啡机型号", required: false, showError: false, labelWidth: 100)
                parameterInputField(title: "磨豆机型号", binding: $grinder, placeholder: "输入磨豆机型号", required: false, showError: false, labelWidth: 100)
                HStack {
                    parameterInputField(title: "最小刻度", binding: $minGrindSize, placeholder: "1", required: false, showError: false, labelWidth: 100)
                    parameterInputField(title: "最大刻度", binding: $maxGrindSize, placeholder: "40", required: false, showError: false, labelWidth: 100)
                }
                parameterInputField(title: "刻度精度", binding: $grindSizePrecision, placeholder: "1", required: false, showError: false,labelWidth: 100)
                Spacer()
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
                            MixedFontText(content: "请输入用户名", fontSize: 16)
                                .foregroundColor(Color.theme.disableColor.opacity(0.7))
                                .padding(.leading, 12)
                        }
                        
                        TextField("", text: $tempUsername)
                            .textFieldStyle(CustomTextFieldStyle())
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
    UserView()
        .environmentObject(AuthManager())
} 
