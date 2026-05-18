//
//  SettingsView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: StoreManager
    @EnvironmentObject private var tabBarState: TabBarState
    
    @StateObject private var vm = SettingsViewModel()
    
    @State private var languageViewPresented = false
    @State private var showPayWall = false
    @State private var projectViewPresented = false
    
    init() {
        UIScrollView.appearance().delaysContentTouches = false
    }
    
    var body: some View {
        settingsView
            .navigationDestination(isPresented: $languageViewPresented) {
                NavigationLazyView(LanguageView())
            }
            .navigationDestination(isPresented: $projectViewPresented) {
                NavigationLazyView(AboutProjectView())
            }
//            .fullScreenCover(isPresented: $showPayWall) {
//                NavigationLazyView(PayWallView(store))
//            }
    }
}

// MARK: - Builder
extension SettingsView {
    private var settingsView: some View {
        CustomScrollView(title: vm.title, withBackButton: false, tabBarIsVisible: true) {
            EmptyView()
        } content: { _ in
            VStack(spacing: 25) {
                CustomForm(headerText: vm.generalSettingsTitle) {
                    themeToggle
                    Divider().padding(.leading, 50)
                    languageButton
                    Divider().padding(.leading, 50)
                    vibrationToggle
                    Divider().padding(.leading, 50)
                    soundToggle
                }
                
                CustomForm(headerText: vm.accessTitle) {
                    PremiumView(.status)
                } content: {
                    subscriptionButton
                    Divider().padding(.leading, 50)
                    reviewButton
                }
                
                CustomForm(headerText: vm.aboutAppTitle) {
                    termsOfUseButton
                    Divider().padding(.leading, 50)
                    privacyPolicyButton
                    Divider().padding(.leading, 50)
                    projectButton
                }
            }
        }

    }
    
    private var themeToggle: some View {
        CustomToggleRow(
            isOff: $vm.isThemeLight,
            icon: .system.darkMode,
            title: vm.darkModeTitle
        )
    }
    
    private var languageButton: some View {
        Group {
            if vm.language == "English" {
                CustomButtonRow(
                    icon: .system.language,
                    title: vm.languageTitle,
                    additionalTitle: vm.language,
                    isLink: true,
                    action: { languageViewPresented.toggle() }
                )
            } else {
                CustomButtonRow(
                    icon: .system.language,
                    title: vm.languageTitle,
                    subtitle: vm.languageSubtitle,
                    additionalTitle: vm.language,
                    isLink: true,
                    action: { languageViewPresented.toggle() }
                )
            }
        }
    }
    
    private var vibrationToggle: some View {
        CustomToggleRow(
            isOff: $vm.isHapticsOff,
            icon: .system.vibration,
            title: vm.hapticsTitle
        )
    }
    
    private var soundToggle: some View {
        CustomToggleRow(
            isOff: $vm.isSoundOff,
            icon: .system.sound,
            title: vm.soundTitle
        )
    }
    
    private var subscriptionButton: some View {
        CustomButtonRow(
            icon: .system.subscription,
            title: vm.subscriptionTitle,
            isLink: true,
            action: { showPayWall.toggle() }
        )
    }
    
    private var reviewButton: some View {
        CustomButtonRow(
            icon: .system.reviewLike,
            title: vm.reviewTitle,
            action: { vm.rateApp() }
        )
    }
    
    private var termsOfUseButton: some View {
        CustomButtonRow(
            icon: .system.termsOfUse,
            title: vm.termsOfUseTitle,
            action: { vm.showTermsOfUse() }
        )
    }
    
    private var privacyPolicyButton: some View {
        CustomButtonRow(
            icon: .system.privacyPolicy,
            title: vm.privacyPolicyTitle,
            action: { vm.showPrivacyPolicy() }
        )
    }
    
    private var projectButton: some View {
        CustomButtonRow(
            icon: .system.developerTool,
            title: vm.projectTitle,
            isLink: true,
            action: { projectViewPresented.toggle() }
        )
    }
}
