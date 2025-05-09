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