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
    
    // 获取最佳参数
    private var bestParameters: BestParameters? {
        brewRecordStore.getBestParametersForCoffeeBean(coffeeBean.id)
    }
    
    // 获取统计信息
    private var statistics: CoffeeBeanStatistics? {
        brewRecordStore.getStatisticsForCoffeeBean(coffeeBean.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        MixedFontText(content: coffeeBean.name, fontSize: 28)
                            .bold()
                        
                        MixedFontText(content: coffeeBean.brand, fontSize: 20)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 显示烘焙度图片
                    Image(roastImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                }
                
                Divider()
                
                if !coffeeBean.variety.isEmpty {
                    detailSection(title: "品种", value: coffeeBean.variety)
                }
                
                if !coffeeBean.origin.isEmpty {
                    detailSection(title: "产地", value: coffeeBean.origin)
                }
                
                if !coffeeBean.processingMethod.isEmpty {
                    detailSection(title: "处理方式", value: coffeeBean.processingMethod)
                }
                
                detailSection(title: "烘焙度", value: coffeeBean.roastLevel.rawValue)
                
                if !coffeeBean.flavors.isEmpty {
                    MixedFontText(content: "口感", fontSize: 18)
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
                
                // 统计信息部分
                if let stats = statistics {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        MixedFontText(content: "萃取统计", fontSize: 18)
                            .font(.headline)
                        
                        HStack(spacing: 16) {
                            StatCard(title: "总记录", value: "\(stats.totalRecords)")
                            StatCard(title: "平均评分", value: String(format: "%.1f", stats.averageRating))
                            StatCard(title: "最高评分", value: String(format: "%.1f", stats.bestRating))
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                }
                
                // 最佳参数部分
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
                        
                        Text("基于 \(formatDate(bestParams.date)) 的记录")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // 关键参数卡片
                        HStack(spacing: 12) {
                            BestParamCard(title: "粉水比", value: bestParams.ratio)
                            BestParamCard(title: "研磨度", value: "\(bestParams.grindSize)")
                            BestParamCard(title: "水温", value: "\(bestParams.waterTemperature)°C")
                        }
                        
                        // 详细参数
                        VStack(spacing: 8) {
                            BestParamRow(title: "咖啡粉重量", value: "\(bestParams.coffeeWeight) g")
                            BestParamRow(title: "出液量", value: "\(bestParams.yieldAmount) g")
                            BestParamRow(title: "萃取时间", value: "\(bestParams.extractionTime) 秒")
                            
                            if !bestParams.preInfusionTime.isEmpty {
                                BestParamRow(title: "预浸泡时间", value: "\(bestParams.preInfusionTime) 秒")
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
        }
//        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    
                    Text("咖啡豆详情")
                        .font(.custom("Slideqiuhong", size: 30))
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
        HStack(alignment: .top) {
            MixedFontText(content: title, fontSize: 18)
                .font(.headline)
                .frame(width: 80, alignment: .leading)
            
            MixedFontText(content: value, fontSize: 16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 8)
    }
}

// 最佳参数卡片
struct BestParamCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(8)
    }
}

// 最佳参数行
struct BestParamRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

// 统计卡片
struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(8)
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

// MARK: - MOCK data for preview
struct CoffeeBeanDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let testBean = CoffeeBean(
            id: UUID(),
            name: "埃塞俄比亚耶加雪菲",
            brand: "星巴克",
            variety: "Heirloom",
            origin: "耶加雪菲, 埃塞俄比亚",
            processingMethod: "水洗",
            roastLevel: .light,
            flavors: ["柑橘", "花香", "莓果"],
            dateAdded: Date()
        )
        
        let brewRecordStore = BrewRecordStore()

        return NavigationView {
            CoffeeBeanDetailView(coffeeBean: testBean)
                .environmentObject(brewRecordStore)
        }
    }
}

