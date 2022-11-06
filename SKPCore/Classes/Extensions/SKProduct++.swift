//
//  SKProduct++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 11/05/2022.
//

import Foundation
import StoreKit

public extension SKProduct {
    
    var subsPeriod: String {
        guard let subscriptionPeriod = self.subscriptionPeriod else { return "" }
        
        let dateComponents: DateComponents
        
        switch subscriptionPeriod.unit {
        case .day: dateComponents = DateComponents(day: subscriptionPeriod.numberOfUnits)
        case .week: dateComponents = DateComponents(weekOfMonth: subscriptionPeriod.numberOfUnits)
        case .month: dateComponents = DateComponents(month: subscriptionPeriod.numberOfUnits)
        case .year: dateComponents = DateComponents(year: subscriptionPeriod.numberOfUnits)
        @unknown default:
            print("WARNING: SwiftyStoreKit localizedSubscriptionPeriod does not handle all SKProduct.PeriodUnit cases.")
            // Default to month units in the unlikely event a different unit type is added to a future OS version
            dateComponents = DateComponents(month: subscriptionPeriod.numberOfUnits)
        }
        return DateComponentsFormatter.localizedString(from: dateComponents, unitsStyle: .full) ?? ""
    }
    
    var locallizePricePerMonth: String? {
        guard let result = priceFormatter(locale: priceLocale).string(from: pricePerMonth as NSNumber) else { return nil }
        return result + "/Month"
    }
    
    var pricePerMonth: Double {
        guard let subscriptionPeriod = self.subscriptionPeriod else { return 0 }
        var months: Double = 0
        switch subscriptionPeriod.unit {
        case .day: months = Double(subscriptionPeriod.numberOfUnits / 30)
        case .week: months = Double(subscriptionPeriod.numberOfUnits / 4)
        case .month: months = Double(subscriptionPeriod.numberOfUnits)
        case .year: months = Double(subscriptionPeriod.numberOfUnits * 12)
        @unknown default:
            return 0
        }
        return price.doubleValue / months
    }
    
    private func priceFormatter(locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }
}
