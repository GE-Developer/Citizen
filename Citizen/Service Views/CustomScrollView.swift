//
//  CustomScrollView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct CustomScrollView<Header: View, Scroll: View, Title: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var tabBarState: TabBarState
    
    @State private var offsetY = 0.0
    @State private var headerHeight = 0.0
    
    private var scrollBehavior: TargetBehaviour {
        .init(headerHeight, largeNavBarHeight, smallNavBarHeight, withTarget)
    }
    
    private var isLargeNavBar: Bool {
        -offsetY < (withSearchField ? headerHeight : 0) + 8
    }
    
    private var scrollMargins: Double {
        min(max(offsetY + 2, -headerHeight - smallNavBarHeight + 8 + 5),2)
    }
    
    private let withBackButton: Bool
    private let withTarget: Bool
    private let tabBarIsVisible: Bool
    private let withSearchField: Bool
    private let largeNavBarHeight = 70.0
    private let smallNavBarHeight = 50.0
    
    private let backgroundImage: Image?
    
    @ViewBuilder private let titleHStackView: (_ isLargeNavBar: Bool) -> Title
    @ViewBuilder private let headerView: (_ minY: CGFloat) -> Header
    @ViewBuilder private let scrollView: (_ proxy: ScrollViewProxy) -> Scroll
    
    init(
        withBackButton: Bool = true,
        withTarget: Bool = false,
        tabBarIsVisible: Bool = false,
        withSearchField: Bool = false,
        backgroundImage: Image? = nil,
        @ViewBuilder titleHStackView: @escaping (_ isLargeNavBar: Bool) -> Title,
        @ViewBuilder headerView: @escaping (_ minY: CGFloat) -> Header = { _ in EmptyView() },
        @ViewBuilder scrollView: @escaping (_ proxy: ScrollViewProxy) -> Scroll
    ) {
        self.withBackButton = withBackButton
        self.withTarget = withTarget
        self.tabBarIsVisible = tabBarIsVisible
        self.withSearchField = withSearchField
        self.backgroundImage = backgroundImage
        self.titleHStackView = titleHStackView
        self.headerView = headerView
        self.scrollView = scrollView
    }
    
    var body: some View {
        customScrollView
            .onAppear {
                tabBarState.isVisible = tabBarIsVisible
                closeKeyboard()
            }
    }
}

// MARK: - Builder
extension CustomScrollView {
    private var customScrollView: some View {
        ZStack(alignment: .top) {
            background.zIndex(0)
            navigationBar.zIndex(3)
            header.zIndex(2)
            scroll.zIndex(1)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private var background: some View {
        Color.citizen.background
            .overlay {
                if let backgroundImage {
                    backgroundImage
                        .resizable()
                        .scaledToFill()
                        .opacity(0.06)
                }
            }
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var backButton: some View {
        if withBackButton {
            Button {
                dismiss()
            } label: {
                Image.system.back
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.citizen.blackAndWhite)
                    .padding(.leading, 8)
                    .frame(width: 50, height: isLargeNavBar ? largeNavBarHeight : smallNavBarHeight)
            }
        }
    }
    
    private var navigationBar: some View {
        ZStack {
            UnevenRoundedRectangle(
                bottomLeadingRadius: isLargeNavBar ? 0 : 10,
                bottomTrailingRadius: isLargeNavBar ? 0 : 10
            )
            .ignoresSafeArea()
            .foregroundStyle(.ultraThinMaterial)
            .opacity(isLargeNavBar ? 0 : 1)
            .shadow(color: Color.citizen.navBarShadow, radius: isLargeNavBar ? 0 : 5)
            
            HStack {
                backButton
                titleHStackView(isLargeNavBar)
            }
            .padding(.trailing, 14)
            .padding(.leading, withBackButton ? 0 : 20)
        }
        .frame(height: isLargeNavBar ? largeNavBarHeight : smallNavBarHeight)
        .animation(.easeOut(duration: 0.2), value: isLargeNavBar)
    }
    
    private var header: some View {
        headerView(offsetY)
            .getHeight($headerHeight)
            .safeAreaPadding(.top, largeNavBarHeight + 8)
            .safeAreaPadding(.horizontal)
    }
    
    private var geometryReader: some View {
        GeometryReader { geo in
            let offset = geo.frame(in: .scrollView(axis: .vertical)).minY
            Color.clear
                .onChange(of: offset) {
                    offsetY = offset
                }
        }
        .frame(height: 0)
    }
    
    private var scroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    geometryReader
                    scrollView(proxy)
                    Spacer()
                        .frame(height: isFaceIDPhone ? 10 : 30)
                }
            }
        }
        .safeAreaPadding(.top, largeNavBarHeight + headerHeight + 16)
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.never)
        .scrollTargetBehavior(scrollBehavior)
        .contentMargins(.top, scrollMargins, for: .scrollIndicators)
    }
}

// MARK: - Logic
extension CustomScrollView {
    private func closeKeyboard() {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .endEditing(true)
    }
}

// MARK: - ScrollTargetBehavior
fileprivate struct TargetBehaviour: ScrollTargetBehavior {
    private let headerHeight: Double
    private let largeNavBarHeight: Double
    private let smallNavBarHeight: Double
    private let withTarget: Bool
    
    init(
        _ headerHeight: Double,
        _ largeNavBarHeight: Double,
        _ smallNavBarHeight: Double,
        _ withTarget: Bool
    ) {
        self.headerHeight = headerHeight
        self.largeNavBarHeight = largeNavBarHeight
        self.smallNavBarHeight = smallNavBarHeight
        self.withTarget = withTarget
    }
    
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        guard withTarget == true else { return }
        
        let fullHeader = headerHeight + 8 + largeNavBarHeight - smallNavBarHeight
        let halfHeader = headerHeight / 2 + 8 + largeNavBarHeight - smallNavBarHeight
        
        switch target.rect.minY {
        case 0 ..< halfHeader:
            target.rect.origin = .zero
        case halfHeader ..< fullHeader:
            target.rect.origin = .init(x: 0, y: fullHeader)
        default:
            break
        }
    }
}
