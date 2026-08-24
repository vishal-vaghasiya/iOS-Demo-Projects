//
//  HistoryView.swift
//  AppLab Watch Watch App
//
//  Created by Nexios Technologies on 19/09/25.
//

import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: TimerSession.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TimerSession.endDate, ascending: false)]
    ) var sessions: FetchedResults<TimerSession>
    
    var body: some View {
        List {
            if sessions.isEmpty {
                Text("No history available")
            } else {
                ForEach(sessions) { session in
                    VStack(alignment: .leading) {
                        Text(formatElapsed(session.elapsed))
                            .font(.headline)
                        Text(dateFormatter.string(from: session.endDate ?? Date()))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete(perform: deleteSessions)
            }
        }
    }
    
    private func deleteSessions(offsets: IndexSet) {
        withAnimation {
            offsets.map { sessions[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // Handle the Core Data error appropriately in a real app
                print("Failed to delete session: \(error.localizedDescription)")
            }
        }
    }
    
    func formatElapsed(_ elapsed: Int64) -> String {
        let seconds = Int(elapsed)
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    HistoryView()
}
