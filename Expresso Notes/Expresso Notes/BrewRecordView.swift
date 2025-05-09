import SwiftUI

struct BrewRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var brewRecordStore: BrewRecordStore
    @EnvironmentObject var beanManager: CoffeeBeanManager
    
    @State private var selectedCoffeeBean: CoffeeBean?
    @State private var coffeeWeight: String = ""
    @State private var waterTemperature: Double = 92.0
    @State private var grindSize: String = "4"
    @State private var preInfusionTime: String = ""
    @State private var extractionTime: String = ""
    @State private var yieldAmount: String = ""
    @State private var rating: Double = 7.0
    @State private var ratingDescription: String = ""
    @State private var showRatingView = false
    @State private var tempRecord: BrewRecord? = nil
    @State private var showCoffeeBeanPicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    // 咖啡豆选择器
                    Section(header: Text("咖啡豆选择")) {
                        coffeeBeanSelector
                    }
                    
                    Section(header: Text("咖啡参数")) {
                        HStack {
                            Text("咖啡粉重量(g)")
                            TextField("输入重量", text: $coffeeWeight)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("水温")
                                Spacer()
                                Text("\(Int(waterTemperature))°C")
                            }
                            Slider(value: $waterTemperature, in: 80...100, step: 1)
                        }
                        
                        HStack {
                            Text("研磨度")
                            TextField("输入研磨度", text: $grindSize)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("预浸泡时间(秒)")
                            TextField("可选", text: $preInfusionTime)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("萃取时间(秒)")
                            TextField("输入时间", text: $extractionTime)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("出液量(g)")
                            TextField("输入出液量", text: $yieldAmount)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    Button(action: prepareRecord) {
                        Text("保存记录")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(red: 0.6, green: 0.4, blue: 0.2))
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.vertical)
                    .disabled(coffeeWeight.isEmpty || extractionTime.isEmpty || yieldAmount.isEmpty || grindSize.isEmpty)
                }
                .navigationTitle("记录萃取参数")
                .navigationBarItems(trailing: Button("关闭") {
                    dismiss()
                })
                .sheet(isPresented: $showCoffeeBeanPicker) {
                    CoffeeBeanPickerView(selectedBean: $selectedCoffeeBean, beanManager: beanManager)
                }
                
                // 评分弹窗覆盖层
                if showRatingView {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {} // 防止点击背景关闭
                    
                    RatingView(rating: $rating, description: $ratingDescription, onSave: {
                        saveRecordWithRating()
                    })
                    .transition(.scale)
                }
            }
            .animation(.easeInOut, value: showRatingView)
        }
    }
    
    // 咖啡豆选择器
    private var coffeeBeanSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 选择器标题和按钮
            HStack {
                Text("选择咖啡豆")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showCoffeeBeanPicker = true
                }) {
                    Text(selectedCoffeeBean == nil ? "选择" : "更换")
                        .foregroundColor(.blue)
                }
            }
            
            // 显示已选择的咖啡豆
            if let bean = selectedCoffeeBean {
                HStack(spacing: 12) {
                    // 烘焙度图片
                    Image(getRoastImage(for: bean.roastLevel))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(bean.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(bean.brand)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 移除按钮
                    Button(action: {
                        selectedCoffeeBean = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            } else {
                Text("未选择咖啡豆")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 6)
            }
        }
    }
    
    // 准备记录并显示评分弹窗
    func prepareRecord() {
        // 创建临时记录
        let grindSizeInt = Int(grindSize) ?? 4
        
        tempRecord = BrewRecord(
            date: Date(),
            coffeeBean: selectedCoffeeBean != nil ? CoffeeBeanReference(from: selectedCoffeeBean!) : nil,
            coffeeWeight: coffeeWeight,
            waterTemperature: Int(waterTemperature),
            grindSize: grindSizeInt,
            preInfusionTime: preInfusionTime,
            extractionTime: extractionTime,
            yieldAmount: yieldAmount
        )
        
        // 显示评分弹窗
        showRatingView = true
    }
    
    // 保存带评分的记录
    func saveRecordWithRating() {
        guard var record = tempRecord else { return }
        record.rating = rating
        record.ratingDescription = ratingDescription.isEmpty ? nil : ratingDescription
        brewRecordStore.addRecord(record)
        
        // 短暂延迟后关闭表单，使评分弹窗消失动画有时间完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
        }
    }
    
    // 获取烘焙度对应的图片名称
    private func getRoastImage(for roastLevel: CoffeeBean.RoastLevel) -> String {
        switch roastLevel {
        case .light:
            return "qianhong"
        case .medium:
            return "zhonghong"
        case .dark:
            return "shenhong"
        }
    }
}

// 咖啡豆选择器视图
struct CoffeeBeanPickerView: View {
    @Binding var selectedBean: CoffeeBean?
    @ObservedObject var beanManager: CoffeeBeanManager
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    var filteredBeans: [CoffeeBean] {
        if searchText.isEmpty {
            return beanManager.coffeeBeans
        } else {
            return beanManager.coffeeBeans.filter { bean in
                bean.name.localizedCaseInsensitiveContains(searchText) ||
                bean.brand.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredBeans) { bean in
                    Button(action: {
                        selectedBean = bean
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(getRoastImage(for: bean.roastLevel))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(bean.name)
                                    .fontWeight(.medium)
                                
                                Text(bean.brand)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedBean?.id == bean.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(InsetGroupedListStyle())
            .searchable(text: $searchText, prompt: "搜索咖啡豆")
            .navigationTitle("选择咖啡豆")
            .navigationBarItems(trailing: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // 获取烘焙度对应的图片名称
    private func getRoastImage(for roastLevel: CoffeeBean.RoastLevel) -> String {
        switch roastLevel {
        case .light:
            return "qianhong"
        case .medium:
            return "zhonghong"
        case .dark:
            return "shenhong"
        }
    }
}

struct BrewRecordView_Previews: PreviewProvider {
    static var previews: some View {
        BrewRecordView()
            .environmentObject(BrewRecordStore())
            .environmentObject(CoffeeBeanManager())
    }
} 
