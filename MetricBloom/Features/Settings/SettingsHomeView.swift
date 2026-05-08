
import SwiftUI
import UniformTypeIdentifiers

struct SettingsHomeView: View {
    @EnvironmentObject private var stores: AppStores
    @State private var cachedPDFURL: URL?
    @State private var isBuildingPDF = false

    private var exportText: String {
        MBExportPDF.buildPlainText(
            history: stores.history,
            projects: stores.projects,
            compareScenarios: stores.compareScenarios
        )
    }

    private var exportPDF: MBPDFReport {
        MBPDFReport(
            history: stores.history,
            projects: stores.projects,
            compareScenarios: stores.compareScenarios
        )
    }

    private func rebuildPDFCache() {
        guard !isBuildingPDF else { return }
        isBuildingPDF = true

        let history = stores.history
        let projects = stores.projects
        let compareScenarios = stores.compareScenarios

        Task.detached(priority: .utility) {
            let data = MBExportPDF.buildReportData(history: history, projects: projects, compareScenarios: compareScenarios)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("MetricBloom-report-\(Int(Date().timeIntervalSince1970)).pdf")
            do {
                try data.write(to: url, options: .atomic)
                await MainActor.run {
                    cachedPDFURL = url
                    isBuildingPDF = false
                }
            } catch {
                await MainActor.run {
                    cachedPDFURL = nil
                    isBuildingPDF = false
                }
            }
        }
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
                    if let cachedPDFURL {
                        ShareLink(item: cachedPDFURL) {
                            Label("Share PDF", systemImage: "doc.richtext")
                        }
                        .foregroundStyle(MBColor.textPrimary)
                    } else {
                        Label(isBuildingPDF ? "Preparing PDF…" : "Preparing PDF…", systemImage: "doc.richtext")
                            .foregroundStyle(MBColor.textSecondary)
                    }
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
        .task {
            if cachedPDFURL == nil {
                rebuildPDFCache()
            }
        }
        .onChange(of: stores.history.count) { _ in rebuildPDFCache() }
        .onChange(of: stores.projects.count) { _ in rebuildPDFCache() }
        .onChange(of: stores.compareScenarios.count) { _ in rebuildPDFCache() }
    }
}

private struct MBPDFReport: Transferable {
    let history: [CheckResult]
    let projects: [MBProject]
    let compareScenarios: [SavedCompareScenario]

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .pdf) { report in
            let data = MBExportPDF.buildReportData(
                history: report.history,
                projects: report.projects,
                compareScenarios: report.compareScenarios
            )
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("MetricBloom-report-\(Int(Date().timeIntervalSince1970)).pdf")
            try data.write(to: url, options: .atomic)
            return SentTransferredFile(url)
        }
        .suggestedFileName("MetricBloom-report.pdf")
    }
}
