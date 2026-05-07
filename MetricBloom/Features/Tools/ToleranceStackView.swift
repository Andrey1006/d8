
import SwiftUI

private struct StackRow: Identifiable {
    let id = UUID()
    var text: String
}

private enum StackMode: String, CaseIterable, Identifiable {
    case worst = "Worst-case"
    case rss = "RSS"

    var id: String { rawValue }
}

struct ToleranceStackView: View {
    @State private var rows: [StackRow] = [
        StackRow(text: "0.02"),
        StackRow(text: "0.01"),
        StackRow(text: "0.015"),
    ]
    @State private var mode: StackMode = .worst

    private var values: [Double] {
        rows.compactMap { MBNumberParse.double($0.text) }.filter { $0 >= 0 }
    }

    private var worstCase: Double {
        values.reduce(0, +)
    }

    private var rss: Double {
        guard !values.isEmpty else { return 0 }
        let sumSq = values.map { $0 * $0 }.reduce(0, +)
        return sqrt(sumSq)
    }

    private var total: Double {
        mode == .worst ? worstCase : rss
    }

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("Mode", selection: $mode) {
                        ForEach(StackMode.allCases) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(mode == .worst
                        ? "Sum of positive tolerances (conservative)."
                        : "RSS: √(t₁²+t₂²+…), for independent dimensional chains.")
                        .font(.subheadline)
                        .foregroundStyle(MBColor.textSecondary)
                    ForEach($rows) { $row in
                        HStack {
                            MBNumericField(title: "Link", text: $row.text)
                            Button(role: .destructive) {
                                if rows.count > 1 {
                                    rows.removeAll { $0.id == row.id }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                            }
                            .disabled(rows.count <= 1)
                        }
                    }
                    MBSecondaryButton(title: "Add link") {
                        rows.append(StackRow(text: "0.01"))
                    }
                    MBCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(mode == .worst ? "Worst-case total" : "RSS total")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MBColor.textSecondary)
                            Text(String(format: "± %.4f mm", total))
                                .font(.title2.bold().monospacedDigit())
                                .foregroundStyle(MBColor.textPrimary)
                        }
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Stack")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}
