import SwiftUI

struct PillSettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Preferences")) {
                Toggle("Dark Mode", isOn: .constant(false))
                NavigationLink("Data Backup/Restore", destination: Text("Backup screen"))
            }
            Section(header: Text("Support")) {
                NavigationLink("FAQs", destination: Text("FAQ"))
                Button("Contact Support") { /* open email */ }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationView {
        PillSettingsView()
    }
}
