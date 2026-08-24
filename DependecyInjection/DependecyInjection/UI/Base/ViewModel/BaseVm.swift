//
//  BaseVm.swift
//  DependecyInjection
//
//  Created by Nexios Mac 4 on 20/03/24.
//

import Foundation

class BaseVm {
    @Injected var notificationService: NotificationService
    @Injected var router: Routable
    
    required init() { }
}
