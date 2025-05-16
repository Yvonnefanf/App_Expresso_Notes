import SwiftUI
import FirebaseAuth

struct UserView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var username: String = ""
    @State private var showLogoutAlert = false
    
    // 添加设备设置状态
    @State private var coffeeMachine: String = ""
    @State private var grinder: String = ""
    @State private var minGrindSize: String = "1"
    @State private var maxGrindSize: String = "40"
    @State private var grindSizePrecision: String = "1"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(red: 0.96, green: 0.93, blue: 0.88))
                        .padding(.top, 20)
                    
                    // Username Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("用户名")
                            .foregroundColor(.gray)
                        TextField("输入用户名", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // 咖啡器具设置
                    GroupBox(label: Text("咖啡器具设置").bold()) {
                        VStack(alignment: .leading, spacing: 15) {
                            // 咖啡机
                            VStack(alignment: .leading, spacing: 8) {
                                Text("咖啡机型号")
                                    .foregroundColor(.gray)
                                TextField("输入咖啡机型号", text: $coffeeMachine)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // 磨豆机
                            VStack(alignment: .leading, spacing: 8) {
                                Text("磨豆机型号")
                                    .foregroundColor(.gray)
                                TextField("输入磨豆机型号", text: $grinder)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            // 磨豆刻度设置
                            VStack(alignment: .leading, spacing: 15) {
                                Text("磨豆刻度设置")
                                    .foregroundColor(.gray)
                                    .padding(.top, 5)
                                
                                // 刻度范围
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("最小刻度")
                                            .font(.caption)
                                        TextField("1", text: $minGrindSize)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.numberPad)
                                    }
                                    
                                    Text("-")
                                        .padding(.horizontal)
                                    
                                    VStack(alignment: .leading) {
                                        Text("最大刻度")
                                            .font(.caption)
                                        TextField("40", text: $maxGrindSize)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .keyboardType(.numberPad)
                                    }
                                }
                                
                                // 精度设置
                                VStack(alignment: .leading) {
                                    Text("刻度精度")
                                        .font(.caption)
                                    TextField("1", text: $grindSizePrecision)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Logout Button
                    Button(action: {
                        showLogoutAlert = true
                    }) {
                        Text("退出登录")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("个人资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        // TODO: Save all settings
                        dismiss()
                    }
                }
            }
            .alert("确认登出", isPresented: $showLogoutAlert) {
                Button("取消", role: .cancel) { }
                Button("确认", role: .destructive) {
                    authManager.signOut()
                    dismiss()
                }
            } message: {
                Text("确定要退出登录吗？")
            }
        }
    }
}

#Preview {
    UserView()
        .environmentObject(AuthManager())
} 