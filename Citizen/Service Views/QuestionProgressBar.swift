//
//  QuestionProgressBar.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct QuestionProgressBar: View {
    private let questions: [Question]
    private let currentQuestionID: String?
    
    init(questions: [Question], currentQuestionID: String? = nil) {
        self.questions = questions
        self.currentQuestionID = currentQuestionID
    }
    
    var body: some View {
        bar
    }
}

// MARK: - Builder
extension QuestionProgressBar {
    private var bar: some View {
        HStack(spacing: 3) {
            ForEach(questions) { question in
                Capsule()
                    .fill(style(for: question))
                    .frame(height: 6)
            }
        }
    }
}

// MARK: - Logic
extension QuestionProgressBar {
    private func style(for question: Question) -> AnyShapeStyle {
        if question.id == currentQuestionID {
            return AnyShapeStyle(Color.citizen.mainText)
        }
        
        switch question.status {
        case .correct:
            return AnyShapeStyle(Gradient.green)
        case .wrong:
            return AnyShapeStyle(Gradient.red)
        case .unanswered:
            return AnyShapeStyle(Color.citizen.background)
        }
    }
}
