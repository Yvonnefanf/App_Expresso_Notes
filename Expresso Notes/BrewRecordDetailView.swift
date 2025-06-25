import SwiftUI

struct BrewRecordDetailView: View {
    let record: BrewRecord
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 头部信息
                VStack(alignment: .leading, spacing: 8) {
                    Text(formatDate(record.date))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("咖啡萃取记录")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // 咖啡豆信息
                if let bean = record.coffeeBean {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("咖啡豆")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 15) {
                            // 烘焙度图片
                            Image(getRoastImage(for: bean.roastLevel))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(bean.name)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                
                                Text(bean.brand)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(bean.roastLevel)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(UIColor.systemGray5))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                // 评分
                if let rating = record.rating {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("评分")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            // 评分条
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 12)
                                    .foregroundColor(Color(UIColor.systemGray5))
                                    .cornerRadius(6)
                                
                                Rectangle()
                                    .frame(width: CGFloat(rating / 10.0) * UIScreen.main.bounds.width * 0.8, height: 12)
                                    .foregroundColor(ratingColor(for: rating))
                                    .cornerRadius(6)
                            }
                            
                            Text(String(format: "%.1f", rating))
                                .font(.headline)
                                .foregroundColor(ratingColor(for: rating))
                                .padding(.leading, 8)
                        }
                        
                        Text(systemRatingDescription(for: rating))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                        
                        // 个人评价
                        if let description = record.ratingDescription, !description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("个人评价")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                                
                                Text(description)
                                    .font(.body)
                                    .padding(12)
                                    .background(Color(UIColor.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                // 分割线
                Divider()
                
                // 关键数据概览
                HStack(spacing: 20) {
                    DataCard(title: "粉水比", value: record.ratio)
                    DataCard(title: "研磨度", value: "\(record.grindSize)")
                    DataCard(title: "水温", value: "\(record.waterTemperature)°C")
                }
                .padding(.horizontal)
                
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
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationTitle("记录详情")
        .navigationBarTitleDisplayMode(.inline)
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

struct DataCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

struct DataRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 8)
    }
}

struct BrewRecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BrewRecordDetailView(record: BrewRecord(
                date: Date(),
                coffeeWeight: "18",
                waterTemperature: 92,
                grindSize: 4,
                preInfusionTime: "30",
                extractionTime: "120",
                yieldAmount: "36"
            ))
        }
    }
} 
