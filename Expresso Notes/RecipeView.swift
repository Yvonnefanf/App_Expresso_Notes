import SwiftUI

struct RecipeView: View {
    @Binding var selectedTab: Int
    
    // 创建4行3列的网格布局
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color(red: 1, green: 1, blue: 1).ignoresSafeArea() // 强制白色背景，不受夜间模式影响
            
            VStack(spacing: 20) {
                // 使用全局返回按钮组件
                HStack {
                    BackButton(action: {
                        selectedTab = 0
                    })
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Title图片在顶部正中间
                Image("title")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 80)
                    .padding(.top, 10)
                
                // 4行3列的图片网格（不可滑动）
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(1...12, id: \.self) { index in
                        Image("cof\(index)")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView(selectedTab: .constant(3))
    }
} 
