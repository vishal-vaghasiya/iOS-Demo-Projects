import SwiftUI

struct PillDetailView: View {
    @StateObject private var store = PillStore.shared
    @State var pill: Pill

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                Text(pill.name).font(.title2).bold()
                Text(pill.dosage)
                if let notes = pill.notes { Text(notes).foregroundColor(.secondary) }
            }
            Section(header: Text("Times")) {
                ForEach(pill.times, id: \ .self) { t in
                    HStack { Text(t, style: .time); Spacer(); Button("Taken") { store.markTaken(pill) } }
                }
            }
            Section(header: Text("Stock")) {
                HStack { Text("Stock"); Spacer(); Text(pill.stockCount.map { "\($0)" } ?? "—") }
            }
        }
        .navigationTitle(pill.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    // Quick inline edit could be added; for now simple example
                }
            }
        }
    }
}

#Preview {
    let samplePill = Pill(
        name: "Paracetamol",
        dosage: "500 mg",
        times: [Date()],
        repeatRule: .daily,
        notes: "After meal",
        stockCount: 10
    )
    return NavigationView {
        PillDetailView(pill: samplePill)
    }
}
