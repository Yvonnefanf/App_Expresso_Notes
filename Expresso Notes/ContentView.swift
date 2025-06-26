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
// 定义通知名称
extension Notification.Name {
    static let switchToTab = Notification.Name("switchToTab")
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var brewRecordStore: BrewRecordStore
    @EnvironmentObject var beanManager: CoffeeBeanManager
    @State private var showMainTabs = false
    @State private var showLogoutAlert = false
    @State private var selectedTab = 0
    @State private var showBrewRecord = false
    
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
                // 未登录状态直接显示LoginView
                LoginView()
                    .environmentObject(authManager)
            }
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
}


