//
//  AppDelegate.swift
//  CoreDataSync
//
//  Created by Nexios Technologies on 23/09/25.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "CoreDataSync")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No persistent store descriptions found")
        }
        
        // CloudKit options
        let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.coredatasync")
        description.cloudKitContainerOptions = options
        
        // Enable history tracking & remote change notifications
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Enable lightweight migration
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // For production, consider logging instead of crashing
                print("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        // Merge policy & automatic changes
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Observe remote changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.processRemoteChanges(_:)),
            name: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
        
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext(context: NSManagedObjectContext? = nil) {
        let context = context ?? persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Failed to save Core Data context: \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Remote change handling
    
    @objc func processRemoteChanges(_ notification: Notification) {
        let context = persistentContainer.viewContext
        context.perform {
            context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
}

