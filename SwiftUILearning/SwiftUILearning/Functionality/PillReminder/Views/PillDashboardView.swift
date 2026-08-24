import SwiftUI

struct PillDashboardView: View {
    @StateObject private var store = PillStore.shared
    @State private var showAdd = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [AppTheme.accent.opacity(0.1), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                PillHomeView()
            }
            .navigationTitle("PillPal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAdd.toggle() }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddPillView { newPill in
                    store.add(newPill)
                    showAdd = false
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    PillDashboardView()
}
