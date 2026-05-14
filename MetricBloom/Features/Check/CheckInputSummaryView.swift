
import SwiftUI

extension CheckResult {
    var inputSummaryRows: [(String, String)] {
        switch payload {
        case .shaftHole(let i):
            var rows: [(String, String)] = [
                ("Hole", String(format: "%.4f…%.4f mm", i.holeMin, i.holeMax)),
                ("Shaft", String(format: "%.4f…%.4f mm", i.shaftMin, i.shaftMax)),
            ]
            if let r = i.minRequiredClearance {
                rows.append(("Min. clearance (req.)", String(format: "%.4f mm", r)))
            }
            rows.append(("Joint mode", i.jointIntent == .intendedPress ? "Interference / press" : "Sliding clearance"))
            if let m = i.maxInterferenceMm {
                rows.append(("Max. overlap", String(format: "%.4f mm", m)))
            }
            return rows
        case .clearanceOnly(let c):
            var rows: [(String, String)] = [
                ("Clearance min", String(format: "%.4f mm", c.clearanceMin)),
                ("Clearance max", String(format: "%.4f mm", c.clearanceMax)),
            ]
            if let r = c.minRequired {
                rows.append(("Min. required", String(format: "%.4f mm", r)))
            }
            return rows
        }
    }

    var sharePlainText: String {
        var lines: [String] = [
            "Metric Bloom — Check",
            "",
            kind.rawValue,
            "Bloom \(bloomScore) · \(status.title)",
            "",
        ]
        for row in inputSummaryRows {
            lines.append("\(row.0): \(row.1)")
        }
        lines.append("")
        lines.append(String(format: "Clearance (min…max): %.4f…%.4f mm", clearanceMin, clearanceMax))
        lines.append("")
        lines.append(summary)
        lines.append("")
        lines.append("Date: \(createdAt.formatted(date: .long, time: .shortened))")
        return lines.joined(separator: "\n")
    }
}

struct CheckInputSummaryView: View {
    let result: CheckResult

    var body: some View {
        MBCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Inputs")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MBColor.textSecondary)
                ForEach(Array(result.inputSummaryRows.enumerated()), id: \.offset) { _, row in
                    HStack {
                        Text(row.0)
                            .foregroundStyle(MBColor.textSecondary)
                        Spacer()
                        Text(row.1)
                            .font(.subheadline.weight(.medium).monospacedDigit())
                            .foregroundStyle(MBColor.textPrimary)
                            .multilineTextAlignment(.trailing)
                    }
                    .font(.caption)
                }
            }
        }
    }
}
