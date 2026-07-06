//
//  HeaderTextView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct HeaderTextView: View {
    private let text: String
    private let offsetY: Double
    
    init(text: String, offsetY: Double) {
        self.text = text
        self.offsetY = offsetY
    }
    
    var body: some View {
        headerTextView
    }
}

// MARK: - Builder
extension HeaderTextView {
    private var headerTextView: some View {
        HStack() {
            Text(text.asMarkdown)
                .font(.subheadline)
                .fontWeight(.thin)
                .fontDesign(.rounded)
                .foregroundStyle(Color.citizen.secondaryText)
                .minimumScaleFactor(0.5)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(10)
        .background(background)
        .offset(y: min(offsetY, 0))
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 12)
            .foregroundStyle(Color.citizen.secondaryGroupBackground)
    }
}
