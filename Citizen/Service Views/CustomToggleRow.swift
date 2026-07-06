//
//  CustomToggleRow.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomToggleRow: View {
    @Binding var isOn: Bool
    
    private let icon: Image?
    private let title: String
    private let haptics = HapticsManager.shared
    
    init(isOn: Binding<Bool>, icon: Image? = nil, title: String) {
        _isOn = isOn
        self.icon = icon
        self.title = title
    }
    
    var body: some View {
        customToggleRow
            .onChange(of: isOn) {
                haptics.selectionChanged()
            }
    }
}

// MARK: - Builder
extension CustomToggleRow {
    @ViewBuilder
    private var customToggleRow: some View {
        HStack(spacing: 0) {
            Group {
                Group {
                    if let icon {
                        icon
                            .foregroundStyle(Gradient.accent)
                            .frame(width: 50)
                    } else {
                        Color.clear
                            .frame(width: 0)
                            .padding(.leading, 16)
                    }
                }
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
            withAnimation { isOn.toggle() }
        } label: {
            RoundedRectangle(cornerRadius: 16)
                .fill(isOn ? Gradient.accent : Gradient.gray)
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.citizen.white)
                        .frame(width: 24, height: 24)
                        .offset(x: isOn ? 10 : -10)
                        .animation(.easeInOut(duration: 0.2), value: isOn)
                )
        }
        .padding(.trailing)
    }
}
