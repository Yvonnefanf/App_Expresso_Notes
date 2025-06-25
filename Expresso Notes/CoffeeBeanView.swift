//
//  Expresso_NotesApp.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 25/3/25.
//

import SwiftUI

// 咖啡豆数据模型
struct CoffeeBean: Identifiable, Codable {
    var id = UUID()
    var name: String
    var brand: String
    var variety: String
    var origin: String
    var processingMethod: String
    var roastLevel: RoastLevel
    var flavors: [String]
    var dateAdded: Date
    
    enum RoastLevel: String, Codable, CaseIterable {
        case light = "浅焙"
        case medium = "中焙"
        case dark = "深焙"
    }
    
}

// 咖啡豆管理器 - 处理数据存储和加载
class CoffeeBeanManager: ObservableObject {
    @Published var coffeeBeans: [CoffeeBean] = []
    
    init() {
        loadCoffeeBeans()
    }
    
    func addCoffeeBean(_ coffeeBean: CoffeeBean) {
        coffeeBeans.append(coffeeBean)
        saveCoffeeBeans()
    }
    
    func deleteCoffeeBean(at indexSet: IndexSet) {
        coffeeBeans.remove(atOffsets: indexSet)
        saveCoffeeBeans()
    }
    
    private func saveCoffeeBeans() {
        // 这里暂时使用 UserDefaults，实际应用中可能需要连接到 Firebase
        if let encoded = try? JSONEncoder().encode(coffeeBeans) {
            UserDefaults.standard.set(encoded, forKey: "coffeeBeans")
        }
    }
    
    private func loadCoffeeBeans() {
        // 从 UserDefaults 加载数据
        if let data = UserDefaults.standard.data(forKey: "coffeeBeans"),
           let decoded = try? JSONDecoder().decode([CoffeeBean].self, from: data) {
            coffeeBeans = decoded
        }
    }
}

struct CoffeeBeanView: View {
    @EnvironmentObject var beanManager: CoffeeBeanManager
    @State private var showingAddSheet = false
    @Environment(\.presentationMode) var presentationMode
    
    // 定义网格布局
    private let gridItems = [
        GridItem(.adaptive(minimum: 130, maximum: 150), spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 15) {
                    // 显示已有的咖啡豆卡片，放在前面
                    ForEach(beanManager.coffeeBeans) { bean in
                        NavigationLink(destination: CoffeeBeanDetailView(coffeeBean: bean)) {
                            CoffeeBeanCard(coffeeBean: bean)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // 添加新咖啡豆的按钮，放在最后
                    AddCoffeeBeanButton(action: {
                        showingAddSheet = true
                    })
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        // 居中标题
                        ToolbarItem(placement: .principal) {
                                  HStack(spacing: 8) {
                                              Image("nobgbean")
                                                  .resizable()
                                                  .scaledToFit()
                                                  .frame(width: 50, height: 50).padding(.top, 4)

                                              MixedFontText(content: "咖啡豆", fontSize: 30)
                                                  .fontWeight(.bold).foregroundColor(Color.theme.textColorForTitle)
                                          }
                                          .foregroundColor(.primary)
                                          .padding(.top, 16)
                              }

                        // 右侧按钮
                        ToolbarItem(placement: .topBarLeading) {
                            Button(action: {
                                // 先发送通知切换到主页
                                NotificationCenter.default.post(name: .switchToTab, object: 0)
                                // 关闭当前视图
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.backward")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20) // 👈 控制大小
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.theme.iconColor)
                                    .padding(.top, 16)
                            }
                        }
                    }
            
            .sheet(isPresented: $showingAddSheet) {
                // 这里传入的 beanManager 也改成环境注入
                AddCoffeeBeanView()
                    .environmentObject(beanManager)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// 虚线加号按钮
struct AddCoffeeBeanButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundColor(Color(red: 240.0/255.0,
                                               green: 187.0/255.0,
                                               blue: 144.0/255.0))
                        .frame(width: 120, height: 160)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 240.0/255.0,
                                                   green: 187.0/255.0,
                                                   blue: 144.0/255.0))
                        
                        MixedFontText(content: "添加新咖啡豆", fontSize: 12)
                            .foregroundColor(Color(red: 240.0/255.0,
                                                   green: 187.0/255.0,
                                                   blue: 144.0/255.0))
                        
                        
                    }
                }
            }
            .frame(width: 120)
            .padding(.bottom, 5)
        }
    }
}

// 咖啡豆卡片
struct CoffeeBeanCard: View {
    var coffeeBean: CoffeeBean
    
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
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // 添加烘焙度对应的图片
            Image(roastImage)
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
            
