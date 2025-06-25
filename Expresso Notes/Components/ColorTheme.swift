import SwiftUI

// 全局颜色主题
struct ColorTheme {
    // MARK: - 背景颜色
    /// 背景颜色-白色
    static let backgroundColor = Color(red: 255/255, green: 255/255, blue: 255/255)
    
    // MARK: - 主题颜色
    /// 背景颜色-鹅黄
    static let themeColor = Color(red: 252/255, green: 240/255, blue: 201/255)
    
    // MARK: - 主题颜色2
    /// 背景颜色-淡鹅黄
    static let themeColor2 = Color(red: 251/255, green: 242/255, blue: 225/255)
    
    // MARK: - 滑块颜色
    /// slider 背景颜色
    static let sliderColor = Color(red: 251/255, green: 240/255, blue: 210/255)
    
    // MARK: - 输入框颜色
    /// 输入框背景颜色
    static let inputBackgroundColor = Color(red: 255/255, green: 255/255, blue: 255/255)
    
    // MARK: - 按钮颜色
    /// 按钮颜色
    static let buttonColor = Color(red: 252/255, green: 240/255, blue: 201/255)
    
    // MARK: - 禁用状态颜色
    /// 禁用状态颜色
    static let disableColor = Color(red: 162/255, green: 160/255, blue: 154/255)
    
    // MARK: - 文本颜色
    /// 普通文本颜色
    static let textColor = Color(red: 134/255, green: 86/255, blue: 56/255).opacity(0.8)
    
    /// 标题文本颜色
    static let textColorForTitle = Color(red: 134/255, green: 86/255, blue: 56/255)
    
    // MARK: - 图标颜色
    /// 图标颜色
    static let iconColor = Color(red: 162/255, green: 160/255, blue: 154/255)
}

// MARK: - Color 扩展，方便使用
extension Color {
    /// 应用主题颜色
    static let theme = ColorTheme.self
}

#Preview {
    VStack(spacing: 20) {
        // 预览所有颜色
        Group {
            Text("背景颜色")
                .padding()
                .background(Color.theme.backgroundColor)
            
            Text("滑块颜色")
                .padding()
                .background(Color.theme.sliderColor)
            
            Text("输入框背景")
                .padding()
                .background(Color.theme.inputBackgroundColor)
            
            Text("按钮颜色")
                .padding()
                .background(Color.theme.buttonColor)
            
            Text("禁用颜色")
                .padding()
                .background(Color.theme.disableColor)
            
            Text("文本颜色")
                .foregroundColor(Color.theme.textColor)
                .padding()
            
            Text("标题颜色")
                .foregroundColor(Color.theme.textColorForTitle)
                .padding()
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Color.theme.iconColor)
                Text("图标颜色")
                    .foregroundColor(Color.theme.iconColor)
            }
            .padding()
        }
    }
    .padding()
} 
