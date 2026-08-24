import SwiftUI

struct AddPillView: View {
    @Environment(\.presentationMode) var presentation
    @State private var name = ""
    @State private var dosage = ""
    @State private var times: [Date] = [Date()]
    @State private var repeatRule: Pill.RepeatRule = .daily
    @State private var notes = ""
    @State private var stock: String = ""

    var onSave: (Pill) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medicine")) {
                    TextField("Name", text: $name)
                    TextField("Dosage (e.g. 500 mg)", text: $dosage)
                }
                Section(header: Text("Times")) {
                    ForEach(times.indices, id: \ .self) { i in
                        DatePicker("Time \(i + 1)", selection: $times[i], displayedComponents: .hourAndMinute)
                    }
                    Button("Add time") { times.append(Date()) }
                }
                Section(header: Text("Repeat")) {
                    Picker("Repeat", selection: $repeatRule) {
                        ForEach(Pill.RepeatRule.allCases, id: \.self) { rule in
                            Text(rule.rawValue.capitalized).tag(rule)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Notes & Stock")) {
                    TextField("Notes (Before/After meal)", text: $notes)
                    TextField("Stock count", text: $stock).keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Pill")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let pill = Pill(name: name, dosage: dosage, times: times, repeatRule: repeatRule, notes: notes.isEmpty ? nil : notes, stockCount: Int(stock))
                        onSave(pill)
                        presentation.wrappedValue.dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentation.wrappedValue.dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddPillView { pill in
        print("Saved pill: \(pill.name)")
    }
}
