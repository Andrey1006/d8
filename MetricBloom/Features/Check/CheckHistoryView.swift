
import SwiftUI

struct CheckHistoryView: View {
    @EnvironmentObject private var stores: AppStores

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            if stores.history.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 40))
                        .foregroundStyle(MBColor.textSecondary)
                    Text("Nothing yet")
                        .font(.headline)
                        .foregroundStyle(MBColor.textPrimary)
                    Text("Runs you perform will show up here.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(MBColor.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(32)
            } else {
                List {
                    ForEach(stores.history) { item in
                        NavigationLink(value: item) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    MBStatusPill(status: item.status)
                                    Spacer()
                                    Text("\(item.bloomScore)")
                                        .font(.caption.weight(.bold).monospacedDigit())
                                        .foregroundStyle(MBColor.highlight)
                                }
                                Text(item.kind.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(MBColor.textPrimary)
                                Text(item.summary)
                                    .font(.caption)
                                    .foregroundStyle(MBColor.textSecondary)
                                    .lineLimit(2)
                            }
                            .listRowBackground(MBColor.surface)
                        }
                    }
                    .onDelete(perform: stores.deleteHistory)
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }
        }
        .navigationTitle("History")
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            if !stores.history.isEmpty {
                Button("Clear", role: .destructive) {
                    stores.clearHistory()
                }
            }
        }
    }
}
