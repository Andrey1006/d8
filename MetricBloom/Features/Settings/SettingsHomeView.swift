
import SwiftUI
import UIKit

struct SettingsHomeView: View {
    @EnvironmentObject private var stores: AppStores
    @State private var pdfURL: URL?
    @State private var showPdfShare = false

    private var exportText: String {
        MBExportPDF.buildPlainText(
            history: stores.history,
            projects: stores.projects,
            compareScenarios: stores.compareScenarios
        )
    }

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            List {
                Section {
                    Toggle("Haptic feedback", isOn: Binding(
                        get: { stores.settings.hapticsEnabled },
                        set: { v in stores.updateSettings { $0.hapticsEnabled = v } }
                    ))
                    .tint(MBColor.accentOrange)
                    Button("Show onboarding again") {
                        stores.replayOnboardingVisible = true
                    }
                    .foregroundStyle(MBColor.accentOrange)
                } header: {
                    Text("Behavior")
                }
                .listRowBackground(MBColor.surface)

                Section {
                    ShareLink(item: exportText) {
                        Label("Export text", systemImage: "doc.text")
                    }
                    Button {
                        pdfURL = MBExportPDF.temporaryPDFURL(
                            history: stores.history,
                            projects: stores.projects,
                            compareScenarios: stores.compareScenarios
                        )
                        showPdfShare = true
                    } label: {
                        Label("Share PDF", systemImage: "doc.richtext")
                    }
                    .foregroundStyle(MBColor.textPrimary)
                } header: {
                    Text("Data")
                }
                .listRowBackground(MBColor.surface)

                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                } header: {
                    Text("Help")
                }
                .listRowBackground(MBColor.surface)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showPdfShare, onDismiss: { pdfURL = nil }) {
            if let pdfURL {
                ShareSheet(activityItems: [pdfURL])
            }
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
