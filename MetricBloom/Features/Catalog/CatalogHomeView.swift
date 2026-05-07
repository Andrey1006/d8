
import SwiftUI

struct CatalogHomeView: View {
    @EnvironmentObject private var stores: AppStores
    @State private var query = ""

    private var filtered: [CatalogFit] {
        let base = CatalogData.fits
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return base }
        return base.filter {
            $0.title.lowercased().contains(q)
                || $0.system.lowercased().contains(q)
                || $0.description.lowercased().contains(q)
        }
    }

    private var favorites: [CatalogFit] {
        CatalogData.fits.filter { stores.isFavorite($0.id) }
    }

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            List {
                if !favorites.isEmpty {
                    Section {
                        ForEach(favorites) { fit in
                            NavigationLink(value: fit) {
                                fitRow(fit)
                            }
                        }
                    } header: {
                        Text("Favorites")
                            .foregroundStyle(MBColor.textSecondary)
                    }
                    .listRowBackground(MBColor.surface)
                }
                Section {
                    ForEach(filtered) { fit in
                        NavigationLink(value: fit) {
                            fitRow(fit)
                        }
                    }
                } header: {
                    Text("Reference")
                        .foregroundStyle(MBColor.textSecondary)
                }
                .listRowBackground(MBColor.surface)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .searchable(text: $query, prompt: "Search fits")
        }
        .navigationTitle("Catalog")
        .navigationDestination(for: CatalogFit.self) { fit in
            CatalogDetailView(fit: fit)
        }
    }

    private func fitRow(_ fit: CatalogFit) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(fit.title)
                    .font(.headline)
                    .foregroundStyle(MBColor.textPrimary)
                Text("\(fit.system) · \(fit.diameterRange)")
                    .font(.caption)
                    .foregroundStyle(MBColor.textSecondary)
            }
            Spacer()
            if stores.isFavorite(fit.id) {
                Image(systemName: "star.fill")
                    .foregroundStyle(MBColor.highlight)
            }
        }
        .padding(.vertical, 4)
    }
}
