//
//  Container.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 20/03/24.
//

import Foundation

final class Container {
    // MARK: - SingalTone
    public static let `default` = Container()
    
    // MARK: - Factory
    var factory: [String : () -> Any] = [:]
    
    // MARK: - Functions
    func registerDependency<Service>(for type: Service.Type, to factory: @autoclosure @escaping () -> Any) {
        self.factory[String(describing: type.self)] = factory
    }
    
    func resolveDependency<Service>(for type: Service.Type) -> Service {
        guard let service = self.factory[String(describing: type.self)]?() as? Service else {
            fatalError("\(String(describing: type.self)) not found")
        }
        return service
    }
}
