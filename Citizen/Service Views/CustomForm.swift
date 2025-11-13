//
//  CustomForm.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomForm<Content: View, HeaderContent: View>: View {
    private let headerText: String?
    private let headerContent: HeaderContent
    private let content: Content
    
    init(
        headerText: String? = nil,
        @ViewBuilder headerContent: () -> HeaderContent = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.headerText = headerText
        self.headerContent = headerContent()
        self.content = content()
    }
    
    var body: some View {
        customForm
    }
}

// MARK: - Builder
extension CustomForm {
    private var customForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let headerText {
                HStack(spacing: 0) {
                    header(headerText)
                    Spacer()
                    headerContent
                }
            }
            VStack(spacing: 0) {
                content
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func header(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(Color.citizen.mainText)
            .font(.caption)
            .fontDesign(.rounded)
            .textCase(.uppercase)
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 6)
    }
}
