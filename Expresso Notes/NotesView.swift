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
    @State private var selectedBeanName: String? = nil
    
    // 使用统一的颜色主题
    private let textColor = Color.theme.textColor
    private let titleColor = Color.theme.textColorForTitle
    private let iconColor = Color.theme.iconColor
    private let disableColor = Color.theme.disableColor
    
    // 获取所有不重复的咖啡豆名称
    var uniqueBeanNames: [String] {
        let beanNames = brewRecordStore.records.compactMap { $0.coffeeBean?.name }
        return Array(Set(beanNames)).sorted()
    }
    
    // 根据选中的咖啡豆筛选记录
    var filteredRecords: [BrewRecord] {
        if let selectedBeanName = selectedBeanName {
            let beanRecords = brewRecordStore.records.filter { record in
                record.coffeeBean?.name == selectedBeanName
            }
            
            // 如果筛选特定咖啡豆，将最佳记录置顶
            if let bestRecord = getBestRecordForBean(beanRecords) {
                var sortedRecords = beanRecords.filter { $0.id != bestRecord.id }
                sortedRecords.sort { $0.date > $1.date } // 其他记录按日期倒序
                return [bestRecord] + sortedRecords
            } else {
                return beanRecords.sorted { $0.date > $1.date }
            }
        } else {
            return brewRecordStore.records.sorted { $0.date > $1.date }
        }
    }
    
    // 获取指定记录列表中的最佳记录（评分最高的）
    private func getBestRecordForBean(_ records: [BrewRecord]) -> BrewRecord? {
        return records
            .filter { $0.rating != nil } // 只考虑有评分的记录
            .max { ($0.rating ?? 0) < ($1.rating ?? 0) }
    }
    
    // 检查指定咖啡豆是否有最佳记录
    private func hasBestRecord(for beanName: String) -> Bool {
        let beanRecords = brewRecordStore.records.filter { $0.coffeeBean?.name == beanName }
        return getBestRecordForBean(beanRecords) != nil
    }
    
    // 根据烘焙程度返回颜色
    func roastLevelColor(for roastLevel: String) -> Color {
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
    
    var body: some View {
        NavigationView {
            VStack {
                if brewRecordStore.records.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 0) {
                        // 咖啡豆分类按钮
                        if !uniqueBeanNames.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    // "全部"按钮
                                    Button(action: {
                                        selectedBeanName = nil
                                    }) {
                                        Text("全部")
                                            .font(.custom("平方江南体", size: 14))
                                            .foregroundColor(selectedBeanName == nil ? .white : titleColor)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedBeanName == nil ? titleColor : Color(UIColor.systemGray6))
                                            .cornerRadius(15)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(titleColor, lineWidth: 1)
                                            )
                                    }
                                    
                                    // 咖啡豆按钮
                                    ForEach(uniqueBeanNames, id: \.self) { beanName in
                                        Button(action: {
                                            selectedBeanName = beanName
                                        }) {
                                            HStack(spacing: 6) {
                                                // 根据烘焙程度显示颜色圆点
                                                if let record = brewRecordStore.records.first(where: { $0.coffeeBean?.name == beanName }),
                                                   let roastLevel = record.coffeeBean?.roastLevel {
                                                    Circle()
                                                        .frame(width: 8, height: 8)
                                                        .foregroundColor(roastLevelColor(for: roastLevel))
                                                }
                                                
                                                MixedFontText(content: beanName, fontSize: 14)
                                                    .foregroundColor(selectedBeanName == beanName ? .white : titleColor)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedBeanName == beanName ? titleColor : Color(UIColor.systemGray6))
                                            .cornerRadius(15)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(titleColor, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                            .background(Color.white)
                        }
                        
                        // 记录列表
                        List {
                            ForEach(Array(filteredRecords.enumerated()), id: \.element.id) { index, record in
                                NavigationLink(destination: BrewRecordDetailView(record: record)) {
                                    BrewRecordRow(
                                        record: record,
                                        isBestRecord: selectedBeanName != nil && index == 0 && record.rating != nil
                                    )
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        deleteRecord(record)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            // 改用 inline 模式，并自定义 toolbar
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 中央标题
                ToolbarItem(placement: .principal) {
                    MixedFontText(content: "咖啡笔记", fontSize: 24)
                        .foregroundColor(titleColor)
                }
                // 左侧返回按钮
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton(action: {
                        // 发送通知让 ContentView 切换到第 0 个 tab
                        NotificationCenter.default.post(name: .switchToTab, object: 0)
                        // 关闭当前视图
                        presentationMode.wrappedValue.dismiss()
                    })
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
            
            MixedFontText(content: "暂无咖啡萃取记录", fontSize: 20)
                .fontWeight(.medium)
                .foregroundColor(disableColor)
            
            MixedFontText(content: "点击首页的开始按钮添加记录", fontSize: 16)
                .foregroundColor(disableColor)
                .padding(.horizontal, 40)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    func deleteRecord(_ record: BrewRecord) {
        brewRecordStore.deleteRecord(record)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}

struct BrewRecordRow: View {
    let record: BrewRecord
    let isBestRecord: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                MixedFontText(content: formatDate(record.date), fontSize: 12)
                    .foregroundColor(Color.theme.disableColor)
                
                Spacer()
                
                // 最佳记录标识
                if isBestRecord {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text("最佳")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.textColor)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                MixedFontText(content: "粉水比 \(record.ratio)", fontSize: 12)
                    .foregroundColor(Color.theme.textColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(UIColor.systemGroupedBackground))
                    .cornerRadius(10)
            }
            
            if let bean = record.coffeeBean {
                HStack(spacing: 8) {
                    Image(getRoastImage(for: bean.roastLevel))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    MixedFontText(content: bean.name, fontSize: 16)
                        .foregroundColor(Color.theme.textColor)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 2)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    MixedFontText(content: "萃取时间: \(record.extractionTime)s", fontSize: 14)
                        .foregroundColor(Color.theme.textColor).opacity(0.8)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    if let rating = record.rating {
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(ratingColor(for: rating))
                            .fixedSize()
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .padding(.trailing, 4)
                    }
                    
                    Image(systemName: "thermometer")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    MixedFontText(content: "\(record.waterTemperature)°C", fontSize: 12)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "dial.min")
                        .foregroundColor(.brown)
                        .font(.caption)
                    
                    MixedFontText(content: "\(record.grindSize)", fontSize: 12)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(isBestRecord ? Color.theme.themeColor2.opacity(0.2) : Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isBestRecord ? Color.theme.themeColor : Color.clear, lineWidth: 2)
        )
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
//        store.addRecord(BrewRecord(
//            date: Date(),
//            coffeeWeight: "18",
//            waterTemperature: 92,
//            grindSize: 4,
//            preInfusionTime: "30",
//            extractionTime: "120",
//            yieldAmount: "36"
//        ))
        
        return NotesView()
            .environmentObject(store)
    }
}
