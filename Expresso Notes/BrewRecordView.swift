import SwiftUI

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.custom("平方江南体", size: 16))
    }
}


struct BrewRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var brewRecordStore: BrewRecordStore
    @EnvironmentObject var beanManager: CoffeeBeanManager
    
    @State private var selectedCoffeeBean: CoffeeBean?
    @State private var coffeeWeight: String = ""
    @State private var waterTemperature: Double = 92.0
    @State private var grindSize: String = ""
    @State private var preInfusionTime: String = ""
    @State private var extractionTime: String = ""
    @State private var yieldAmount: String = ""
    @State private var rating: Double = 7.0
    @State private var ratingDescription: String = ""
    @State private var showRatingPopup = false
    @State private var tempRecord: BrewRecord? = nil
    @State private var showCoffeeBeanPicker = false
    
    // 鹅黄色背景颜色
    private let backgroundColor = Color(red: 255/255, green: 255/255, blue: 255/255 ).opacity(0.6)
    // slider 背景颜色
    private let sliderColor = Color(red: 251/255, green: 240/255, blue: 210/255 )
    // 输入框背景颜色
    
    private let inputBackgroundColor = Color(red: 252/255, green: 239/255, blue: 201/255)
    // 按钮颜色
    private let buttonColor = Color(red: 252/255, green: 240/255, blue: 201/255)
    
    private let disableColor = Color(red: 162/255, green: 160/255, blue: 154/255)
    // 文本颜色
    private let textColor = Color(red: 134/255, green: 86/255, blue: 56/255).opacity(0.8)
    let textColorForTitle = Color(red: 134/255, green: 86/255, blue: 56/255)
    let iconColor = Color(red: 162/255, green: 160/255, blue: 154/255)
    
    // 定义错误高亮颜色
    private let errorHighlightColor = Color(red: 255/255, green: 0/255, blue: 0/255)

    // 新增：输入校验状态
    @State private var showErrorCoffeeBean = false
    @State private var showErrorCoffeeWeight = false
    @State private var showErrorGrindSize = false
    @State private var showErrorExtractionTime = false
    @State private var showErrorYieldAmount = false
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 咖啡豆选择
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("咖啡豆")
                                    .font(.custom("平方江南体", size: 18))
                                    .foregroundColor(textColor)
                                Text("*")
                                    .font(.custom("平方江南体", size: 18))
                                    .foregroundColor(.red)
                            }
                            
                            // 咖啡豆选择器
                            coffeeBeanSelector
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(showErrorCoffeeBean ? errorHighlightColor : Color.gray.opacity(0.2))
                                )
                        }
                        .padding(.top, 16)
                        
                        // 咖啡参数
                        VStack(alignment: .leading, spacing: 24) {
                            // 咖啡粉重量
                            parameterInputField(title: "咖啡粉重量(g)", binding: $coffeeWeight, placeholder: "输入重量", required: true, showError: showErrorCoffeeWeight)
                            
                            // 水温
                            HStack(alignment: .center) {
                                // 标签
                                HStack(spacing: 2) {
                                    Text("水温")
                                        .font(.custom("平方江南体", size: 18))
                                        .foregroundColor(textColor)
                                    Text("*")
                                        .font(.custom("平方江南体", size: 18))
                                        .foregroundColor(.red)
                                }
                                .frame(width: 130, alignment: .leading)
                                
                                Spacer()
                                
                                // 滑块和数值
                                HStack {
                                    Slider(value: $waterTemperature, in: 80...100, step: 1)
                                        .accentColor(sliderColor)
                                    
                                    Text("\(Int(waterTemperature))°C")
                                        .font(.custom("umeboshi", size: 16))
                                        .foregroundColor(textColor)
                                        .frame(width: 50)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            // 研磨度
                            parameterInputField(title: "研磨度", binding: $grindSize, placeholder: "输入研磨度", required: true, showError: showErrorGrindSize)
                            
                            // 预浸泡时间
                            parameterInputField(title: "预浸泡时间(s)", binding: $preInfusionTime, placeholder: "输入时间", required: false, showError: false)
                            
                            // 萃取时间
                            parameterInputField(title: "萃取时间(s)", binding: $extractionTime, placeholder: "输入时间", required: true, showError: showErrorExtractionTime)
                            
                            // 出液量
                            parameterInputField(title: "出液量(g)", binding: $yieldAmount, placeholder: "输入出液量", required: true, showError: showErrorYieldAmount)
                        }
                        
                        // 保存按钮始终可点
                        Button(action: validateAndPrepareRecord) {
                            Text("保存记录")
                                .font(.custom("平方江南体", size: 18))
                                .foregroundColor(textColor)
                                .frame(width: 160)
                                .padding(.vertical, 14)
                                .background(buttonColor)
                                .cornerRadius(25)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                        }
                        .padding(.vertical, 20)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                }
                .navigationBarTitleDisplayMode(.inline) // 设置为中间小标题模式
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 8) {
                                    Image("nobgbean") // 可替换为你想要的咖啡豆图标
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50).padding(.top, 4)

                                    Text("参数记录")
                                        .font(.custom("Slideqiuhong", size: 30))
                                        .fontWeight(.bold).foregroundColor(textColorForTitle)
                                }
                                .foregroundColor(.primary)
                                .padding(.top, 16)
                    }
                }
                .navigationBarItems(
                    leading: Button(action: {
                        dismiss()
                        // 发送通知切换到主页
                        NotificationCenter.default.post(name: .switchToTab, object: 0)
                    }) {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20) // 👈 控制大小
                            .fontWeight(.bold)           // 👈 更粗（仅适用于某些系统图标）
                            .foregroundColor(iconColor)
                            .padding(.top, 16)
                    }
                )
                .sheet(isPresented: $showCoffeeBeanPicker) {
                    CoffeeBeanPickerView(selectedBean: $selectedCoffeeBean)
                         .environmentObject(beanManager)
                  }
                
                // 评分弹窗覆盖层
                if showRatingPopup {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {} // 防止点击背景关闭
                    
                    ratingPopupView
                        .transition(.scale)
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .animation(.easeInOut, value: showRatingPopup)
        }
    }
    
    // 评分弹窗视图
    private var ratingPopupView: some View {
        ScrollView {
            VStack(spacing: 24) {
//                Text("给你的咖啡打分")
//                    .font(.custom("平方江南体", size: 20))
//                    .fontWeight(.bold)
//                    .foregroundColor(textColor)
                
                Text("本次萃取评价反馈")
                    .font(.custom("平方江南体", size: 16))
                    .foregroundColor(textColor.opacity(0.7))
                
                // 评分滑块
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("评分")
                            .font(.custom("平方江南体", size: 18))
                            .foregroundColor(textColor)
                        Spacer()
                        Text(String(format: "%.1f", rating))
                            .font(.custom("平方江南体", size: 18))
                            .foregroundColor(textColor)
                    }
                    
                    Slider(value: $rating, in: 0...10, step: 0.1)
                        .accentColor(sliderColor)
                    
                }
                .padding(.vertical, 0)
                
                // 显示评分描述
                Text(systemRatingDescription(for: rating))
                    .font(.custom("平方江南体", size: 14))
                    .foregroundColor(textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                // 个人评价输入
                VStack(alignment: .leading, spacing: 0) {
                    Text("反馈")
                        .font(.custom("平方江南体", size: 18))
                        .foregroundColor(textColor)
                    
                    ZStack(alignment: .topLeading) {
                        if ratingDescription.isEmpty {
                            Text("描述一下这次萃取的风味、口感等...")
                                .font(.custom("平方江南体", size: 14))
                                .foregroundColor(textColor.opacity(0.5))
                                .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                        }
                        
                        TextEditor(text: $ratingDescription)
                            .font(.custom("平方江南体", size: 14))
                            .frame(minHeight: 100)
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.vertical, 0)
                
                // 按钮
                HStack(spacing: 16) {
//                    Button("取消") {
//                        showRatingPopup = false
//                    }
//                    .frame(width: 120)
//                    .padding()
//                    .foregroundColor(textColor)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(textColor, lineWidth: 1)
//                    )
                    
                    Button("完成") {
                        saveRecordWithRating()
                    }
                    .frame(width: 120)
                    .padding()
                    .foregroundColor(textColor)
                    .background(buttonColor)
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal, 24)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // 咖啡豆选择器
    private var coffeeBeanSelector: some View {
            VStack(alignment: .leading, spacing: 10) {
                if let bean = selectedCoffeeBean {
                    // 已选豆子视图
                    Button(action: {
                        showCoffeeBeanPicker = true
                    }) {
                        HStack(spacing: 15) {
                            Image(getRoastImage(for: bean.roastLevel))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                MixedFontText(content: bean.name)
                                     .fontWeight(.medium)
                                     .foregroundColor(textColor)
                                 
                                 MixedFontText(content: bean.brand)
                                     .foregroundColor(textColor.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: {
                        showCoffeeBeanPicker = true
                    }) {
                        HStack {
                            Text("选择咖啡豆")
                                .font(.custom("平方江南体", size: 16))
                                .foregroundColor(disableColor.opacity(0.7))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(red: 255/255, green: 255/255, blue: 255/255))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
        }
    
    // 校验并准备记录
    func validateAndPrepareRecord() {
        // 校验
        showErrorCoffeeBean = (selectedCoffeeBean == nil)
        showErrorCoffeeWeight = coffeeWeight.isEmpty
        showErrorGrindSize = grindSize.isEmpty
        showErrorExtractionTime = extractionTime.isEmpty
        showErrorYieldAmount = yieldAmount.isEmpty
        
        let hasError = showErrorCoffeeBean || showErrorCoffeeWeight || showErrorGrindSize || showErrorExtractionTime || showErrorYieldAmount
        if hasError {
            // 有错误，不提交
            return
        }
        // 无错误，正常提交
        prepareRecord()
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
        showRatingPopup = true
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
    
    // 评分描述函数
    func systemRatingDescription(for rating: Double) -> String {
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
}

// 咖啡豆选择器视图
struct CoffeeBeanPickerView: View {
    @Binding var selectedBean: CoffeeBean?
    @EnvironmentObject var beanManager: CoffeeBeanManager
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    // 定义相同的颜色方案
    private let backgroundColor = Color(red: 255/255, green: 255/255, blue: 255/255 )
    let textColor = Color(red: 134/255, green: 86/255, blue: 56/255).opacity(0.8)
    
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
//                Color.white.ignoresSafeArea() // 强制白色背景，不受夜间模式影响
                backgroundColor.edgesIgnoringSafeArea(.all)
                
//
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
                                    MixedFontText(content: bean.name)
                                        .fontWeight(.medium)
                                        .foregroundColor(textColor)
                                    
                                    MixedFontText(content:bean.brand)
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
            
            .navigationBarTitleDisplayMode(.inline) // 设置为中间小标题模式
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("咖啡豆")
                        .font(.title2)
                        .fontWeight(.semibold)// 可改为 .subheadline 或 .footnote 以更小
                        .foregroundColor(.primary)
                        .padding(.top, 6) // 控制下移距离
                }
            }
////            .navigationTitle("选择咖啡豆")
            .navigationBarItems(trailing:
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark") // 或改成 "xmark" 看你想要哪种
                        .foregroundColor(.primary)
                        .imageScale(.medium)
                }
            )
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
