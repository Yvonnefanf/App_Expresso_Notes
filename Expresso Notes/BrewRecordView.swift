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
    
    // 鹅黄色背景颜色
    private let backgroundColor = Color(red: 253/255, green: 242/255, blue: 206/255)
    // 输入框背景颜色
    private let inputBackgroundColor = Color(red: 253/255, green: 246/255, blue: 227/255)
    // 按钮颜色
    private let buttonColor = Color(red: 249/255, green: 213/255, blue: 107/255)
    // 文本颜色
    private let textColor = Color(red: 49/255, green: 54/255, blue: 56/255)
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 咖啡豆选择
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("咖啡豆选择")
                                    .font(.headline)
                                    .foregroundColor(textColor)
                                Text("*")
                                    .foregroundColor(.red)
                            }
                            
                            // 咖啡豆选择器
                            coffeeBeanSelector
                        }
                        .padding(.top, 16)
                        
                        // 咖啡参数
                        VStack(alignment: .leading, spacing: 24) {
                            // 咖啡粉重量
                            parameterInputField(title: "咖啡粉重量(g)", binding: $coffeeWeight, placeholder: "输入重量", required: true)
                            
                            // 水温
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("水温")
                                        .font(.headline)
                                        .foregroundColor(textColor)
                                    Text("*")
                                        .foregroundColor(.red)
                                }
                                
                                HStack {
                                    Slider(value: $waterTemperature, in: 80...100, step: 1)
                                        .accentColor(buttonColor)
                                    
                                    Text("\(Int(waterTemperature))°C")
                                        .foregroundColor(textColor)
                                        .frame(width: 50)
                                }
                            }
                            
                            // 研磨度
                            parameterInputField(title: "研磨度", binding: $grindSize, placeholder: "输入研磨度", required: true)
                            
                            // 预浸泡时间
                            parameterInputField(title: "预浸泡时间(秒)", binding: $preInfusionTime, placeholder: "可选", required: false)
                            
                            // 萃取时间
                            parameterInputField(title: "萃取时间(秒)", binding: $extractionTime, placeholder: "输入时间", required: true)
                            
                            // 出液量
                            parameterInputField(title: "出液量(g)", binding: $yieldAmount, placeholder: "输入出液量", required: true)
                        }
                        
                        // 保存按钮
                        Button(action: prepareRecord) {
                            Text("保存记录")
                                .font(.headline)
                                .foregroundColor(textColor)
                                .frame(width: 160)
                                .padding(.vertical, 14)
                                .background(
                                    coffeeWeight.isEmpty || extractionTime.isEmpty || yieldAmount.isEmpty || grindSize.isEmpty 
                                    ? buttonColor.opacity(0.5) 
                                    : buttonColor
                                )
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        }
                        .disabled(coffeeWeight.isEmpty || extractionTime.isEmpty || yieldAmount.isEmpty || grindSize.isEmpty)
                        .padding(.vertical, 20)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                }
                .navigationTitle("记录萃取参数")
                .navigationBarItems(
//                    leading: Button(action: {
//                        dismiss()
//                        // 发送通知切换到主页
//                        NotificationCenter.default.post(name: .switchToTab, object: 0)
//                    }) {
//                        Image(systemName: "house.fill")
//                            .foregroundColor(textColor)
//                    },
                    trailing: Button(action: {
                        dismiss()
                        // 发送通知切换到主页
                        NotificationCenter.default.post(name: .switchToTab, object: 0)
                    }) {
                        Image(systemName: "house.fill")
                            .foregroundColor(textColor)
                    }
                )
                .sheet(isPresented: $showCoffeeBeanPicker) {
                    CoffeeBeanPickerView(selectedBean: $selectedCoffeeBean)
                         .environmentObject(beanManager)
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
    
    // 参数输入字段
    private func parameterInputField(title: String, binding: Binding<String>, placeholder: String, required: Bool) -> some View {
        HStack(alignment: .center) {
            // 标签
            HStack(spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(textColor)
                
                if required {
                    Text("*")
                        .foregroundColor(.red)
                }
            }
            .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            // 输入框
            TextField(placeholder, text: binding)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(inputBackgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .frame(maxWidth: .infinity)
        }
    }
    
    // 咖啡豆选择器
    private var coffeeBeanSelector: some View {
            VStack(alignment: .leading, spacing: 10) {
                if let bean = selectedCoffeeBean {
                    // 已选豆子视图
                } else {
                    Button(action: {
                        showCoffeeBeanPicker = true
                    }) {
                        HStack {
                            Text("选择咖啡豆")
                                .foregroundColor(textColor.opacity(0.7))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(red: 253/255, green: 246/255, blue: 227/255))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
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

// 咖啡豆选择器视图样式也更新
struct CoffeeBeanPickerView: View {
    @Binding var selectedBean: CoffeeBean?
    @EnvironmentObject var beanManager: CoffeeBeanManager
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    // 定义相同的颜色方案
    private let backgroundColor = Color(red: 253/255, green: 242/255, blue: 206/255)
    private let textColor = Color(red: 49/255, green: 54/255, blue: 56/255)
    
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
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
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
                                        .foregroundColor(textColor)
                                    
                                    Text(bean.brand)
                                        .font(.caption)
                                        .foregroundColor(textColor.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                if selectedBean?.id == bean.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
                .searchable(text: $searchText, prompt: "搜索咖啡豆")
            }
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
