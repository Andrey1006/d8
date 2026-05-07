
import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Metric Bloom helps engineers quickly verify clearances and tolerances, assess assembly risk, and capture node projects.")
                        .foregroundStyle(MBColor.textSecondary)
                    MBCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Version 1.0")
                                .font(.headline)
                                .foregroundStyle(MBColor.textPrimary)
                            Text("Calculations are indicative; for certification use approved methods and full standards.")
                                .font(.footnote)
                                .foregroundStyle(MBColor.textSecondary)
                        }
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}
