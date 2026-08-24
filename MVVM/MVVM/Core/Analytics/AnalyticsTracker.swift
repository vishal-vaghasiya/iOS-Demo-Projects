//
//  AnalyticsTracker.swift
//  MVVM
//
//  Created by Vishal Vaghasiya on 09/01/26.
//

protocol AnalyticsTracking {
    func track(event: String)
}

final class AnalyticsTracker: AnalyticsTracking {
    func track(event: String) {
        print("Tracked event:", event)
    }
}
