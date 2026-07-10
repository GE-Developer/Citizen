//
//  QuestionTextCard.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct QuestionTextCard: View {
    private let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        questionTextCard
    }
}

// MARK: - Builder
extension QuestionTextCard {
    private var questionTextCard: some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title3)
            .fontWeight(.regular)
            .fontDesign(.rounded)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Color.citizen.mainText)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(Color.citizen.groupBackground)
            }
    }
}
