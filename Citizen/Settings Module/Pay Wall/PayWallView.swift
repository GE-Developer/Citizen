//
//  PayWallView.swift
//  Citizen
//
//  Created by GE-Developer
//
//
//import SwiftUI
//
//struct PayWallView: View {
//    @EnvironmentObject private var store: StoreManager
//    @StateObject private var vm: PayWallViewModel
//    
//    init(_ store: StoreManager) {
//        _vm = StateObject(wrappedValue: PayWallViewModel(store: store))
//    }
//    
//    var body: some View {
//        payWall
//            .environmentObject(vm)
//            .alert(
//                Text(vm.errorTitle),
//                isPresented: $vm.showError,
//                actions: { Button(vm.errorOK) {} },
//                message: { Text(vm.errorDescription) }
//            )
//    }
//}
//
//// MARK: - Builder
//extension PayWallView {
//    private var payWall: some View {
//        VStack(spacing: 0) {
//            topper
//            mainView
//                .padding(.top, 5)
//                .padding(.horizontal)
//                .padding(.bottom, isFaceIDPhone ? 20 : 5)
//        }
//        .ignoresSafeArea()
//        .background(background)
//        .overlay(backButton)
//    }
//    
//    private var mainView: some View {
//        VStack(spacing: 0) {
//            title
//            subtitle
//            
//            VStack(spacing: 22) {
//                lifetimeButton
//                subscriptionButtons
//            }
//            .frame(height: 80+22+170+20)
//            .frame(maxWidth: .infinity)
//            .opacity(vm.isLoading || vm.loadingError ? 0 : 1)
//            .overlay { placeHolderLoader }
//            
//            VStack(spacing: 10) {
//                restorePurchasesButton
//                purchaseButton
//                
//                HStack(spacing: 6) {
//                    bottomLink(text: vm.privacyPolicy) { vm.showPrivacyPolicy() }
//                    bottomLink(text: vm.termsOfUse) { vm.showTermsOfUse() }
//                }
//            }
//        }
//    }
//    
//    private var title: some View {
//        Text(vm.title)
//            .font(.title)
//            .fontDesign(.rounded)
//            .fontWeight(.semibold)
//            .foregroundStyle(Color.void.mainText)
//            .lineLimit(1)
//            .minimumScaleFactor(0.7)
//            .frame(height: 34)
//    }
//    
//    private var subtitle: some View {
//        Text(vm.subtitle)
//            .font(.subheadline)
//            .fontDesign(.rounded)
//            .multilineTextAlignment(.center)
//            .foregroundStyle(Color.void.secondaryText)
//            .lineLimit(2)
//            .minimumScaleFactor(0.7)
//            .frame(height: 38)
//    }
//    
//    private var restorePurchasesButton: some View {
//        Button(action: vm.restorePurchases) {
//            HStack {
//                Image.system.restorePurchases
//                    .font(.caption2)
//                Text(vm.restorePurchasesTitle)
//                    .font(.caption)
//            }
//            .fontDesign(.rounded)
//            .foregroundStyle(Color.void.secondaryText)
//            .lineLimit(1)
//            .minimumScaleFactor(0.7)
//            .frame(height: 16)
//        }
//    }
//    
//    private var purchaseButton: some View {
//        Button {
//            vm.purchase(vm.chosenProduct)
//        } label: {
//            Text(vm.purchaseButtonTitle)
//                .font(.title3)
//                .fontWeight(.medium)
//                .fontDesign(.rounded)
//                .padding()
//                .frame(maxWidth: .infinity)
//                .frame(height: 60)
//                .background(Gradient.payWallAccent)
//                .foregroundStyle(Color.white)
//                .clipShape(Capsule())
//                .shadow(color: Color.void.mainText, radius: 1)
//        }
//        .disabled(vm.purchaseButtonDisabled)
//        .opacity(vm.purchaseButtonDisabled ? 0.3 : 1)
//    }
//    
//    private var background: some View {
//        Color.void.background
//            .ignoresSafeArea()
//    }
//    
//    private var backButton: some View {
//        VStack {
//            HStack {
//                Spacer()
//                ExitButton()
//                    .padding()
//            }
//            Spacer()
//        }
//    }
//    
//    @ViewBuilder
//    private var lifetimeButton: some View {
//        if let inAppPurchase = vm.inAppPurchases.first {
//            ProductButton(inAppPurchase, .horisontal)
//        }
//    }
//    
//    private var subscriptionButtons: some View {
//        HStack(spacing: 12) {
//            ForEach(vm.subscriptions) {
//                ProductButton($0, isDisabled: vm.isMonthlyButtonDisabled($0))
//            }
//        }
//    }
//    
//    private var topper: some View {
//        ZStack(alignment: .bottom) {
////            MatrixAnimationView(
////                .binary,
////                color: Gradient.payWallAccent,
////                letterSize: 12,
////                columnSpacing: 0,
////                rowSpacing: 0,
////                updateDelay: nil,
////                speedRange: 8...9
////            )
//            Rectangle()
//                .frame(height: 40)
//                .foregroundStyle(LinearGradient(colors: [.void.background, .void.background.opacity(0.7), Color.clear], startPoint: .bottom, endPoint: .top))
//        }
//    }
//    
//    @ViewBuilder
//    private var placeHolderLoader: some View {
//        if vm.isLoading {
//            ProgressView()
//        } else if vm.loadingError {
//            VStack {
//                Image.system.warning
//                    .font(.title2)
//                Text(vm.errorTitle)
//                    .font(.title3)
//            }
//            .fontDesign(.rounded)
//            .foregroundStyle(Color.void.secondaryText)
//        }
//    }
//    
//    private func bottomLink(text: String, _ action: @escaping () -> Void) -> some View {
//        Button(action: action) {
//            Text(text)
//                .font(.caption)
//                .fontWeight(.light)
//                .fontDesign(.rounded)
//                .foregroundStyle(Color.void.secondaryText)
//                .lineLimit(2)
//                .minimumScaleFactor(1)
//                .frame(maxWidth: .infinity)
//                .frame(height: 31)
//        }
//    }
//}
