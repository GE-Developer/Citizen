//
//  CourcesView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

final class TestsViewModel: ObservableObject {
    @Published var chosenQuestions: [Question] = []
    
    let title = "Тесты"
    let questions: [QuestionCategory: [Question]]
    
    init() {
        let allQuestions = Question.getData()
        
        questions = Dictionary(grouping: allQuestions) { $0.category }
        print("Tests INIT")
    }
    
    deinit {
        print("Tests DE-INIT")
    }
}




struct CourcesView: View {
    @State private var showQuestions = false
    @EnvironmentObject private var tabBarState: TabBarState
    
    @StateObject private var vm = TestsViewModel()
    
    var body: some View {
        testView
            .navigationDestination(isPresented: $showQuestions) {
                NavigationLazyView(QuestionCategoriesView(vm.chosenQuestions))
            }
            .onAppear {
                tabBarState.isVisible = true
                vm.chosenQuestions = []
            }
    }
}

// MARK: - Builder
extension CourcesView {
    private var testView: some View {
        CustomScrollView(withBackButton: false) {
            CustomNavigationTitle(title: vm.title, isLargeNavBar: $0)
            Spacer()
        } scrollView: { _ in
            scroll
        }
    }
    
    private var scroll: some View {
        ForEach(QuestionCategory.allCases, id: \.self) { category in
            if let questions = vm.questions[category] {
                
                Button {
                    vm.chosenQuestions = questions
                    showQuestions.toggle()
                } label: {
                    Text("\(category.rawValue) - \(questions.count)")
                }
                
            }
        }
    }
}
