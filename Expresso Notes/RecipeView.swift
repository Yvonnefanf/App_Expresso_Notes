import SwiftUI

struct RecipeView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
            ZStack {
                VStack {
                    Spacer()
                    Image("caipu_content")
                        .resizable()
                        .scaledToFit() // 保持比例，铺满宽度
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        selectedTab = 0
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.black)
                            .font(.title2)
                    }
                }
            }
        }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
             RecipeView(selectedTab: .constant(3))
        }
    }
} 
