//
//  View + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

// MARK: - View Extension
extension View {
    var logo: some View {
        Image.other.svgLogo
            .resizable()
            .scaledToFit()
    }
    
    var isFaceIDPhone: Bool {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            return false
        }
        return window.safeAreaInsets.bottom > 0
    }
    
    func getHeight(_ height: Binding<Double>) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { height.wrappedValue = geo.size.height }
            }
        )
    }
    
    func premiumOption(_ showPayWall: Binding<Bool>, swipable: Bool = false) -> some View {
        self.modifier(PremiumLockModifier(showPayWall, swipable: swipable))
    }
}

// MARK: - View Modifiers
struct PremiumLockModifier: ViewModifier {
    @EnvironmentObject private var store: StoreManager
    @Binding private var showPayWall: Bool
    
    private let swipable: Bool
    
    init(_ showPayWall: Binding<Bool>, swipable: Bool) {
        self._showPayWall = showPayWall
        self.swipable = swipable
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(store.isPremium ? 1 : 0.5)
            .disabled(!store.isPremium)
            .overlay {
                if swipable {
                    swipableOverlay
                } else {
                    notSwipableOverlay
                }
            }
    }
    
    @ViewBuilder
    private var swipableOverlay: some View {
        if !store.isPremium {
            Color.citizen.blackAndWhite.opacity(0.000001)
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            if value.translation.width > 50
                                && abs(value.translation.height) < 30 {
                                showPayWall = true
                            }
                        }
                )
                .onTapGesture {
                    showPayWall = true
                }
        }
    }
    
    @ViewBuilder
    private var notSwipableOverlay: some View {
        if !store.isPremium {
            Color.citizen.blackAndWhite.opacity(0.000001)
                .onTapGesture {
                    showPayWall = true
                }
        }
    }
}
