//
//  CustomCapsulePicker.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomCapsulePicker<Item: CaseIterable & Hashable>: View
where Item.AllCases: RandomAccessCollection
{
    @Binding private var selection: Item
    
    private let disabledItems: Set<Item>
    private let title: String?
    private let capsuleName: (Item) -> String
    
    private let hapticsManager = HapticsManager.shared
    
    init(
        selection: Binding<Item>,
        disabledItems: Set<Item> = [],
        title: String? = nil,
        capsuleName: @escaping (Item) -> String
    ) {
        self._selection = selection
        self.disabledItems = disabledItems
        self.title = title
        self.capsuleName = capsuleName
    }
    
    var body: some View {
        capsulePicker
    }
}

// MARK: - Builder
extension CustomCapsulePicker {
    private var capsulePicker: some View {
        VStack(spacing: 12) {
            if let title {
                FormHeaderView(title)
            }
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(Item.allCases, id: \.self) { item in
                            capsuleButton(item)
                                .id(item)
                        }
                    }
                }
                .onAppear {
                    proxy.scrollTo(selection, anchor: .center)
                }
                .onChange(of: selection) { _, newValue in
                    withAnimation {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
    }
    
    private func capsuleButton(_ item: Item) -> some View {
        let isSelected = selection == item
        let isDisabled = disabledItems.contains(item)
        return Button {
            selection = item
            hapticsManager.selectionChanged()
        } label: {
            Text(capsuleName(item))
                .font(.subheadline)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isDisabled ? Color.citizen.mainText.opacity(0.3) : Color.citizen.mainText)
                .background(isSelected ? AnyShapeStyle(Gradient.accent) : AnyShapeStyle(Color(.secondarySystemGroupedBackground)))
                .clipShape(Capsule())
        }
        .disabled(isDisabled || isSelected)
    }
}
