//
//  ContentView.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 25/3/25.
//

import SwiftUI
import FirebaseCore

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showLogin = false
    @State private var showRegister = false
    
    var body: some View {
        if authManager.isLoggedIn {
            // 已登录状态显示的内容
            VStack {
                Image(systemName: "cup.and.saucer.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, Expresso Notes!")
                
                Button(action: {
                    authManager.signOut()
                }) {
                    Text("登出")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        } else {
            // 未登录状态显示的内容
            VStack(spacing: 20) {
                Image(systemName: "cup.and.saucer.fill")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .padding(.bottom, 20)
                
                Text("欢迎使用 Expresso Notes")
                    .font(.title)
                    .bold()
                
                Button(action: {
                    print("点击登录按钮")
                    showLogin = true
                }) {
                    Text("登录")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    print("点击注册按钮")
                    showRegister = true
                }) {
                    Text("注册")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
            }
            .padding()
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
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}


