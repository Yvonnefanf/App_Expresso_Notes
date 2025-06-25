import SwiftUI

struct RecipeView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            VStack {
                // 自定义返回按钮
                HStack {
                    Button(action: {
                        selectedTab = 0
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .font(.title2)
                           
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                
                Spacer()
                Image("caipu_content")
                    .resizable()
                    .scaledToFit() // 保持比例，铺满宽度
                    .frame(maxWidth: .infinity)
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
