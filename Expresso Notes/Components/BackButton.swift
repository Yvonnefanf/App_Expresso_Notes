import SwiftUI

struct BackButton: View {
    let action: () -> Void
    let iconColor: Color
    let showText: Bool
    
    init(
        action: @escaping () -> Void,
        iconColor: Color = Color(red: 162/255, green: 160/255, blue: 154/255),
        showText: Bool = false
    ) {
        self.action = action
        self.iconColor = iconColor
        self.showText = showText
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .fontWeight(.bold)
                    .foregroundColor(iconColor)
                
                if showText {
                    Text("返回")
                        .foregroundColor(iconColor)
                        .font(.title3)
                }
            }
        }
        .padding(.leading, 16)
        .padding(.top, 16)
    }
}

#Preview {
    VStack(spacing: 20) {
        BackButton(action: { print("Back pressed") })
        BackButton(action: { print("Back pressed") }, showText: true)
        BackButton(action: { print("Back pressed") }, iconColor: .blue, showText: true)
    }
} 
