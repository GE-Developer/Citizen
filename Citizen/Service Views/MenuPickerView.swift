//
//  MenuPickerView.swift
//  VOID
//
//  Created by GE-Developer
//

import SwiftUI

struct MenuPickerView: View {
    @Binding private var selection: String
    
    private let options: [String]
    
    init(selection: Binding<String>, options: [String]) {
        self._selection = selection
        self.options = options
    }
    
    var body: some View {
        menuPickerView
    }
}

// MARK: - Builder
extension MenuPickerView {
    private var menuPickerView: some View {
        Picker("", selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(option)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .tag(option)
            }
        }
        .pickerStyle(.menu)
        .tint(Color.void.accent)
        .frame(height: 40)
        .background(background)
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.secondarySystemGroupedBackground))
            .shadow(color: Color.void.viewShadow, radius: 4)
    }
}
