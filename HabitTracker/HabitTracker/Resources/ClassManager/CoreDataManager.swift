//
//  CoreDataManager.swift
//  HabitTracker
//
//  Created by Nexios Technologies on 20/08/25.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HabitTracker") // 👈 same as .xcdatamodeld name
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("CoreData save error: \(error)")
            }
        }
    }
    
    func fetchHabits() -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching habits: \(error)")
            return []
        }
    }
    // Increment a habit's completedGoal by completedMinutes and save the context
    func updateHabitGoal(_ habit: Habit, completedMinutes: Int) {
        guard completedMinutes > 0 else { return }
        habit.completedGoal += Int32(completedMinutes)
        saveContext()
    }
    
    func markHabitAsCompleted(_ habit: Habit) {
        habit.isCompleted = true
        saveContext()
    }
}
