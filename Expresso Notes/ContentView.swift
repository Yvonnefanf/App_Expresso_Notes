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
    @State private var showMainTabs = false
    @State private var showLogin = false
    @State private var showRegister = false
    @State private var showLogoutAlert = false
    @State private var selectedTab = 0
    @State private var showBrewRecord = false
    
    // 添加通知观察者
    @State private var notificationSubscription: AnyCancellable?
    
    var body: some View {
        ZStack {
            Color.white // 白色背景
                           .ignoresSafeArea() // 覆盖整个屏幕（包括 safe area）
            if authManager.isLoggedIn {
                VStack(spacing: 0) {
                    // 主内容区域
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
                            CustomTabButton(image: "profile", title: "我的", isSelected: selectedTab == 4, action:  {
                                selectedTab = 4
                            }, iconSize: 40)
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
                // 未登录状态显示的内容
                VStack(spacing: 15) {
                    Image(systemName: "cup.and.saucer.fill")
                        .imageScale(.medium)
                        .padding(.bottom, 10)
                    
                    Text("欢迎使用 Expresso Notes")
                        .font(.title3)
                        .bold()
                    
                    Button(action: {
                        print("点击登录按钮")
                        showLogin = true
                    }) {
                        Text("登录")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .frame(width: 200)
                    
                    Button(action: {
                        print("点击注册按钮")
                        showRegister = true
                    }) {
                        Text("注册")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .frame(width: 200)
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .frame(width: 280)
            }
        }
        .sheet(isPresented: $showLogin) {
            LoginView()
                .environmentObject(authManager)
        }
        .sheet(isPresented: $showRegister) {
            LoginView(isRegistering: true)
                .environmentObject(authManager)
        }
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
                Text(title)
                    .font(.custom("平方江南体", size: isSelected ? 20 : 16))
                    .fixedSize(horizontal: true, vertical: false)
                    .onAppear {
                        print("Button title: \(title), isSelected: \(isSelected)")
                        // 打印所有可用字体
                        for family in UIFont.familyNames {
                            if family.contains("umeboshi") {
                                print("Found umeboshi font family: \(family)")
                                for name in UIFont.fontNames(forFamilyName: family) {
                                    print("Font name: \(name)")
                                }
                            }
                        }
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
}


