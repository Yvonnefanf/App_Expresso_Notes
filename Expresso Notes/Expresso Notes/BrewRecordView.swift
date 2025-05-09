import SwiftUI

struct BrewRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var brewRecordStore: BrewRecordStore
    
    @State private var coffeeWeight: String = ""
    @State private var waterTemperature: Double = 92.0
    @State private var grindSize: Double = 4.0
    @State private var preInfusionTime: String = ""
    @State private var extractionTime: String = ""
    @State private var yieldAmount: String = ""
    
    var body: some View {
        NavigationView {
            Form {
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
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("研磨度")
                            Spacer()
                            Text("\(Int(grindSize))")
                        }
                        Slider(value: $grindSize, in: 1...10, step: 1)
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
                
                Button(action: saveRecord) {
                    Text("保存记录")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color(red: 0.6, green: 0.4, blue: 0.2))
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.vertical)
                .disabled(coffeeWeight.isEmpty || extractionTime.isEmpty || yieldAmount.isEmpty)
            }
            .navigationTitle("记录萃取参数")
            .navigationBarItems(trailing: Button("关闭") {
                dismiss()
            })
        }
    }
    
    func saveRecord() {
        let newRecord = BrewRecord(
            date: Date(),
            coffeeWeight: coffeeWeight,
            waterTemperature: Int(waterTemperature),
            grindSize: Int(grindSize),
            preInfusionTime: preInfusionTime,
            extractionTime: extractionTime,
            yieldAmount: yieldAmount
        )
        
        brewRecordStore.addRecord(newRecord)
        dismiss()
    }
}

struct BrewRecordView_Previews: PreviewProvider {
    static var previews: some View {
        BrewRecordView()
            .environmentObject(BrewRecordStore())
    }
} 
