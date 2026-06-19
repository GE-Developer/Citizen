//
//  PremiumImageView.swift
//  VOID
//
//  Created by GE-Developer
//

import SwiftUI

struct PremiumView: View {
    @EnvironmentObject private var store: StoreManager
    
    @State private var isAnimating = false
    
    private let forPremiumText = "For Premium"
    private let premiumText = "Premium"
    private let basicText = "Basic"
    
    private let demonstration: Demonstration
    
    enum Demonstration {
        case star
        case textAndStar
        case status
    }
    
    init(_ demonstration: Demonstration) {
        self.demonstration = demonstration
    }
    
    var body: some View {
        premiumView
    }
}

// MARK: - Builder
extension PremiumView {
    private var premiumView: some View {
        switch demonstration {
        case .star:
            AnyView(starView)
        case .textAndStar:
            AnyView(starAndTextView)
        case .status:
            AnyView(statusView)
        }
    }
    
    @ViewBuilder
    private var starView: some View {
        if !store.isPremium {
            Image.system.star
                .fontWeight(.bold)
                .foregroundStyle(Gradient.gold)
                .rotation3DEffect(
                    .degrees(isAnimating ? 360 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .font(.callout)
                .fontDesign(.rounded)
                .animation(
                    .easeInOut(duration: 0.6)
                    .delay(1.5)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
        }
    }
    
    @ViewBuilder
    private var starAndTextView: some View {
        if !store.isPremium {
            HStack {
                Text(forPremiumText)
                    .foregroundStyle(Gradient.gold)
                Image.system.star
                    .fontWeight(.bold)
                    .foregroundStyle(Gradient.gold)
                    .rotation3DEffect(
                        .degrees(isAnimating ? 360 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .offset(y: -3)
            }
            .font(.callout)
            .fontDesign(.rounded)
            .animation(
                .easeInOut(duration: 0.6)
                .delay(1.5)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
        }
    }
    
    private var statusView: some View {
        HStack {
            if store.isPremium {
                Image.system.star
                    .foregroundStyle(Color(.secondarySystemGroupedBackground))
            }
            
            Text(store.isPremium ? premiumText : basicText)
                .foregroundStyle(Color(.secondarySystemGroupedBackground))
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .minimumScaleFactor(0.5)
        }
        .font(.caption2)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    store.isPremium
                    ? Gradient.gold
                    : Gradient.gray
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(.secondarySystemGroupedBackground), lineWidth: 2)
                )
        }
    }
}
