import SwiftUI

struct DetailView: View {
    let term: String
    @State private var summary: String?
    @State private var loading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if loading {
                ProgressView("Fetching info…")
            }
            if let s = summary {
                ScrollView {
                    Text(s)
                        .padding()
                }
            } else {
                Text("No description found for '\(term)'.")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .navigationTitle(term)
        .task {
            await fetchWikiSummary(for: term)
        }
        .padding()
    }

    func fetchWikiSummary(for query: String) async {
        loading = true
        defer { loading = false }
        let safe = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? query
        let urlStr = "https://en.wikipedia.org/api/rest_v1/page/summary/\(safe)"
        guard let url = URL(string: urlStr) else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let extract = json["extract"] as? String {
                    summary = extract
                } else {
                    summary = "No summary found."
                }
            } else {
                summary = "No wikipedia page found for \(query)."
            }
        } catch {
            summary = "Error fetching Wikipedia: \(error.localizedDescription)"
        }
    }
}
