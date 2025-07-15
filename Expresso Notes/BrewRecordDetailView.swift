import SwiftUI

struct BrewRecordDetailView: View {
    let record: BrewRecord
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(red: 1, green: 1, blue: 1).ignoresSafeArea() // 强制白色背景，不受夜间模式影响
            
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 头部信息
                VStack(alignment: .center, spacing: 20) {
                    MixedFontText(content: formatDate(record.date),color: Color.theme.disableColor)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                
                // 咖啡豆信息 - 调整到第二位
                if let bean = record.coffeeBean {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(spacing: 0) {
                            // 烘焙度图片
                            Image(getRoastImage(for: bean.roastLevel))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, height: 90)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                MixedFontText(
                                    content: bean.name, fontSize: 20
                                ).fontWeight(.medium)
                                
                                MixedFontText(
                                    content: bean.brand, fontSize: 18, color: Color.theme.textColor.opacity(0.7)
                                )
                                
                                HStack(spacing: 6) {
                                    Circle()
                                        .frame(width: 8, height: 8)
                                        .foregroundColor(roastLevelColor(for: bean.roastLevel))
                                
                                MixedFontText(content: bean.roastLevel)
                                }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.theme.themeColor2.opacity(0.5))
                                    .cornerRadius(4)
                            }
                            
                            Spacer() // 确保内容居左
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .leading) // 居左对齐
                    .background(Color(red: 1, green: 1, blue: 1)) // 强制白色背景
                    .cornerRadius(10) // 移除shadow
                    .padding(.horizontal)
                }
                
                // 关键数据概览 - 调整到第三位
                HStack(spacing: 20) {
                    DataCard(title: "粉水比", value: record.ratio)
                    DataCard(title: "研磨度", value: String(format: "%.1f", record.grindSize))
                    DataCard(title: "水温", value: "\(record.waterTemperature)°C")
                }
                .padding(.horizontal).padding(.top, 20)
                
                // 详细数据
                Group {
                    DataRow(title: "咖啡粉重量", value: "\(record.coffeeWeight) g")
                    DataRow(title: "出液量", value: "\(record.yieldAmount) g")
                    DataRow(title: "萃取时间", value: "\(record.extractionTime) s")
                    
                    if !record.preInfusionTime.isEmpty {
                        DataRow(title: "预浸泡时间", value: "\(record.preInfusionTime) s")
                    }
                }
                .padding(.horizontal)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                
                // 评分
                if let rating = record.rating {
                    VStack(alignment: .leading, spacing: 12) {
                        MixedFontText(content: systemRatingDescription(for: rating), color: ratingColor(for: rating))
//                        Text(systemRatingDescription(for: rating))
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                            .padding(.top, 2)
                        
                        HStack {
                            // 评分条
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 10)
                                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.9)) // 固定浅灰色，不受夜间模式影响
                                    .cornerRadius(6)
                                
                                Rectangle()
                                    .frame(width: CGFloat(rating / 10.0) * UIScreen.main.bounds.width * 0.8, height: 10)
                                    .foregroundColor(ratingColor(for: rating))
                                    .cornerRadius(6)
                            }
                            
                            Text(String(format: "%.1f", rating))
                                .font(.headline)
                                .foregroundColor(ratingColor(for: rating))
                                .padding(.leading, 8)
                        }
                        
                        // 个人评价
                        if let description = record.ratingDescription, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                MixedFontText(content: description) // 移除emoji，直接显示内容
                                    .padding(.top, 12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .background(Color(red: 1, green: 1, blue: 1)) // 强制白色背景
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                }
        
                
                Spacer()
            }
            .padding(.vertical)
            }
        }
//        .navigationTitle("记录详情")
//        .navigationBarTitleDisplayMode(.inline)
//        
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("记录详情")
                    .font(.custom("Slideqiuhong", size: 24))
                    .fontWeight(.bold).foregroundColor(Color.theme.textColorForTitle)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(action: {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
            
        
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
    
    private func systemRatingDescription(for rating: Double) -> String {
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
    
    private func ratingColor(for rating: Double) -> Color {
        switch rating {
        case 0..<3:
            return .red
        case 3..<5:
            return .orange
        case 5..<7:
            return .yellow
        case 7..<9:
            return .green
        case 9...10:
            return .blue
        default:
            return .gray
        }
    }
    
    // 获取烘焙度对应的图片名称
    private func getRoastImage(for roastLevel: String) -> String {
        switch roastLevel {
        case "浅焙":
            return "qianhong"
        case "中焙":
            return "zhonghong"
        case "深焙":
            return "shenhong"
        default:
            return "zhonghong"
        }
    }
    
    // 根据烘焙程度返回颜色
    private func roastLevelColor(for roastLevel: String) -> Color {
        switch roastLevel {
        case "浅焙":
            return .green
        case "中焙":
            return .blue
        case "深焙":
            return .red
        default:
            return .gray
        }
    }
}
