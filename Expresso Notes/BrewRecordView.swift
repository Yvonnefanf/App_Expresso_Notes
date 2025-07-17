import SwiftUI

struct BrewRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var brewRecordStore: BrewRecordStore
    @EnvironmentObject var beanManager: CoffeeBeanManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @StateObject var beanViewModel = CoffeeBeanViewModel() // 新增
    
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
    @State private var showPurchasePopup = false
    @State private var isSaving = false
    
    // MARK: - 校验状态
    // 输入校验状态
    @State private var showErrorCoffeeBean = false
    @State private var showErrorCoffeeWeight = false
    @State private var showErrorGrindSize = false
    @State private var showErrorExtractionTime = false
    @State private var showErrorYieldAmount = false
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Color(red: 1, green: 1, blue: 1).ignoresSafeArea() // 强制白色背景，不受夜间模式影响
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - 咖啡豆选择表单
                        // 咖啡豆选择
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                MixedFontText(content: "咖啡豆",fontSize:18)
                                MixedFontText(content: "*",color:.red)
                            }
                            
                            // 咖啡豆选择器
                            coffeeBeanSelector
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(showErrorCoffeeBean ? Color.theme.errorHighlightColor : Color.gray.opacity(0.2))
                                )
                        }
                        .padding(.top, 16)
                        
                        VStack(alignment: .leading, spacing: 24) {
                            // 咖啡粉重量
                            parameterInputField(title: "咖啡粉重量(g)", binding: $coffeeWeight, placeholder: "输入重量", required: true, showError: showErrorCoffeeWeight, keyboardType: .decimalPad)
                            
                            // 水温
                            HStack(alignment: .center) {
                                // 标签
                                HStack(spacing: 2) {
                                    MixedFontText(content: "水温",fontSize:18)
                                    MixedFontText(content: "*",color:.red)
                                }
                                .frame(width: 130, alignment: .leading)
                                
                                Spacer()
                                
                                // 滑块和数值
                                HStack {
                                    Slider(value: $waterTemperature, in: 80...100, step: 1)
                                        .accentColor(Color.theme.sliderColor)
                                    
                                    Text("\(Int(waterTemperature))°C")
                                        .font(.custom("umeboshi", size: 16))
                                        .foregroundColor(Color.theme.textColor)
                                        .frame(width: 50)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            // 研磨度
                            parameterInputField(title: "研磨度", binding: $grindSize, placeholder: "输入研磨度", required: true, showError: showErrorGrindSize, keyboardType: .decimalPad)
                            
                            // 预浸泡时间
                            parameterInputField(title: "预浸泡时间(s)", binding: $preInfusionTime, placeholder: "输入时间", required: false, showError: false, keyboardType: .numberPad)
                            
                            // 萃取时间
                            parameterInputField(title: "萃取时间(s)", binding: $extractionTime, placeholder: "输入时间", required: true, showError: showErrorExtractionTime, keyboardType: .numberPad)
                            
                            // 出液量
                            parameterInputField(title: "出液量(g)", binding: $yieldAmount, placeholder: "输入出液量", required: true, showError: showErrorYieldAmount, keyboardType: .decimalPad)
                        }
                        
                        // 保存按钮始终可点
                        Button(action: validateAndPrepareRecord) {
                            MixedFontText(content: "保存记录")
                                .frame(width: 160)
                                .padding(.vertical, 14)
                                .background(Color.theme.buttonColor)
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
                                        .fontWeight(.bold).foregroundColor(Color.theme.textColorForTitle)
                                }
                                .foregroundColor(.primary)
                                .padding(.top, 16)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        BackButton(action: {
                            dismiss()
                            // 发送通知切换到主页
                            NotificationCenter.default.post(name: .switchToTab, object: 0)
                        })
                    }
                }
                .sheet(isPresented: $showCoffeeBeanPicker) {
                    CoffeeBeanPickerView(selectedBean: $selectedCoffeeBean, viewModel: beanViewModel)
                }
                
                // 评分弹窗覆盖层
                if showRatingPopup {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {} // 防止点击背景关闭
                    
                    ratingPopupView
                        .transition(.scale)
                }
                
                // 购买弹窗覆盖层
                if showPurchasePopup {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {} // 防止点击背景关闭
                    
                    purchasePopupView
                        .transition(.scale)
                        .zIndex(1000)
                }
                // 全屏保存中 loading 遮罩
                if isSaving {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {}
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.buttonColor))
                            .scaleEffect(1.5)
                        Text("保存中...")
                            .font(.system(size: 16))
                            .foregroundColor(Color.theme.textColor)
                    }
                    .padding(30)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .animation(.easeInOut, value: showRatingPopup)
        .animation(.easeInOut, value: showPurchasePopup)
        }
        .preferredColorScheme(.light)  // 强制使用白天模式，不受系统夜间模式影响
    }
    
    // MARK: - 评分
    private var ratingPopupView: some View {
        ScrollView {
            VStack(spacing: 24) {
//                Text("给你的咖啡打分")
//                    .font(.custom("平方江南体", size: 20))
//                    .fontWeight(.bold)
//                    .foregroundColor(textColor)
                
                Text("本次萃取评价反馈")
                    .font(.custom("平方江南体", size: 16))
                    .foregroundColor(Color.theme.textColor.opacity(0.7))
                
                // 评分滑块
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("评分")
                            .font(.custom("平方江南体", size: 18))
                            .foregroundColor(Color.theme.textColor)
                        Spacer()
                        Text(String(format: "%.1f", rating))
                            .font(.custom("平方江南体", size: 18))
                            .foregroundColor(Color.theme.textColor)
                    }
                    
                    Slider(value: $rating, in: 0...10, step: 0.1)
                        .accentColor(Color.theme.sliderColor)
                    
                }
                .padding(.vertical, 0)
                
                // 显示评分描述
                Text(systemRatingDescription(for: rating))
                    .font(.custom("平方江南体", size: 14))
                    .foregroundColor(Color.theme.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                // 个人评价输入
                VStack(alignment: .leading, spacing: 0) {
                    Text("反馈")
                        .font(.custom("平方江南体", size: 18))
                        .foregroundColor(Color.theme.textColor)
                    
                    ZStack(alignment: .topLeading) {
                        if ratingDescription.isEmpty {
                            Text("描述一下这次萃取的风味、口感等...")
                                .font(.system(size: 14))
                                .foregroundColor(Color.theme.textColor.opacity(0.5))
                                .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                        }
                        
                        TextEditor(text: $ratingDescription)
                            .font(.system(size: 14))
                            .foregroundColor(Color.theme.textColor)
                            .frame(minHeight: 100)
                            .padding(4)
                            .background(Color(red: 1, green: 1, blue: 1)) // 强制白色背景
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
                    
                    Button(action: saveRecordWithRating) {
                        Text("完成")
                    }
                    .font(.custom("平方江南体", size: 18))
                    .frame(width: 120)
                    .padding()
                    .foregroundColor(Color.theme.textColor)
                    .background(Color.theme.buttonColor)
                    .cornerRadius(8)
                    .disabled(isSaving)
                }
            }
            .padding()
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
        .background(Color(red: 1, green: 1, blue: 1)) // 强制白色背景
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal, 24)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
 // MARK: - 咖啡豆选择器
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
                                     
                                 
                                MixedFontText(content: bean.brand).opacity(0.7)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(red: 1, green: 1, blue: 1)) // 强制白色背景
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
                                .foregroundColor(Color.theme.disableColor.opacity(0.7))
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
        let grindSizeDouble = Double(grindSize) ?? 4.0
        
        tempRecord = BrewRecord(
            date: Date(),
            coffeeBean: selectedCoffeeBean != nil ? CoffeeBeanReference(from: selectedCoffeeBean!) : nil,
            coffeeWeight: coffeeWeight,
            waterTemperature: Int(waterTemperature),
            grindSize: grindSizeDouble,
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
        
        // 检查是否需要购买
        if !purchaseManager.canCreateNewRecord {
            showRatingPopup = false
            showPurchasePopup = true
            return
        }
      
        isSaving = true
        record.rating = rating
        record.ratingDescription = ratingDescription.isEmpty ? nil : ratingDescription
        brewRecordStore.addRecord(record) { error in
            isSaving = false
            if error == nil {
                dismiss()
            } else {
                // 可选：显示错误提示
            }
        }
        
        // 使用免费机会（如果未解锁）
        if !purchaseManager.isUnlocked {
            purchaseManager.useFreeAttempt()
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
    
    // MARK: - 购买弹窗视图
    private var purchasePopupView: some View {
        VStack(spacing: 24) {
            // 标题
            VStack(spacing: 8) {
                Image("nobgbean")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                
                Text("解锁完整版")
                    .font(.custom("Slideqiuhong", size: 24))
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.textColor)
            }
            
            // 说明文字
            VStack(spacing: 12) {
                Text("您已使用完 3 次免费记录机会")
                    .font(.custom("平方江南体", size: 16))
                    .foregroundColor(Color.theme.textColor)
                    .multilineTextAlignment(.center)
                
                Text("购买完整版获得：")
                    .font(.custom("平方江南体", size: 14))
                    .foregroundColor(Color.theme.textColor.opacity(0.7))
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("无限制创建萃取记录")
                            .font(.custom("平方江南体", size: 14))
                            .foregroundColor(Color.theme.textColor)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("永久保存所有数据")
                            .font(.custom("平方江南体", size: 14))
                            .foregroundColor(Color.theme.textColor)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("一次购买，终身使用")
                            .font(.custom("平方江南体", size: 14))
                            .foregroundColor(Color.theme.textColor)
                    }
                }
                .padding(.leading, 16)
            }
            
            // 价格信息
            if let product = purchaseManager.products.first {
                VStack(spacing: 4) {
                    Text(product.displayPrice)
                        .font(.custom("umeboshi", size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.textColor)
                    
                    Text("一次性购买")
                        .font(.custom("平方江南体", size: 12))
                        .foregroundColor(Color.theme.textColor.opacity(0.6))
                }
            }
            
            // 按钮组
            VStack(spacing: 16) {
                // 购买按钮
                Button(action: {
                    Task {
                        await purchaseManager.purchaseUnlock()
                        if purchaseManager.isUnlocked {
                            showPurchasePopup = false
                            // 自动保存记录
                            saveRecordWithRating()
                        }
                    }
                }) {
                    HStack {
                        if case .purchasing = purchaseManager.purchaseStatus {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(Color.theme.textColor)
                        }
                        Text(purchaseButtonText)
                            .font(.custom("平方江南体", size: 16))
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.theme.buttonColor)
                    .foregroundColor(Color.theme.textColor.opacity(0.8))
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .disabled(isPurchasing)
                
                // 取消按钮
                Button(action: {
                    showPurchasePopup = false
                }) {
                    Text("暂不购买")
                        .font(.custom("平方江南体", size: 16))
                        .foregroundColor(Color.theme.textColor.opacity(0.6))
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 40)
    }
    
    // MARK: - 计算属性
    private var purchaseButtonText: String {
        if case .purchasing = purchaseManager.purchaseStatus {
            return "购买中..."
        } else {
            return "立即购买"
        }
    }
    
    private var isPurchasing: Bool {
        if case .purchasing = purchaseManager.purchaseStatus {
            return true
        } else {
            return false
        }
    }
    
    private var isLoading: Bool {
        if case .loading = purchaseManager.purchaseStatus {
            return true
        } else {
            return false
        }
    }
}

// 咖啡豆选择器视图
struct CoffeeBeanPickerView: View {
    @Binding var selectedBean: CoffeeBean?
    @ObservedObject var viewModel: CoffeeBeanViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    let textColor = Color(red: 134/255, green: 86/255, blue: 56/255).opacity(0.8)
    
    var filteredBeans: [CoffeeBean] {
        if searchText.isEmpty {
            return viewModel.beans
        } else {
            return viewModel.beans.filter { bean in
                bean.name.localizedCaseInsensitiveContains(searchText) ||
                bean.brand.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1, green: 1, blue: 1).ignoresSafeArea() // 强制白色背景，不受夜间模式影响
                // Color.theme.backgroundColor.edgesIgnoringSafeArea(.all)
                
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
                                        .foregroundColor(Color.theme.textColor)
                                    
                                    MixedFontText(content:bean.brand)
                                        .foregroundColor(Color.theme.textColor.opacity(0.7))
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
        .onAppear {
            viewModel.subscribe()
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
            .environmentObject(PurchaseManager())
    }
} 
