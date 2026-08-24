//
//  Destination.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 26/03/24.
//

import UIKit

enum Destination: DestinationProtocol {
    case main, second, third
    
    var viewController: UIViewController {
        switch self {
        case .main:
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainVc") as? MainVc else { return .init() }
            return vc
        case .second:
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondVc") as? SecondVc else { return .init() }
            return vc
        case .third:
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThirdVc") as? ThirdVc else { return .init() }
            return vc
        }
    }
}
