//
//  AccentActionCard.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AccentActionCard: View {
    private let icon: Image
    private let title: String
    private let subtitle: String
    private let action: () -> Void
    
    init(icon: Image, title: String, subtitle: String, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        card
    }
}

// MARK: - Builder
extension AccentActionCard {
    private var card: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Gradient.accent)
                    icon
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color.citizen.white)
                }
                .frame(maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .padding(.vertical, 5)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.citizen.mainText)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.citizen.secondaryText)
                }
                .fontDesign(.rounded)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                
                Spacer()
                
                Image.system.chevron
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.secondaryText)
            }
            .padding()
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.citizen.groupBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Gradient.accent.opacity(0.12))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Gradient.accent.opacity(0.45), lineWidth: 1)
            }
        }
    }
}