            MixedFontText(content: coffeeBean.name, fontSize: 12)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.top, 2)
        }
        .frame(width: 120)
        .padding(.bottom, 5)
    }
}

// 添加新咖啡豆的表单
struct AddCoffeeBeanView: View {
    @EnvironmentObject var beanManager: CoffeeBeanManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var brand = ""
    @State private var variety = ""
    @State private var origin = ""
    @State private var processingMethod = ""
    @State private var roastLevel = CoffeeBean.RoastLevel.medium
    @State private var flavors = ""
    
    let flavorSuggestions = ["柑橘", "巧克力", "坚果", "花香", "浆果", "焦糖", "水果", "清新", "醇厚"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 24) {
                    // 基本信息
                    parameterInputField(title: "咖啡豆名字", binding: $name, placeholder: "输入咖啡豆名字", required: true, showError: false)
                    parameterInputField(title: "品牌", binding: $brand, placeholder: "输入品牌", required: true, showError: false)
                    
                    // 详细信息（可选）
                    parameterInputField(title: "品种", binding: $variety, placeholder: "输入品种", required: false, showError: false)
                    parameterInputField(title: "产地", binding: $origin, placeholder: "输入产地", required: false, showError: false)
                    parameterInputField(title: "处理方式", binding: $processingMethod, placeholder: "输入处理方式", required: false, showError: false)
                    
                    // 烘焙度
                    HStack(alignment: .center) {
                        MixedFontText(content: "烘焙度", fontSize: 18)
                            .foregroundColor(Color.theme.textColor)
                            .frame(width: 130, alignment: .leading)
                        
                        Spacer()
                        
                        Picker("烘焙度", selection: $roastLevel) {
                            ForEach(CoffeeBean.RoastLevel.allCases, id: \.self) { level in
                                MixedFontText(content: level.rawValue, fontSize: 16).tag(level)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(maxWidth: .infinity)
                    }
                    
                    // 口感
                    VStack(alignment: .leading, spacing: 8) {
                        MixedFontText(content: "口感", fontSize: 18)
                            .foregroundColor(Color.theme.textColor)
                        
                        parameterInputField(title: "", binding: $flavors, placeholder: "口感特点，用逗号分隔", required: false, showError: false, labelWidth: 0)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(flavorSuggestions, id: \.self) { flavor in
                                    Button(action: {
                                        if flavors.isEmpty {
                                            flavors = flavor
                                        } else {
                                            flavors += ", " + flavor
                                        }
                                    }) {
                                        MixedFontText(content: flavor, fontSize: 14)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.theme.themeColor.opacity(0.5))
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                
                // 保存按钮
                Button(action: saveBean) {
                    MixedFontText(content: "保存", fontSize: 18)
                        .foregroundColor(Color.theme.textColor)
                        .frame(width: 160)
                        .padding(.vertical, 14)
                        .background(Color.theme.buttonColor)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .disabled(name.isEmpty || brand.isEmpty)
                .padding(.vertical, 20)
            }
//            .navigationTitle("添加咖啡豆")
            .navigationBarTitleDisplayMode(.inline) // 设置为中间小标题模式
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {

                                Text("添加咖啡豆")
                                    .font(.custom("Slideqiuhong", size: 30))
                                    .fontWeight(.bold).foregroundColor(Color.theme.textColorForTitle)
                            }
                            .foregroundColor(.primary)
                            .padding(.top, 16)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    BackButton(action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
        }
    }
    
    private func saveBean() {
        let flavorArray = flavors
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let newBean = CoffeeBean(
            name: name,
            brand: brand,
            variety: variety,
            origin: origin,
            processingMethod: processingMethod,
            roastLevel: roastLevel,
            flavors: flavorArray,
            dateAdded: Date()
        )
        
        beanManager.addCoffeeBean(newBean)
        presentationMode.wrappedValue.dismiss()
    }
}

// 咖啡豆详情视图
struct CoffeeBeanDetailView: View {
    var coffeeBean: CoffeeBean
    @Environment(\.presentationMode) var presentationMode
    
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
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // 返回到咖啡豆列表
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(red: 0.96, green: 0.93, blue: 0.88))
                }
            }
            
            ToolbarItem(placement: .principal) {
                HStack {
                    Image("coffee_bean")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                    MixedFontText(content: "咖啡豆详情", fontSize: 18)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private func detailSection(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            MixedFontText(content: title, fontSize: 18)
                .font(.headline)
            MixedFontText(content: value, fontSize: 16)
                .padding(.bottom, 8)
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

#Preview {
    CoffeeBeanView()
        .environmentObject(CoffeeBeanManager())
}
