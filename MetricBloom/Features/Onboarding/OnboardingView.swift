
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var stores: AppStores
    @Binding var isPresented: Bool
    @State private var page = 0

    private let pages: [(String, String, String)] = [
        ("Metric Bloom", "Fast clearance and tolerance checks before assembly.", "bolt.horizontal.circle"),
        ("Bloom Score", "A 0–100 score for how robust the system is to variation.", "leaf.circle"),
        ("Statuses", "Green — OK, yellow — tight margin, red — interference risk or below minimum.", "exclamationmark.triangle"),
    ]

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer(minLength: 20)
                Image(systemName: pages[page].2)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundStyle(LinearGradient.mbBrand)
                    .shadow(color: MBColor.glowSoft, radius: 16)
                Text(pages[page].0)
                    .font(.title.bold())
                    .foregroundStyle(MBColor.textPrimary)
                    .multilineTextAlignment(.center)
                Text(pages[page].1)
                    .font(.body)
                    .foregroundStyle(MBColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                HStack(spacing: 8) {
                    ForEach(0 ..< pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? MBColor.accentOrange : MBColor.border)
                            .frame(width: i == page ? 24 : 8, height: 8)
                    }
                }
                .padding(.top, 8)
                Spacer()
                if page < pages.count - 1 {
                    MBGradientButton(title: "Next") {
                        withAnimation { page += 1 }
                    }
                    MBSecondaryButton(title: "Skip") {
                        finish()
                    }
                } else {
                    MBGradientButton(title: "Get started") {
                        finish()
                    }
                }
            }
            .padding(24)
        }
    }

    private func finish() {
        if !stores.settings.hasCompletedOnboarding {
            stores.completeOnboarding()
        }
        stores.replayOnboardingVisible = false
        isPresented = false
    }
}
