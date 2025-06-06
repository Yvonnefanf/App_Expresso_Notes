//
//  Expresso_NotesApp.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 25/3/25.
//

import SwiftUI
import FirebaseCore

@main
struct Expresso_NotesApp: App {
    @StateObject private var authManager = AuthManager()
    @StateObject private var brewRecordStore = BrewRecordStore()
    @StateObject private var beanManager = CoffeeBeanManager()
    
    init() {
        FirebaseApp.configure()
        print("Firebase 配置完成")
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
                    .environmentObject(authManager)
                    .environmentObject(brewRecordStore)
                    .environmentObject(beanManager)   // ← 把同一个 beanManager 放到环境里
            }
        }
    }
}
