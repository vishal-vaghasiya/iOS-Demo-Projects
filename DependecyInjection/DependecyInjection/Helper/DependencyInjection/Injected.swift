//
//  Injected.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 20/03/24.
//

import Foundation

@propertyWrapper
struct Injected<Service> {
    // MARK: - Properties
    var service: Service
    
    // MARK: - Life-Cycle
    init() {
        self.service = Container.default.resolveDependency(for: Service.self)
    }
    
    // MARK: - WrappedValue
    var wrappedValue: Service {
        get {
            return self.service
        }
        
        set {
            self.service = newValue
        }
    }
}
