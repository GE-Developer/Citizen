//
//  CustomToggleRow.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomToggleRow: View {
    @Binding var isOff: Bool
    
    private let icon: Image
    private let title: String
    private let haptics = HapticsManager.shared
    
    init(isOff: Binding<Bool>, icon: Image, title: String) {
        _isOff = isOff
        self.icon = icon
        self.title = title
    }
    
    var body: some View {
        customToggleRow
    }
}

// MARK: - Builder
extension CustomToggleRow {
    private var customToggleRow: some View {
        HStack(spacing: 0) {
            Group {
                icon
                    .foregroundStyle(Gradient.accent)
                    .frame(width: 50)
                Text(title)
                    .foregroundStyle(Color.citizen.mainText)
                    .font(.headline)
                    .fontDesign(.rounded)
                    .fontWeight(.regular)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.leading)
                    .padding(.trailing)
            }
            .padding(.vertical)
            Spacer()
            toggle
        }
    }
    
    private var toggle: some View {
        Button {
            withAnimation { isOff.toggle() }
        } label: {
            RoundedRectangle(cornerRadius: 16)
                .fill(isOff ? Gradient.gray : Gradient.accent)
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .offset(x: isOff ? -10 : 10)
                        .animation(.easeInOut(duration: 0.2), value: isOff)
                )
        }
        .padding(.trailing)
        .onChange(of: isOff) {
            haptics.selectionChanged()
        }
    }
}
