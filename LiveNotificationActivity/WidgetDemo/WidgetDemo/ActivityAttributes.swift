//
//  PizzaDeliveryAttributes.swift
//  iOS16-Live-Activities
//
//  Created by Ming on 29/7/2022.
//

import SwiftUI
import ActivityKit

struct PendingDeliveryAttributes: ActivityAttributes {
    public typealias PendingDeliveryStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var driverName: String
        var estimatedDeliveryTime: ClosedRange<Date>
    }

    var numberOfPizzas: Int
    var totalAmount: String
}

struct PizzaAdAttributes: ActivityAttributes {
    public typealias PendingDeliveryAdStatus = ContentState

    public struct ContentState: Codable, Hashable {
        var adName: String
        var showTime: Date
    }
    var discount: String
}
