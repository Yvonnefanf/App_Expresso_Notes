//
//  ContentView.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 25/3/25.
//

import SwiftUI
import FirebaseCore
import WebKit
import Combine

// GIF 视图组件
struct GIFView: UIViewRepresentable {
    let gifName: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        
        // 设置 WKWebView 的缩放模式
        webView.scrollView.contentMode = .scaleAspectFit
        
        // 添加自适应大小的 CSS
        let css = """
        <style>
        body {
            margin: 0;
            padding: 0;
            background: transparent;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }
        </style>
        """
        
        // 从项目根目录加载 GIF
        if let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif"),
           let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)) {
            print("成功加载 GIF 文件：\(gifName)")
            let html = """
            <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
                \(css)
            </head>
            <body>
                <img src="data:image/gif;base64,\(gifData.base64EncodedString())" />
            </body>
            </html>
            """
            webView.loadHTMLString(html, baseURL: nil)
        } else {
            print("无法加载 GIF 文件：\(gifName)")
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// 定义通知名称
extension Notification.Name {
    static let switchToTab = Notification.Name("switchToTab")
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var brewRecordStore = BrewRecordStore()
    @StateObject private var beanManager = CoffeeBeanManager()
    @State private var showMainTabs = false
    @State private var showLogin = false
    @State private var showRegister = false
    @State private var showGIF = false
    @State private var showLogoutAlert = false
    @State private var selectedTab = 0
    @State private var showBrewRecord = false
    @State private var showUserProfile = false
    
    // 添加通知观察者
    @State private var notificationSubscription: AnyCancellable?
    
    var body: some View {
        ZStack {
            if authManager.isLoggedIn {
                VStack {
                    // 主内容区域
                    ZStack {
                        switch selectedTab {
                        case 0:
                            // Notes Tab
                            VStack {
                                ZStack {
                                    VStack(spacing: 0) {
                                        ZStack {
                                            // 静态图片
                                            Image("background")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 400)
                                                .opacity(showGIF ? 0 : 1)
                                            
                                            // GIF 图片
                                            GIFView(gifName: "background")
                                                .frame(width: 400)
                                                .opacity(showGIF ? 1 : 0)
                                        }.offset(y: 40)
                                        .animation(.easeInOut(duration: 0.001), value: showGIF)
                                        
                                        Button(action: {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                                                showBrewRecord = true
                                            }
                                        }) {
                                            Image("start_btn")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 160, height: 100)
                                        }
                                        .offset(y: -10)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(10)
                                    
                                    // 登出按钮放在右上角
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                showUserProfile = true
                                            }) {
                                                Image(systemName: "person.circle")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.white)
                                                    .padding(0)
                                                    .background(Color(red: 0.96, green: 0.93, blue: 0.88))
                                                    .clipShape(Circle())
                                                    .shadow(radius: 2)
                                            }
                                            .padding(.top, 10)
                                            .padding(.trailing, 25)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        case 1:
                            NotesView()
                                .environmentObject(brewRecordStore)
                        case 2:
                            CoffeeBeanView()
                                .environmentObject(beanManager)
                        case 3:
                            VStack {
                                Text("菜谱")
                                    .font(.title)
                            }
                        default:
                            EmptyView()
                        }
                    }
                    
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
                        CustomTabButton(image: "rank", title: "排行", isSelected: selectedTab == 4) {
                            selectedTab = 4
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(
                        Color.white
                            .ignoresSafeArea(edges: .bottom)
                    )
                    .frame(maxWidth: .infinity) // 整行撑满宽度
                }
                .onAppear {
                    // 设置通知监听
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
                .sheet(isPresented: $showBrewRecord, onDismiss: {
                    showGIF = false
                }) {
                    BrewRecordView()
                        .environmentObject(brewRecordStore)
                        .environmentObject(beanManager)
                }
                .sheet(isPresented: $showUserProfile) {
                    UserView()
                        .environmentObject(authManager)
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

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    // 根据选中状态微调尺寸
                    .frame(width: 46,
                           height: 46)
                Text(title)
                    .font(.system(size: isSelected ? 20 : 16))
            }
            .foregroundColor(isSelected
                             ? Color(red: 0.96, green: 0.93, blue: 0.88)
                             : .gray)
            .frame(maxWidth: .infinity) // 均等分布
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}


