//
//  MixedFontText.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 22/6/25.
//

import SwiftUI

struct MixedFontText: View {
    let content: String
    var chineseFont: String = "平方江南体"
    var latinFont: String = "umeboshi"
    var fontSize: CGFloat = 17

    var body: some View {
        let components = splitText(content)
        components.reduce(Text("")) { result, part in
            let isChinese = containsChinese(part)
            return result + Text(part)
                .font(.custom(isChinese ? chineseFont : latinFont, size: fontSize))
        }
    }

    private func containsChinese(_ text: String) -> Bool {
        for scalar in text.unicodeScalars {
            if scalar.value >= 0x4E00 && scalar.value <= 0x9FFF {
                return true
            }
        }
        return false
    }

    private func splitText(_ input: String) -> [String] {
        var result: [String] = []
        var current = ""
        var currentIsChinese: Bool? = nil

        for char in input {
            let isChinese = containsChinese(String(char))
            if currentIsChinese == nil {
                current.append(char)
                currentIsChinese = isChinese
            } else if currentIsChinese == isChinese {
                current.append(char)
            } else {
                result.append(current)
                current = String(char)
                currentIsChinese = isChinese
            }
        }

        if !current.isEmpty {
            result.append(current)
        }

        return result
    }
}


