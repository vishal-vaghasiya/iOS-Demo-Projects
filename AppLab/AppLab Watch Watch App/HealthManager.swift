//
//  HealthManager.swift
//  DemoForWatch Watch App
//
//  Created by Nexios Mac 4 on 22/09/25.
//

import Foundation
import HealthKit

class HealthManager {
    static let shared = HealthManager()
    let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let readTypes: Set = [stepType]
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
            completion(success, error)
        }
    }

    func getTodayStepCount(completion: @escaping (Double?, Error?) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        guard let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) else {
            completion(nil, nil)
            return
        }
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            var steps: Double? = nil
            if let quantity = result?.sumQuantity() {
                steps = quantity.doubleValue(for: HKUnit.count())
            }
            completion(steps, nil)
        }
        healthStore.execute(query)
    }
}
