//
//  View + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

extension View {
    var logo: some View {
        Image.other.svgLogo
            .resizable()
            .scaledToFit()
    }
    
    var isFaceIDPhone: Bool { DeviceLayout.hasHomeIndicator }
    
    func premiumOption(
        _ showPayWall: Binding<Bool>,
        swipable: Bool = false,
        isIncluded: Bool = true
    ) -> some View {
        modifier(
            PremiumLockModifier(showPayWall, swipable: swipable, isIncluded: isIncluded)
        )
    }
    
    @ViewBuilder
    func screenshotDisabled(_ isEnabled: Bool) -> some View {
        let securedText = "Secured"
        ZStack {
            if isEnabled {
                VStack {
                    logo
                        .frame(height: 50)
                    Text(securedText)
                        .font(.headline)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color.citizen.mainText)
                }
            }
            self.mask {
                if isEnabled {
                    ScreenShotPreventerMask()
                        .ignoresSafeArea()
                } else {
                    Color.white
                        .ignoresSafeArea()
                }
            }
            .animation(nil, value: isEnabled)
        }
    }
    
    func shimmering() -> some View {
        modifier(Shimmer())
    }
}
