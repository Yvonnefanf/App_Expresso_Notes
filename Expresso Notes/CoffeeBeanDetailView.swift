//
//  CoffeeBeanDetailView.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 26/6/25.
//
import SwiftUI

// MARK: - 咖啡豆详情视图
struct CoffeeBeanDetailView: View {
    var coffeeBean: CoffeeBean
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var brewRecordStore: BrewRecordStore
    
    // 根据烘焙度获取对应的图片名称
    private var roastImage: String {
        switch coffeeBean.roastLevel {
        case .light:
            return "qianhong"
        case .medium:
            return "zhonghong"
        case .dark:
            return "shenhong"
        }
    }
    
    // 使用State变量来存储数据
    @State private var bestParameters: BestParameters?
    @State private var statistics: CoffeeBeanStatistics?
    
    var body: some View {
        ScrollView {
                        // MARK: - 咖啡豆信息
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    // 左侧所有信息
                    VStack(alignment: .leading, spacing: 8) {
                        // 名称
                        MixedFontText(content: coffeeBean.name, fontSize: 24)
                            .bold()
                        
                        // 品牌
                        MixedFontText(content: coffeeBean.brand, fontSize: 20)
                            .foregroundColor(.secondary)
                        
                        // 烘焙度
                        HStack(spacing: 6) {
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(roastLevelColor(for: coffeeBean.roastLevel.rawValue))
                            
                            MixedFontText(content: coffeeBean.roastLevel.rawValue)
                        }
                        
                        // 品种
                        if !coffeeBean.variety.isEmpty {
                            detailSection(title: "品种:", value: coffeeBean.variety)
                        }
                        
                        // 产地
                        if !coffeeBean.origin.isEmpty {
                            detailSection(title: "产地:", value: coffeeBean.origin)
                        }
                        
                        // 处理方式
                        if !coffeeBean.processingMethod.isEmpty {
                            detailSection(title: "处理方式:", value: coffeeBean.processingMethod)
                        }
                        
                        // 口感
                        if !coffeeBean.flavors.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                MixedFontText(content: "口感:", fontSize: 18)
                                    .font(.headline)
                                
                                FlowLayout(alignment: .leading, spacing: 8) {
                                    ForEach(coffeeBean.flavors, id: \.self) { flavor in
                                        MixedFontText(content: flavor, fontSize: 14)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color(red: 0.96, green: 0.93, blue: 0.88))
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // 右侧图片
                    Image(roastImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70)
                }.padding(.horizontal, 20)
                
                
                // MARK: - 咖啡豆 萃取统计信息
                if let stats = statistics {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        MixedFontText(content: "萃取统计", fontSize: 18)
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            
                            DataCard(title: "总次数", value: "\(stats.totalRecords)")
                            DataCard(title: "平均评分", value: String(format: "%.1f", stats.averageRating))
                            DataCard(title: "最高评分", value: String(format: "%.1f", stats.bestRating))
                        }
                    }
                    .padding(.horizontal, 20)
                    .background(Color.theme.backgroundColor)
                    .cornerRadius(12)
                }
                
                // MARK: - 咖啡豆 最佳参数信息
                if let bestParams = bestParameters {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            MixedFontText(content: "最佳参数", fontSize: 18)
                                .font(.headline)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                
                                Text(String(format: "%.1f", bestParams.rating))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                            }
                        }
                        

                        
                        // 关键参数卡片
                        HStack(spacing: 12) {
                            DataCard(title: "粉水比", value: bestParams.ratio)
                            DataCard(title: "研磨度", value: String(format: "%.1f", bestParams.grindSize))
                            DataCard(title: "水温", value: "\(bestParams.waterTemperature)°C")
                        }.padding(.top, 8)
                        
