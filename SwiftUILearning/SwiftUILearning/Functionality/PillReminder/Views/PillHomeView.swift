import SwiftUI

struct PillHomeView: View {
    @StateObject private var store = PillStore.shared

    var body: some View {
        List {
            Section(header: Text("Reminders")) {
                if store.pills.isEmpty {
                    Text("No reminders yet — tap + to add your first pill")
                        .foregroundColor(.secondary)
                }
                ForEach(store.pills) { pill in
                    NavigationLink(destination: PillDetailView(pill: pill)) {
                        PillRowView(pill: pill)
                    }
                }
                .onDelete { idx in
                    idx.forEach { i in
                        let p = store.pills[i]
                        store.remove(p)
                    }
                }
            }

            Section(header: Text("Quick Actions")) {
                Button(action: { /* open refill screen */ }) { Label("Refill Reminder", systemImage: "repeat") }
                Button(action: { /* open history */ }) { Label("Medication History", systemImage: "clock.arrow.circlepath") }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

#Preview {
    NavigationView {
        PillHomeView()
    }
}
