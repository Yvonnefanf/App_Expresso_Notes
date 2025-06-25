//
//  LabeledInputField.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 22/6/25.
//
import SwiftUI

// 自定义 TextField 样式，使用系统原生字体
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16)) // 使用系统原生字体和大小
    }
}

func parameterInputField(
    title: String,
    binding: Binding<String>,
    placeholder: String,
    required: Bool,
    showError: Bool,
    textColor: Color = Color(red: 134/255, green: 86/255, blue: 56/255).opacity(0.8),
    disableColor: Color = Color(red: 162/255, green: 160/255, blue: 154/255),
    errorHighlightColor: Color = .red,
    labelWidth: Double = 130
) -> some View {
    HStack(alignment: .center) {
        // 标签
        HStack(spacing: 2) {
            MixedFontText(content: title)
                .foregroundColor(textColor)
            if required {
                MixedFontText(content: "*", color:.red)
            }
        }
        .frame(width: labelWidth, alignment: .leading)

        Spacer()

        // 输入框
        ZStack(alignment: .leading) {
            if binding.wrappedValue.isEmpty {
                MixedFontText(content: placeholder,fontSize: 16, color: disableColor.opacity(0.7))
                    .padding(.leading, 12)
            }

            TextField("", text: binding)
                .textFieldStyle(CustomTextFieldStyle())
                .keyboardType(.decimalPad)
                .padding(12)
                .foregroundColor(textColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showError ? errorHighlightColor : Color.gray.opacity(0.2))
                )
                .frame(maxWidth: .infinity)
        }
    }
}


