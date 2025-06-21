//
//  NotesView.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 9/5/25.
//

import SwiftUI

struct NotesView: View {
    @EnvironmentObject var brewRecordStore: BrewRecordStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var searchText = ""
    
    // 你可以根据需要替换成你项目中实际的颜色
    private let textColor: Color = .primary
    
    // 筛选逻辑保持不变
    var filteredRecords: [BrewRecord] {
        if searchText.isEmpty {
            return brewRecordStore.records
        } else {
            return brewRecordStore.records.filter { record in
                let dateString = formatDate(record.date)
                return dateString.localizedCaseInsensitiveContains(searchText) ||
                       record.ratio.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if brewRecordStore.records.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredRecords) { record in
                            NavigationLink(destination: BrewRecordDetailView(record: record)) {
                                BrewRecordRow(record: record)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                        .onDelete(perform: deleteRecords)
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "搜索记录")
                }
            }
            // 改用 inline 模式，并自定义 toolbar
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 中央标题
                ToolbarItem(placement: .principal) {
                    Text("咖啡笔记")
                        .font(.custom("Umeboshi", size: 24))
                }
                // 右侧回到首页按钮
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // 发送通知让 ContentView 切换到第 0 个 tab
                        NotificationCenter.default.post(name: .switchToTab, object: 0)
                        // 关闭当前视图
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "house.fill")
                            .foregroundColor(textColor)
                    }
                }
                // ToolbarItem(placement: .navigationBarLeading) {
                //     HStack {
                //         Button("添加测试") {
                //             brewRecordStore.addTestRecord()
                //         }
                //         .foregroundColor(.blue)
                        
                //         Button("清空") {
                //             brewRecordStore.clearAllRecords()
                //         }
                //         .foregroundColor(.red)
                //     }
                // }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cup.and.saucer.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("暂无咖啡萃取记录")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text("点击首页的开始按钮添加记录")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    func deleteRecords(at offsets: IndexSet) {
        brewRecordStore.deleteRecord(at: offsets)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

struct BrewRecordRow: View {
    let record: BrewRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(record.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("粉水比 \(record.ratio)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
            }
            
            if let bean = record.coffeeBean {
                HStack(spacing: 8) {
                    Image(getRoastImage(for: bean.roastLevel))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text(bean.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(bean.brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("萃取时间: \(record.extractionTime)秒")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text("\(record.coffeeWeight)g / \(record.yieldAmount)g")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    if let rating = record.rating {
                        HStack(spacing: 4) {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(ratingColor(for: rating))
                            
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(ratingColor(for: rating))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding(.trailing, 4)
                    }
                    
                    Image(systemName: "thermometer")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text("\(record.waterTemperature)°C")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "dial.min")
                        .foregroundColor(.brown)
                        .font(.caption)
                    
                    Text("\(record.grindSize)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let description = record.ratingDescription, !description.isEmpty {
                HStack {
                    Image(systemName: "text.quote")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(description.count > 40 ? description.prefix(40) + "..." : description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter.string(from: date)
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

struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        let store = BrewRecordStore()
        
        // 添加示例数据
        store.addRecord(BrewRecord(
            date: Date(),
            coffeeWeight: "18",
            waterTemperature: 92,
            grindSize: 4,
            preInfusionTime: "30",
            extractionTime: "120",
            yieldAmount: "36"
        ))
        
        return NotesView()
            .environmentObject(store)
    }
}
