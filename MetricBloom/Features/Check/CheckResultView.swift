
import SwiftUI

struct CheckResultView: View {
    @EnvironmentObject private var stores: AppStores
    let result: CheckResult
    @State private var showSaveProject = false

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        MBStatusPill(status: result.status)
                        Spacer()
                        Text(result.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(MBColor.textSecondary)
                    }
                    MBBloomGauge(score: result.bloomScore)
                    CheckInputSummaryView(result: result)
                    MBCard {
                        VStack(alignment: .leading, spacing: 10) {
                            row("Min. clearance", value(result.clearanceMin))
                            row("Max. clearance", value(result.clearanceMax))
                            Divider().overlay(MBColor.border)
                            Text(result.summary)
                                .font(.subheadline)
                                .foregroundStyle(MBColor.textSecondary)
                        }
                    }
                    MBSecondaryButton(title: "Save to project…") {
                        showSaveProject = true
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showSaveProject) {
            SaveCheckToProjectSheet(result: result)
                .environmentObject(stores)
        }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(MBColor.textSecondary)
            Spacer()
            Text(value)
                .font(.body.weight(.semibold).monospacedDigit())
                .foregroundStyle(MBColor.textPrimary)
        }
        .font(.subheadline)
    }

    private func value(_ mm: Double) -> String {
        String(format: "%.4f mm", mm)
    }
}

struct SaveCheckToProjectSheet: View {
    @EnvironmentObject private var stores: AppStores
    @Environment(\.dismiss) private var dismiss
    let result: CheckResult
    @State private var projectId: UUID?
    @State private var newProjectName = ""
    @State private var nodeName = "Joint 1"

    var body: some View {
        NavigationStack {
            Form {
                Section("Project") {
                    Picker("Existing", selection: $projectId) {
                        Text("— New project —").tag(Optional<UUID>.none)
                        ForEach(stores.projects) { p in
                            Text(p.name).tag(Optional(p.id))
                        }
                    }
                    if projectId == nil {
                        TextField("Project name", text: $newProjectName)
                    }
                }
                Section("Node") {
                    TextField("Node name", text: $nodeName)
                }
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .background(MBColor.background)
            .navigationTitle("Save to project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(); dismiss() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        if let projectId, stores.projects.contains(where: { $0.id == projectId }) {
            return !nodeName.trimmingCharacters(in: .whitespaces).isEmpty
        }
        return !newProjectName.trimmingCharacters(in: .whitespaces).isEmpty && !nodeName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func save() {
        let trimmedNode = nodeName.trimmingCharacters(in: .whitespaces)
        if let projectId,
           var project = stores.projects.first(where: { $0.id == projectId })
        {
            if let idx = project.nodes.firstIndex(where: { $0.name == trimmedNode }) {
                project.nodes[idx].checks.append(result)
            } else {
                project.nodes.append(AssemblyNode(name: trimmedNode, checks: [result]))
            }
            project.updatedAt = Date()
            stores.upsertProject(project)
            return
        }
        let name = newProjectName.trimmingCharacters(in: .whitespaces)
        let node = AssemblyNode(name: trimmedNode, checks: [result])
        let project = MBProject(name: name, nodes: [node])
        stores.upsertProject(project)
    }
}
