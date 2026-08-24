//
//  DocumentScannerApp.swift
//  DocumentScanner
//
//  Created by Vishal Vaghasiya on 03/06/26.
//

import SwiftUI

@main
struct DocumentScannerApp: App {
    let coreDataManager = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, coreDataManager.viewContext)
                .preferredColorScheme(.light)
                .task {
                    await CoreDataBackupService.shared.restoreIfNeeded()
                }
        }
    }
}
