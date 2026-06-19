//
//  AppVersion.swift
//  VOID
//
//  Created by GE-Developer
//

import SwiftUI

// MARK: - App Version
struct AppVersion: View {
    @State private var isGestureActivated = false
    @State private var showDeveloperView = false
    
    private let haptic = HapticsManager.shared
    private let sound = SoundManager.shared
    
    private let appVersion: String
    
    private var textColor: Color {
        isGestureActivated ? Color.void.accent : Color.void.grayDark
    }
    
    init() {
        let infoDictionary = Bundle.main.infoDictionary
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        
        appVersion = "\(version)"
    }
    
    var body: some View {
        appVersionView
            .onDisappear { isGestureActivated = false }
            .onLongPressGesture(minimumDuration: 5, perform: longGesture)
            .onTapGesture(count: 10, perform: gesture)
            .navigationDestination(isPresented: $showDeveloperView) {
                NavigationLazyView(DeveloperView())
            }
    }
    
    private var appVersionView: some View {
        ZStack {
            Color.void.background
            VStack {
                Text(L10n("Settings.AppVersion.title"))
                Text(appVersion)
            }
            .foregroundStyle(textColor)
            .font(.caption)
            .fontDesign(.monospaced)
            .padding(6)
            .frame(maxWidth: .infinity)
        }
    }
    
    private func longGesture() {
        haptic.notification(type: .success)
        withAnimation {
            isGestureActivated.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 40) {
            guard isGestureActivated else { return }
            haptic.selectionChanged()
            withAnimation {
                isGestureActivated = false
            }
        }
    }
    
    private func gesture() {
        guard isGestureActivated else { return }
        haptic.impact(style: .heavy)
        sound.playSound(.devMode)
        showDeveloperView = true
    }
}

// MARK: - Developer View
struct DeveloperView: View {
    @EnvironmentObject private var store: StoreManager
    
    @State private var devAccess = false
    @State private var typePass = ""
    
    private var isButtonEnabled: Bool {
        devAccess || !typePass.isEmpty
    }
    
    private var isPremiumOn: Binding<Bool> {
        Binding(
            get: {
                store.devTest
            },
            set: {
                store.devTest = $0
                defaults.set($0, forKey: key)
                defaults.synchronize()
            }
        )
    }
    
    private let key = AppStorageKey.devTest.key
    
    private let haptic = HapticsManager.shared
    private let defaults = UserDefaults.standard
    
    private let title = "Developer Mode"
    private let cancel = "Cancel"
    private let placeHolder = "Code"
    private let subscriptionTitle = "Subscription & Purchases"
    private let premiumRowText = "Premium"
    private let noticeMessage = "If you’ve landed on this screen by accident, please leave **immediately**.   \n This area is intended solely for **debugging** and **internal testing**.   \n User interaction is not expected and may lead to **unpredictable behavior or app instability**."
    
    private let password = "TestDrive936"
    
    var body: some View {
        CustomScrollView(title: title) {
            EmptyView()
        } content: { _ in
            VStack(spacing: 25) {
                headerView()
                logo.padding(.horizontal, 110)
                noticeView
                developerFormView
            }
        }
    }
    
    private var noticeView: some View {
        CustomForm {
            CustomTextRow(noticeMessage)
        }
    }
    
    @ViewBuilder
    private var developerFormView: some View {
        if devAccess {
            VStack(spacing: 25) {
                CustomForm(headerText: subscriptionTitle) {
                    PremiumView(.status)
                } content: {
                    CustomToggleRow(
                        isOn: isPremiumOn,
                        icon: .system.subscription,
                        title: premiumRowText
                    )
                }
            }
        }
    }
    
    private func headerView() -> some View {
        HStack {
            Button(action: lockButtonTapped) {
                Image.system.lock(devAccess)
                    .frame(width: 60)
                    .foregroundStyle(
                        devAccess
                        ? Color.void.greenDark
                        : Color.void.accent
                    )
                    .background { background() }
            }
            .disabled(!isButtonEnabled)
            .opacity(isButtonEnabled ? 1 : 0.6)
            .animation(.default, value: isButtonEnabled)
            
            CustomNavigationTextField(
                text: $typePass,
                image: .system.code,
                placeholder: placeHolder,
                cancelButtonTitle: cancel,
                deleteAction: clearTypedText
            )
            .autocapitalization(.none)
        }
    }
    
    private func background() -> some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.void.textFieldBackground)
            .shadow(color: Color.void.viewShadow, radius: 2)
            .frame(height: 40)
    }
    
    private func lockButtonTapped() {
        withAnimation {
            switch devAccess {
            case true:
                devAccess = false
                typePass = ""
                haptic.notification(type: .success)
            case false:
                if password == typePass {
                    devAccess = true
                    haptic.notification(type: .success)
                } else {
                    haptic.notification(type: .error)
                }
                typePass = ""
            }
        }
        
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    private func clearTypedText() {
        typePass = ""
        HapticsManager.shared.impact(style: .rigid)
    }
}
