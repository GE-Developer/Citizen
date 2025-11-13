//
//  QuestionCategoriesView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

final class QuestionCategoriesViewModel: ObservableObject {
    let title = "Категории"
    let questions: [QuestionTheme: [Question]]
    
    @Published var chosenQuestions: [Question] = []
    
    init(_ questions: [Question]) {
        self.questions = Dictionary(grouping: questions) { $0.theme }
        print("Categories INIT")
    }
    
    deinit {
        print("Categories DE-INIT")
    }
}

struct QuestionCategoriesView: View {
    @StateObject private var vm: QuestionCategoriesViewModel
    @State private var showQuestions = false
    
    @State private var coredatatext: String = ""
    
    init(_ questions: [Question]) {
        _vm = StateObject(wrappedValue: QuestionCategoriesViewModel(questions))
    }
    
    var body: some View {
        questionCategoriesView
            .navigationDestination(isPresented: $showQuestions) {
                NavigationLazyView(QuestionsView(vm.chosenQuestions))
            }
    }
}

// MARK: - Builder
extension QuestionCategoriesView {
    private var questionCategoriesView: some View {
        CustomScrollView {
            CustomNavigationTitle(title: vm.title, isLargeNavBar: $0)
            Spacer()
        } scrollView: { _ in
            ForEach(QuestionTheme.allCases, id: \.self) { theme in
                if let questions = vm.questions[theme] {
                    Button {
                        vm.chosenQuestions = questions
                        showQuestions.toggle()
                    } label: {
                        Text("\(theme.name) - \(questions.count)")
                    }
                }
            }
            Text(coredatatext)
            Button("Обнулить") {
                AnswerStorage.shared.reset()
            }

        }
        .onAppear {
            coredatatext = "true - \(AnswerStorage.shared.fetchCorrectIDs().count), false - \(AnswerStorage.shared.fetchWrongIDs().count)"
        }
    }
}
