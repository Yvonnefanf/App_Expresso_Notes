import SwiftUI

struct RatingView: View {
    @Binding var rating: Double
    @Binding var description: String
    @Environment(\.dismiss) private var dismiss
    var onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("给你的咖啡打分")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("这次的萃取效果如何？")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // 评分滑块
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("评分")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "%.1f", rating))
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                
                Slider(value: $rating, in: 0...10, step: 0.1)
                    .accentColor(.orange)
                
                // 评分标尺
                HStack {
                    Text("0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("5")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("10")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
            }
            .padding(.vertical, 8)
            
            // 显示评分描述
            Text(systemRatingDescription(for: rating))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            
            // 个人评价输入
            VStack(alignment: .leading, spacing: 8) {
                Text("个人评价")
                    .font(.headline)
                
                ZStack(alignment: .topLeading) {
                    if description.isEmpty {
                        Text("描述一下这次萃取的风味、口感等...")
                            .font(.body)
                            .foregroundColor(.gray.opacity(0.8))
                            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                    }
                    
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .padding(4)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 8)
            
            Divider()
                .padding(.vertical, 8)
            
            // 按钮
            HStack(spacing: 16) {
                Button("取消") {
                    dismiss()
                }
                .frame(width: 120)
                .padding()
                .foregroundColor(.gray)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                Button("保存") {
                    onSave()
                    dismiss()
                }
                .frame(width: 120)
                .padding()
                .foregroundColor(.white)
                .background(Color(red: 0.6, green: 0.4, blue: 0.2))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal, 24)
    }
    
    func systemRatingDescription(for rating: Double) -> String {
        switch rating {
        case 0..<3:
            return "不满意，存在明显问题"
        case 3..<5:
            return "一般，有改进空间"
        case 5..<7:
            return "不错，基本满意"
        case 7..<9:
            return "很好，令人满意"
        case 9...10:
            return "极佳，完美萃取"
        default:
            return ""
        }
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
            RatingView(rating: .constant(7.0), description: .constant(""), onSave: {})
        }
    }
} 