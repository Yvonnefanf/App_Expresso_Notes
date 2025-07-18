//
//  Expresso_NotesApp.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 25/3/25.
//

import SwiftUI
import FirebaseAuth

// 咖啡豆管理器 - 处理数据存储和加载
class CoffeeBeanManager: ObservableObject {
    @Published var coffeeBeans: [CoffeeBean] = []
    
    // 获取当前用户的保存key
    private var saveKey: String {
        let userId = Auth.auth().currentUser?.uid ?? "anonymous"
        return "coffeeBeans_\(userId)"
    }
    
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
    
    // 获取指定咖啡豆的最佳参数
    func getBestParameters(for coffeeBeanId: UUID, from brewRecordStore: BrewRecordStore) -> BestParameters? {
        return brewRecordStore.getBestParametersForCoffeeBean(coffeeBeanId)
    }
    
    // 获取指定咖啡豆的所有记录数量
    func getRecordCount(for coffeeBeanId: UUID, from brewRecordStore: BrewRecordStore) -> Int {
        return brewRecordStore.getRecordsForCoffeeBean(coffeeBeanId).count
    }
    
    // 当用户切换时重新加载数据
    func reloadForCurrentUser() {
        loadCoffeeBeans()
    }
    
    private func saveCoffeeBeans() {
        // 这里暂时使用 UserDefaults，实际应用中可能需要连接到 Firebase
        if let encoded = try? JSONEncoder().encode(coffeeBeans) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
            print("✅ 成功保存 \(coffeeBeans.count) 个咖啡豆 (用户: \(Auth.auth().currentUser?.uid ?? "anonymous"))")
        }
    }
    
    private func loadCoffeeBeans() {
        // 从 UserDefaults 加载数据
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([CoffeeBean].self, from: data) {
            coffeeBeans = decoded
            print("✅ 成功加载 \(coffeeBeans.count) 个咖啡豆 (用户: \(Auth.auth().currentUser?.uid ?? "anonymous"))")
        } else {
            coffeeBeans = []
            print("ℹ️ 没有找到保存的咖啡豆数据，初始化为空数组 (用户: \(Auth.auth().currentUser?.uid ?? "anonymous"))")
        }
    }
}

struct CoffeeBeanView: View {
    @StateObject var viewModel = CoffeeBeanViewModel()
    @EnvironmentObject var brewRecordStore: BrewRecordStore
    @State private var showingAddSheet = false
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteAlert = false // 新增
    @State private var beanToDelete: CoffeeBean? = nil // 新增
    
    // 定义网格布局
    private let gridItems = [
        GridItem(.adaptive(minimum: 130, maximum: 150), spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                Color.theme.backgroundColor.ignoresSafeArea()
                LazyVGrid(columns: gridItems, spacing: 15) {
                    ForEach(viewModel.beans) { bean in
                        NavigationLink(destination: CoffeeBeanDetailView(coffeeBean: bean)
                            .environmentObject(brewRecordStore)
                        ) {
                            CoffeeBeanCard(coffeeBean: bean)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button(role: .destructive) {
                                viewModel.delete(bean)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                    }
                    AddCoffeeBeanButton(action: {
                        showingAddSheet = true
                    })
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
                ToolbarItem(placement: .cancellationAction) {
                    BackButton(action: {
                        NotificationCenter.default.post(name: .switchToTab, object: 0)
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddCoffeeBeanView(viewModel: viewModel)
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("删除咖啡豆"),
                    message: Text("确定要删除该咖啡豆吗？此操作不可恢复。"),
                    primaryButton: .destructive(Text("删除")) {
                        if let bean = beanToDelete {
                            viewModel.delete(bean)
                        }
                        beanToDelete = nil
                    },
                    secondaryButton: .cancel {
                        beanToDelete = nil
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            viewModel.subscribe()
        }
    }
}

// MARK: - 添加咖啡豆
struct AddCoffeeBeanButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(Color.theme.textColor.opacity(0.3))
                        .frame(width: 120, height: 160)
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 40))
                            .foregroundColor(Color.theme.textColor.opacity(0.3))
                        MixedFontText(content: "添加咖啡豆", fontSize: 18)
                    }
                }
            }
            .frame(width: 120)
            .padding(.bottom, 5)
        }
    }
}

// MARK: - 咖啡豆卡片
struct CoffeeBeanCard: View {
    var coffeeBean: CoffeeBean
    
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
            Image(roastImage)
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
            MixedFontText(content: coffeeBean.name, fontSize: 18)
                .fontWeight(.medium)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding(.top, -8)
        }
        .frame(width: 120)
        .padding(.bottom, 5)
    }
}

// 添加新咖啡豆的表单
struct AddCoffeeBeanView: View {
    @ObservedObject var viewModel: CoffeeBeanViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var brand = ""
    @State private var variety = ""
    @State private var origin = ""
    @State private var processingMethod = ""
    @State private var roastLevel = CoffeeBean.RoastLevel.medium
    @State private var flavors = ""
    @State private var keyboardHeight: CGFloat = 0 // 新增
    
    let flavorSuggestions = ["柑橘", "巧克力", "坚果", "花香", "浆果", "焦糖", "水果", "清新", "醇厚", "牛奶", "烟草","茶香","玫瑰"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 24) {
                        parameterInputField(title: "咖啡豆名字", binding: $name, placeholder: "输入咖啡豆名称", required: true, showError: false)
                        parameterInputField(title: "品牌", binding: $brand, placeholder: "输入品牌", required: false, showError: false)
                        parameterInputField(title: "品种", binding: $variety, placeholder: "输入品种", required: false, showError: false)
                        parameterInputField(title: "产地", binding: $origin, placeholder: "输入产地", required: false, showError: false)
                        parameterInputField(title: "处理方式", binding: $processingMethod, placeholder: "输入处理方式", required: false, showError: false)
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
                        VStack(alignment: .leading, spacing: 8) {
                            MixedFontText(content: "口感", fontSize: 18)
                                .foregroundColor(Color.theme.textColor)
                            parameterInputField(title: "", binding: $flavors, placeholder: "口感特点", required: false, showError: false, labelWidth: 0)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
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
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .frame(height: 35)
                            .padding(.vertical, 5)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    Button(action: saveBean) {
                        MixedFontText(content: "保存", fontSize: 18)
                            .foregroundColor(Color.theme.textColor)
                            .frame(width: 160)
                            .padding(.vertical, 14)
                            .background(Color.theme.buttonColor)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                    .disabled(name.isEmpty)
                    .padding(.vertical, 20)
                }
            }
            .padding(.bottom, keyboardHeight) // 键盘避让
            .onAppear { startKeyboardObserver() }
            .onDisappear { NotificationCenter.default.removeObserver(self) }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Text("添加咖啡豆")
                            .font(.custom("Slideqiuhong", size: 24))
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
    
    private func startKeyboardObserver() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let screenHeight = UIScreen.main.bounds.height
                let keyboardTop = frame.origin.y
                let height = max(0, screenHeight - keyboardTop)
                self.keyboardHeight = height
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.keyboardHeight = 0
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
        viewModel.save(newBean)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    CoffeeBeanView()
        .environmentObject(BrewRecordStore())
}
