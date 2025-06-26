//
//  DataCard.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 26/6/25.
//
import SwiftUI

struct DataCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            MixedFontText(content: title)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.theme.textColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.theme.themeColor2.opacity(0.3))
        .cornerRadius(10)
    }
}

