//
//  CustomNavigationBar.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomNavigationTitle: View {
    private let title: String
    private let subTitle: String?
    private let isLargeNavBar: Bool
    private let alignment: HorizontalAlignment
    private let multilineAlignment: TextAlignment
    
    init(
        title: String,
        subTitle: String? = nil,
        isLargeNavBar: Bool,
        alignment: HorizontalAlignment = .leading,
        multilineAlignment: TextAlignment = .leading
    ) {
        self.title = title
        self.subTitle = subTitle
        self.isLargeNavBar = isLargeNavBar
        self.alignment = alignment
        self.multilineAlignment = multilineAlignment
    }
    
    var body: some View {
        navigationBar
    }
}

// MARK: - Builder
extension CustomNavigationTitle {
    private var navigationBar: some View {
        VStack(alignment: alignment) {
            mainTitle
            secondaryTitle
        }
        .fontDesign(.rounded)
        .animation(.easeInOut(duration: 0.25), value: subTitle)
    }
    
    private var mainTitle: some View {
        Text(title)
            .font(isLargeNavBar ? .title : .title3)
            .fontWeight(.medium)
            .foregroundStyle(Color.citizen.blackAndWhite)
            .multilineTextAlignment(multilineAlignment)
    }
    
    private var secondaryTitle: some View {
        Group {
            if isLargeNavBar, let subTitle {
                Text(subTitle)
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundStyle(Color.citizen.mainText)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
