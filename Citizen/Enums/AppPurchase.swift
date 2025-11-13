//
//  AppPurchase.swift
//  Citizen
//
//  Created by GE-Developer
//

enum AppPurchase: CaseIterable {
    case monthly
    case annual
    
    var id: String {
        switch self {
        case .monthly: return Plist.get(.monthlyProduct)
        case .annual: return Plist.get(.annualProduct)
        }
    }
    
    static var subscriptionIDs: [String] {
        [self.monthly.id, self.annual.id]
    }
}
