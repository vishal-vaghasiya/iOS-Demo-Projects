//
//  CoreDataManager.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import CoreData
internal import Foundation
internal import Combine

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    private init() {
        // Define model entities programmatically to prevent compiler/bundling errors
        // with raw .xcdatamodeld files in cross-platform/dynamic environments.
        let model = NSManagedObjectModel()
        
        // Define SavedFile Entity
        let savedFileEntity = NSEntityDescription()
        savedFileEntity.name = "SavedFile"
        savedFileEntity.managedObjectClassName = NSStringFromClass(SavedFile.self)
        
        // Attributes
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false
        
        let nameAttr = NSAttributeDescription()
        nameAttr.name = "name"
        nameAttr.attributeType = .stringAttributeType
        nameAttr.isOptional = false
        
        let pathAttr = NSAttributeDescription()
        pathAttr.name = "path"
        pathAttr.attributeType = .stringAttributeType
        pathAttr.isOptional = false
        
        let fileSizeAttr = NSAttributeDescription()
        fileSizeAttr.name = "fileSize"
        fileSizeAttr.attributeType = .integer64AttributeType
        fileSizeAttr.isOptional = false
        
        let createdAtAttr = NSAttributeDescription()
        createdAtAttr.name = "createdAt"
        createdAtAttr.attributeType = .dateAttributeType
        createdAtAttr.isOptional = false
        
        let fileTypeAttr = NSAttributeDescription()
        fileTypeAttr.name = "fileType"
        fileTypeAttr.attributeType = .stringAttributeType
        fileTypeAttr.isOptional = false
        
        let isFavoriteAttr = NSAttributeDescription()
        isFavoriteAttr.name = "isFavorite"
        isFavoriteAttr.attributeType = .booleanAttributeType
        isFavoriteAttr.isOptional = false
        isFavoriteAttr.defaultValue = false
        
        let sourceOperationAttr = NSAttributeDescription()
        sourceOperationAttr.name = "sourceOperation"
        sourceOperationAttr.attributeType = .stringAttributeType
        sourceOperationAttr.isOptional = false
        
        savedFileEntity.properties = [
            idAttr, nameAttr, pathAttr, fileSizeAttr, createdAtAttr, fileTypeAttr, isFavoriteAttr, sourceOperationAttr
        ]
        
        model.entities = [savedFileEntity]
        
        // Setup Persistent Container
        container = NSPersistentContainer(name: "DocumentScannerModel", managedObjectModel: model)
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Core Data failed to configure descriptions.")
        }
        
        // Ensure Offline-First Local Data
        description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// Custom ManagedObject implementation
@objc(SavedFile)
class SavedFile: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var path: String // Relative to Documents directory
    @NSManaged public var fileSize: Int64
    @NSManaged public var createdAt: Date
    @NSManaged public var fileType: String
    @NSManaged public var isFavorite: Bool
    @NSManaged public var sourceOperation: String
}

extension SavedFile: Identifiable {}

extension SavedFile {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedFile> {
        return NSFetchRequest<SavedFile>(entityName: "SavedFile")
    }

    var folderPath: String? {
        let folder = (path as NSString).deletingLastPathComponent
        return folder == "." || folder.isEmpty ? nil : folder
    }

    var folderDisplayName: String {
        folderPath.flatMap { URL(fileURLWithPath: $0).lastPathComponent } ?? "All Files"
    }
}
