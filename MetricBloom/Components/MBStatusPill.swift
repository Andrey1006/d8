
import SwiftUI

extension MBCheckStatus {
    var pillColor: Color {
        switch self {
        case .ok: return MBColor.statusOK
        case .warn: return MBColor.statusWarn
        case .critical: return MBColor.statusBad
        }
    }
}

struct MBStatusPill: View {
    let status: MBCheckStatus

    var body: some View {
        Text(status.title)
            .font(.caption.weight(.bold))
            .foregroundStyle(status.pillColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(status.pillColor.opacity(0.18))
            .clipShape(Capsule())
    }
}

struct MBBloomGauge: View {
    let score: Int

    private var tint: Color {
        switch score {
        case ..<40: return MBColor.statusBad
        case 40 ..< 70: return MBColor.statusWarn
        default: return MBColor.statusOK
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Bloom Score")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(MBColor.textSecondary)
                Spacer()
                Text("\(score)")
                    .font(.title2.weight(.bold).monospacedDigit())
                    .foregroundStyle(MBColor.textPrimary)
            }
            GeometryReader { geo in
                let w = geo.size.width * CGFloat(score) / 100
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(MBColor.surfaceElevated)
                    Capsule()
                        .fill(LinearGradient(
                            colors: [tint.opacity(0.9), MBColor.accentDeep],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: max(8, w))
                }
            }
            .frame(height: 10)
        }
    }
}
