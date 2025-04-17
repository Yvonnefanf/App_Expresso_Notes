//
//  ContentView.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 25/3/25.
//

import SwiftUI
import FirebaseCore
import WebKit

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

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showLogin = false
    @State private var showRegister = false
    @State private var showGIF = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack {
            // 背景
            if authManager.isLoggedIn {
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
                        }
                        .animation(.easeInOut(duration: 0.001), value: showGIF)
                        
                        Button(action: {
                            withAnimation {
                                showGIF.toggle()
                            }
                        }) {
                            Image("start_btn")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 100)
                        }
                        .offset(y: -70)
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    
                    // 登出按钮放在右上角
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                showLogoutAlert = true
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                                    .padding(12)
                                    .background(Color(red: 0.96, green: 0.93, blue: 0.82))
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            .alert("确认登出", isPresented: $showLogoutAlert) {
                                Button("取消", role: .cancel) { }
                                Button("确认", role: .destructive) {
                                    authManager.signOut()
                                }
                            } message: {
                                Text("确定要退出登录吗？")
                            }
                            .padding(.top, 10)
                            .padding(.trailing, 35)
                        }
                        Spacer()
                    }
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

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}


