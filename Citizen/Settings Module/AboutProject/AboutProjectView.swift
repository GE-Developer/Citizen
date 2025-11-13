//
//  AboutProjectView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AboutProjectView: View {
    private let vm = AboutProjectViewModel()
    
    var body: some View {
        aboutProjectView
    }
}

// MARK: - Builder
extension AboutProjectView {
    private var aboutProjectView: some View {
        CustomScrollView {
            CustomNavigationTitle(title: vm.title, isLargeNavBar: $0)
            Spacer()
        } scrollView: { _ in
            VStack(spacing: 25) {
                aboutProjectForm
                developerMichaelForm
            }
        }
    }
    
    private var aboutProjectForm: some View {
        CustomForm(headerText: vm.aboutProjectTitle) {
            CustomTextRow(vm.aboutProjectDescription)
        }
    }
    
    private var developerMichaelForm: some View {
        CustomForm(headerText: vm.developersTitle) {
            CustomButtonRow(
                circleImage: Image.other.iosDeveloperMichael,
                title: vm.developerMichaelButtonTitle,
                subtitle: vm.developerMichaelButtonSubtitle,
                action: { vm.developerMichaelButtonPressed() }
            )
            Divider().padding(.horizontal)
            CustomTextRow(vm.otherInfo)
        }
    }
}
