//
//  StoreManager.swift
//  Citizen
//
//  Created by GE-Developer
//

import Foundation
import StoreKit

@MainActor
final class StoreManager: ObservableObject {
    @Published var devTest: Bool
    @Published private(set) var purchasedProductIDs: Set<String> = []
    
    var isPremium: Bool { devTest || !purchasedProductIDs.isEmpty }
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        devTest = UserDefaults.standard.bool(forKey: AppStorageKey.devTest.key)
//        updates = newTransactionListenerTask()
//        Task { await updatePurchasedProducts() }
    }
    
    deinit {
        updates?.cancel()
    }
    
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    func purchase(_ product: Product) async throws {
        do {
            let result = try await product.purchase()
            
            switch result {
            case let .success(.verified(transaction)):
                await transaction.finish()
                await updatePurchasedProducts()
            case let .success(.unverified(_, reason)):
                throw StoreError.from(reason)
            case .userCancelled:
                break
            case .pending:
                throw StoreError.pending
            @unknown default:
                throw StoreError.unknown
            }
        } catch {
            throw StoreError.system
        }
    }
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                await handle(updatedTransaction: verificationResult)
            }
        }
    }
    
    private func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            await handle(updatedTransaction: result)
        }
    }
    
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verificationResult else { return }
        
        if let _ = transaction.revocationDate {
            purchasedProductIDs.remove(transaction.productID)
            await transaction.finish()
        } else if let expirationDate = transaction.expirationDate, expirationDate < Date() {
            purchasedProductIDs.remove(transaction.productID)
            await transaction.finish()
        } else if transaction.isUpgraded {
            return
        } else {
            purchasedProductIDs.insert(transaction.productID)
        }
    }
}
