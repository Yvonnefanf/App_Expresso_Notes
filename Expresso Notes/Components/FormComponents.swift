//
//  LabeledInputField.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 22/6/25.
//
import SwiftUI

func parameterInputField(
    title: String,
    binding: Binding<String>,
    placeholder: String,
    required: Bool,
    showError: Bool,
    textColor: Color = Color(red: 134/255, green: 86/255, blue: 56/255).opacity(0.8),
    disableColor: Color = Color(red: 162/255, green: 160/255, blue: 154/255),
    errorHighlightColor: Color = .red
) -> some View {
    HStack(alignment: .center) {
        // 标签
        HStack(spacing: 2) {
            MixedFontText(content: title)
                .foregroundColor(textColor)
            if required {
                Text("*")
                    .font(.custom("平方江南体", size: 18))
                    .foregroundColor(.red)
            }
        }
        .frame(width: 130, alignment: .leading)

        Spacer()

        // 输入框
        ZStack(alignment: .leading) {
            if binding.wrappedValue.isEmpty {
                MixedFontText(content: placeholder,fontSize: 16)
                    .foregroundColor(disableColor.opacity(0.7))
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


