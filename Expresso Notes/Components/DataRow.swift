//
//  DataRow.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 26/6/25.
//
import SwiftUI

struct DataRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            MixedFontText(content: title)
            
            Spacer()
            
//            Text(value)
//                .font(.title2)
//                .fontWeight(.bold)
//                .foregroundColor(Color.theme.textColor)
            MixedFontText(content: value, fontSize: 22)
                .fontWeight(.bold)
        }
        .padding(.vertical, 8)
    }
}
