import SwiftUI

struct PillRowView: View {
    var pill: Pill

    var body: some View {
        HStack {
            Image(systemName: "pills")
                .frame(width: 36, height: 36)
                .background(RoundedRectangle(cornerRadius: 8).fill(AppTheme.accent.opacity(0.15)))
            VStack(alignment: .leading) {
                Text(pill.name).bold()
                Text(pill.dosage).font(.footnote).foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                if let next = pill.times.first {
                    Text(next, style: .time)
                }
                if let stock = pill.stockCount {
                    Text("\(stock) left").font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let samplePill = Pill(
        name: "Amoxicillin",
        dosage: "250 mg",
        times: [Date()],
        repeatRule: .daily,
        notes: "After lunch",
        stockCount: 6
    )
    return PillRowView(pill: samplePill)
        .previewLayout(.sizeThatFits)
        .padding()
}