                        // 详细参数
                        VStack(spacing: 8) {
                            DataRow(title: "咖啡粉重量", value: "\(bestParams.coffeeWeight) g")
                            DataRow(title: "出液量", value: "\(bestParams.yieldAmount) g")
                            DataRow(title: "萃取时间", value: "\(bestParams.extractionTime) s")
                            
                            if !bestParams.preInfusionTime.isEmpty {
                                DataRow(title: "预浸泡时间", value: "\(bestParams.preInfusionTime) s")
                            }
                        }
                        .padding(.top, 8).padding(.leading, 20).padding(.trailing, 20)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(Color.theme.backgroundColor)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            // 在视图出现时加载数据
            bestParameters = brewRecordStore.getBestParametersForCoffeeBean(coffeeBean.id)
            statistics = brewRecordStore.getStatisticsForCoffeeBean(coffeeBean.id)
        }

        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    
                    Text("咖啡豆详情")
                        .font(.custom("Slideqiuhong", size: 24))
                        .fontWeight(.bold).foregroundColor(Color.theme.textColorForTitle)
                }
                .foregroundColor(.primary)
                .padding(.top, 16)
            }
            ToolbarItem(placement: .cancellationAction) {
                BackButton(action:{presentationMode.wrappedValue.dismiss()}
                )
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
    
    private func detailSection(title: String, value: String) -> some View {
        HStack(spacing: 8) {
            MixedFontText(content: title, fontSize: 16)
                .foregroundColor(.secondary)
            
            MixedFontText(content: value, fontSize: 16)
            
            Spacer()
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

// 流式布局（用于显示标签）
struct FlowLayout: Layout {
    var alignment: HorizontalAlignment = .leading
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var width: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if x + viewSize.width > maxWidth {
                // 换行
                y += viewSize.height + spacing
                x = 0
                
                // 放置当前视图
                x += viewSize.width + spacing
                width = max(width, viewSize.width)
                height = y + viewSize.height
            } else {
                // 继续当前行
                x += viewSize.width + spacing
                width = max(width, x)
                height = max(height, y + viewSize.height)
            }
        }
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x = bounds.minX
        var y = bounds.minY
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if x + viewSize.width > bounds.maxX {
                // 换行
                y += viewSize.height + spacing
                x = bounds.minX
            }
            
            view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += viewSize.width + spacing
        }
    }
}

// MARK: - MOCK data for preview (only open when testing / debugging)
//struct CoffeeBeanDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        let testBean = CoffeeBean(
//            id: UUID(),
//            name: "埃塞俄比亚耶加雪菲",
//            brand: "星巴克",
//            variety: "Heirloom",
//            origin: "耶加雪菲, 埃塞俄比亚",
//            processingMethod: "水洗",
//            roastLevel: .light,
//            flavors: ["柑橘", "花香", "莓果"],
//            dateAdded: Date()
//        )
//        
//        let brewRecordStore = BrewRecordStore()
//        
//        // Add mock brew records for preview
//        let coffeeBeanRef = CoffeeBeanReference(from: testBean)
//        let mockRecords = [
//            BrewRecord(
//                date: Date().addingTimeInterval(-86400), // 1 day ago
//                coffeeBean: coffeeBeanRef,
//                coffeeWeight: "18",
//                waterTemperature: 92,
//                grindSize: 4,
//                preInfusionTime: "30",
//                extractionTime: "120",
//                yieldAmount: "36",
//                rating: 8.5,
//                ratingDescription: "花香明显，酸度适中"
//            ),
//            BrewRecord(
//                date: Date().addingTimeInterval(-172800), // 2 days ago
//                coffeeBean: coffeeBeanRef,
//                coffeeWeight: "18",
//                waterTemperature: 90,
//                grindSize: 5,
//                preInfusionTime: "25",
//                extractionTime: "110",
//                yieldAmount: "36",
//                rating: 9.2,
//                ratingDescription: "柑橘香气突出，口感平衡"
//            ),
//            BrewRecord(
//                date: Date().addingTimeInterval(-259200), // 3 days ago
//                coffeeBean: coffeeBeanRef,
//                coffeeWeight: "18",
//                waterTemperature: 94,
//                grindSize: 3,
//                preInfusionTime: "35",
//                extractionTime: "130",
//                yieldAmount: "36",
//                rating: 7.8,
//                ratingDescription: "萃取过度，苦味较重"
//            )
//        ]
//        
//        // Add records to the store
//        for record in mockRecords {
//            brewRecordStore.addRecord(record)
//        }
//
//        return NavigationView {
//            CoffeeBeanDetailView(coffeeBean: testBean)
//                .environmentObject(brewRecordStore)
//        }
//    }
//}

