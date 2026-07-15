//
//  SettingsView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: StoreManager
    
    @StateObject private var vm = SettingsViewModel()
    
    @State private var languageViewPresented = false
    @State private var showPayWall = false
    @State private var projectViewPresented = false
    @State private var showStyleView = false
    @State private var showAppIconView = false
    
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
            .navigationDestination(isPresented: $showStyleView) {
                NavigationLazyView(StyleView())
            }
            .navigationDestination(isPresented: $showAppIconView) {
                NavigationLazyView(AppIconView())
            }
            .fullScreenCover(isPresented: $showPayWall) {
                NavigationLazyView(PayWallView(store))
            }
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
                
                CustomForm(headerText: vm.testsSettingsTitle) {
                    voiceActingToggle
                    Divider().padding(.leading, 50)
                    shuffleAnswersToggle
                    Divider().padding(.leading, 50)
                    shuffleQuestionsToggle
                }
                
                CustomForm(headerText: vm.accessTitle) {
                    PremiumView(.status)
                } content: {
                    subscriptionButton
                    Divider().padding(.leading, 50)
                    reviewButton
                }
                
                CustomForm(headerText: vm.customizationTitle) {
                    styleButton
                    Divider().padding(.leading, 50)
                    appIconButton
                }
                
                CustomForm(headerText: vm.aboutAppTitle) {
                    termsOfUseButton
                    Divider().padding(.leading, 50)
                    privacyPolicyButton
                    Divider().padding(.leading, 50)
                    projectButton
                }
                
                CustomForm(headerText: vm.accountTitle) {
                    CustomButtonRow(
                        icon: .system.signOut,
                        title: vm.signOutTitle,
                        isCritical: true,
                        action: { vm.signOut() }
                    )
                }
                
                AppVersion()
            }
        }
        
    }
    
    private var themeToggle: some View {
        CustomToggleRow(
            isOn: $vm.isDarkMode,
            icon: .system.darkMode,
            title: vm.darkModeTitle
        )
    }
    
    private var languageButton: some View {
        CustomButtonRow(
            icon: .system.language,
            title: vm.languageTitle,
            subtitle: vm.language == "English" ? nil : vm.languageSubtitle,
            additionalTitle: vm.language,
            isLink: true,
            action: { languageViewPresented.toggle() }
        )
    }
    
    private var vibrationToggle: some View {
        CustomToggleRow(
            isOn: $vm.isHapticsOn,
            icon: .system.vibration,
            title: vm.hapticsTitle
        )
    }
    
    private var soundToggle: some View {
        CustomToggleRow(
            isOn: $vm.isSoundOn,
            icon: .system.sound,
            title: vm.soundTitle
        )
    }
    
    private var voiceActingToggle: some View {
        CustomToggleRow(
            isOn: $vm.isVoiceActingOn,
            icon: .system.voiceActing,
            title: vm.voiceActingToggleTitle
        )
    }
    
    private var shuffleAnswersToggle: some View {
        CustomToggleRow(
            isOn: $vm.isShuffleAnswersOn,
            icon: .system.shuffle,
            title: vm.shuffleAnswersToggleTitle
        )
    }
    
    private var shuffleQuestionsToggle: some View {
        CustomToggleRow(
            isOn: $vm.isShuffleQuestionsOn,
            icon: .system.dice,
            title: vm.shuffleQuestionsToggleTitle,
            subtitle: vm.shuffleQuestionsToggleSubtitle
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
    
    private var styleButton: some View {
        CustomButtonRow(
            icon: .system.paintpalette,
            title: vm.styleTitle,
            isLink: true,
            action: { showStyleView.toggle() }
        )
    }
    
    private var appIconButton: some View {
        CustomButtonRow(
            icon: .system.appIcon,
            title: vm.appIconTitle,
            isLink: true,
            action: { showAppIconView.toggle() }
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
