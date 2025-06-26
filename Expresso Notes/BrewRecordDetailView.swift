import SwiftUI

struct BrewRecordDetailView: View {
    let record: BrewRecord
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 头部信息
                VStack(alignment: .center, spacing: 20) {
                    MixedFontText(content: formatDate(record.date),color: Color.theme.disableColor)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                // 咖啡豆信息
                if let bean = record.coffeeBean {
                    VStack(alignment: .leading, spacing: 20) {
//                        Text("咖啡豆")
//                            .font(.headline)
//                            .foregroundColor(.secondary)
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
                                
                                MixedFontText(content: bean.roastLevel)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.theme.themeColor2.opacity(0.5))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
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
                                    .foregroundColor(Color(UIColor.systemGray5))
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
                                MixedFontText(content: "📒🖊️: " + description )
//                                Text("详细描述: " + description)
//                                    .font(.headline)
//                                    .foregroundColor(.secondary)
                                    .padding(.top, 12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .background(Color.theme.backgroundColor)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                }
                
//                // 分割线
//                Divider()
                
                // 关键数据概览
                HStack(spacing: 20) {
                    DataCard(title: "粉水比", value: record.ratio)
                    DataCard(title: "研磨度", value: "\(record.grindSize)")
                    DataCard(title: "水温", value: "\(record.waterTemperature)°C")
                }
                .padding(.horizontal).padding(.top, 20)
                
                // 详细数据
                Group {
                    DataRow(title: "咖啡粉重量", value: "\(record.coffeeWeight) g")
                    DataRow(title: "出液量", value: "\(record.yieldAmount) g")
                    DataRow(title: "萃取时间", value: "\(record.extractionTime) 秒")
                    
                    if !record.preInfusionTime.isEmpty {
                        DataRow(title: "预浸泡时间", value: "\(record.preInfusionTime) 秒")
                    }
                }
                .padding(.horizontal)
                .padding(.leading, 20)
                .padding(.trailing, 20)
        
                
                Spacer()
            }
            .padding(.vertical)
        }
//        .navigationTitle("记录详情")
//        .navigationBarTitleDisplayMode(.inline)
//        
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("记录详情")
                    .font(.custom("Slideqiuhong", size: 30))
                    .fontWeight(.bold).foregroundColor(Color.theme.textColorForTitle)
            }
            ToolbarItem(placement: .cancellationAction) {
                    BackButton(action: {
//                        dismiss()
//                        // 发送通知切换到主页
//                        NotificationCenter.default.post(name: .switchToTab, object: 0)
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
}

// MARK: - MOCK data for preview (only open when testing / debugging)
//struct BrewRecordDetailView_Previews: PreviewProvider {
// 
//    
//    static var previews: some View {
//        let testBean1 = CoffeeBeanReference(
//            id: UUID(), // 使用固定ID便于测试
//            name: "埃塞俄比亚耶加雪菲",
//            brand: "星巴克",
//            roastLevel: "浅焙"
//        )
//        NavigationView {
//            BrewRecordDetailView(record: BrewRecord(
//                date: Date(),
//                coffeeBean: testBean1,
//                coffeeWeight: "18",
//                waterTemperature: 92,
//                grindSize: 4,
//                preInfusionTime: "30",
//                extractionTime: "120",
//                yieldAmount: "36",
//                rating: 8,
//                ratingDescription: "haode"
//            ))
//        }
//    }
//} 
