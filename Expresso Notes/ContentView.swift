//
//  ContentView.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 25/3/25.
//

import SwiftUI
import FirebaseCore
import Combine

// 定义通知名称
extension Notification.Name {
    static let switchToTab = Notification.Name("switchToTab")
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var brewRecordStore: BrewRecordStore
    @EnvironmentObject var beanManager: CoffeeBeanManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showMainTabs = false
    @State private var showLogoutAlert = false
    @State private var selectedTab = 0
    @State private var showBrewRecord = false
    @State private var showFirstTimeSetup = false
    @State private var setupUsername = ""
    @State private var setupCoffeeMachine = ""
    @State private var setupGrinder = ""
    
    // 添加通知观察者
    @State private var notificationSubscription: AnyCancellable?
    
    var body: some View {
        ZStack {
            Color.theme.backgroundColor.ignoresSafeArea() // all white
            if authManager.isLoggedIn {
                VStack(spacing: 0) {
                    // 已经登陆 主内容区域
                    ZStack {
                        switch selectedTab {
                        case 0:
                            // Notes Tab
                            VStack {
                                ZStack {
                                    VStack(spacing: 0) {
                                        // 静态图片
                                        Image("background")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 400)
                                            .offset(y: 40)
                                        
                                        Button(action: {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                                                showBrewRecord = true
                                            }
                                        }) {
                                            Image("start_button")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 160, height: 100)
                                        }
                                        .offset(y: 10)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(10)
                                }
                            }
                        case 1:
                            NotesView()
                                .environmentObject(brewRecordStore)
                        case 2:
                            CoffeeBeanView()
                                .environmentObject(beanManager)
                        case 3:
                            RecipeView(selectedTab: $selectedTab)
                        case 4:
                            UserView()
                                .environmentObject(authManager)
                                .environmentObject(purchaseManager)
                        default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // 菜单栏 - 只在首页显示
                    if selectedTab == 0 {
                        HStack {
                            CustomTabButton(image: "coffeenote", title: "笔记", isSelected: selectedTab == 1) {
                                selectedTab = 1
                            }
                            CustomTabButton(image: "coffeebean", title: "豆仓", isSelected: selectedTab == 2) {
                                selectedTab = 2
                            }
                            CustomTabButton(image: "recipe", title: "菜谱", isSelected: selectedTab == 3) {
                                selectedTab = 3
                            }
                            CustomTabButton(image: "profile", title: "我的", isSelected: selectedTab == 4) {
                                selectedTab = 4
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(
                            Color.white
                                .ignoresSafeArea(edges: .bottom)
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
                .onAppear {
                    // 设置通知监听（原来的代码）
                    notificationSubscription = NotificationCenter.default
                        .publisher(for: .switchToTab)
                        .sink { notification in
                            if let tabIndex = notification.object as? Int {
                                selectedTab = tabIndex
                            }
                        }
                    
                    // 设置AuthManager的数据管理器引用
                    authManager.setDataManagers(brewRecordStore: brewRecordStore, beanManager: beanManager, purchaseManager: purchaseManager)
                }
                .onChange(of: authManager.isFirstLogin) { isFirstLogin in
                    if isFirstLogin {
                        // 预填充用户名
                        setupUsername = authManager.username
                        showFirstTimeSetup = true
                    }
                }
                .onDisappear {
                    // 清理通知监听
                    notificationSubscription?.cancel()
                }
                .alert("确认登出", isPresented: $showLogoutAlert) {
                    Button("取消", role: .cancel) { }
                    Button("确认", role: .destructive) {
                        authManager.signOut()
                    }
                } message: {
                    Text("确定要退出登录吗？")
                }
                .sheet(isPresented: $showBrewRecord) {
                    BrewRecordView()
                        .environmentObject(brewRecordStore)
                        .environmentObject(beanManager)
                }
            } else {
                // 未登录状态直接显示LoginView
                LoginView()
                    .environmentObject(authManager)
            }
            
            // 首次登录设置弹窗
            if showFirstTimeSetup {
                firstTimeSetupDialog
            }
        }
    }
    
    // MARK: - 首次设置弹窗
    var firstTimeSetupDialog: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // 防止点击背景关闭
                }
            
            VStack(spacing: 20) {
                MixedFontText(content: "完善个人信息", fontSize: 20)
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.textColorForTitle)
                
                Text("首次登录，请设置您的个人信息和设备参数")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.theme.textColor)
                
                VStack(spacing: 16) {
                    // 用户名输入框
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            MixedFontText(content: "用户名", fontSize: 16)
                                .foregroundColor(Color.theme.textColor)
                            Text("*")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                        }
                        TextField("请输入用户名", text: $setupUsername)
                            .font(.system(size: 14))
                            .padding(12)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // 咖啡机型号输入框
                    VStack(alignment: .leading, spacing: 8) {
                        MixedFontText(content: "咖啡机型号", fontSize: 16)
                            .foregroundColor(Color.theme.textColor)
                        TextField("请输入咖啡机型号（可选）", text: $setupCoffeeMachine)
                            .font(.system(size: 14))
                            .padding(12)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    // 磨豆机型号输入框
                    VStack(alignment: .leading, spacing: 8) {
                        MixedFontText(content: "磨豆机型号", fontSize: 16)
                            .foregroundColor(Color.theme.textColor)
                        TextField("请输入磨豆机型号（可选）", text: $setupGrinder)
                            .font(.system(size: 14))
                            .padding(12)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                }
                
                // 按钮
                Button(action: {
                    saveFirstTimeSetup()
                }) {
                    MixedFontText(content: "完成设置", fontSize: 16)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(setupUsername.isEmpty ? Color.theme.disableColor : Color.theme.buttonColor)
                        .cornerRadius(25)
                }
                .disabled(setupUsername.isEmpty)
                .opacity(setupUsername.isEmpty ? 0.3 : 1.0)
            }
            .padding(30)
            .background(Color(red: 1, green: 1, blue: 1))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
        }
        .zIndex(1000)
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - 保存首次设置
    private func saveFirstTimeSetup() {
        print("保存首次设置...")
        authManager.saveFirstTimeSetup(
            username: setupUsername,
            coffeeMachine: setupCoffeeMachine,
            grinder: setupGrinder
        )
        
        // 关闭弹窗
        withAnimation(.easeInOut(duration: 0.3)) {
            showFirstTimeSetup = false
        }
        
        // 清空输入内容
        setupUsername = ""
        setupCoffeeMachine = ""
        setupGrinder = ""
    }
}

struct CustomTabButton: View {
    let image: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var iconSize: CGFloat = 46

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconSize, height: iconSize)
                MixedFontText(content: title)
                    .fixedSize(horizontal: true, vertical: false)
                    .onAppear {
                        print("Button title: \(title), isSelected: \(isSelected)")
                    }
            }
            .foregroundColor(isSelected
                             ? Color(red: 0.96, green: 0.93, blue: 0.88)
                             : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
        .environmentObject(BrewRecordStore())
        .environmentObject(CoffeeBeanManager())
        .environmentObject(PurchaseManager())
}


