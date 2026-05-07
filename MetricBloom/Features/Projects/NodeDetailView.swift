
import SwiftUI

struct NodeDetailView: View {
    @EnvironmentObject private var stores: AppStores
    let projectId: UUID
    let node: AssemblyNode
    @State private var showRenameNode = false
    @State private var renameNodeText = ""

    private var liveProject: MBProject? {
        stores.projects.first(where: { $0.id == projectId })
    }

    private var liveNode: AssemblyNode? {
        liveProject?.nodes.first(where: { $0.id == node.id })
    }

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            if let liveNode {
                List {
                    Section {
                        MBCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Node")
                                        .foregroundStyle(MBColor.textSecondary)
                                    Spacer()
                                    MBStatusPill(status: liveNode.worstStatus)
                                }
                                MBBloomGauge(score: liveNode.minBloom)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                    }
                    Section {
                        if liveNode.checks.isEmpty {
                            Text("Add a check from the result screen using “Save to project”.")
                                .font(.subheadline)
                                .foregroundStyle(MBColor.textSecondary)
                                .listRowBackground(MBColor.surface)
                        } else {
                            ForEach(liveNode.checks) { check in
                                NavigationLink(value: check) {
                                    checkSnippet(check)
                                }
                                .listRowBackground(MBColor.surface)
                            }
                            .onDelete(perform: deleteChecks)
                        }
                    } header: {
                        Text("Checks")
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            } else {
                Text("Node not found")
                    .foregroundStyle(MBColor.textSecondary)
            }
        }
        .navigationTitle(liveNode?.name ?? "Node")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: CheckResult.self) { result in
            CheckResultView(result: result)
                .environmentObject(stores)
        }
        .sheet(isPresented: $showRenameNode) {
            RenameNodeSheet(projectId: projectId, nodeId: node.id, text: $renameNodeText)
                .environmentObject(stores)
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    renameNodeText = liveNode?.name ?? ""
                    showRenameNode = true
                } label: {
                    Text("Name")
                }
            }
        }
    }

    private func deleteChecks(at offsets: IndexSet) {
        guard let liveNode else { return }
        for idx in offsets.sorted(by: >) {
            let check = liveNode.checks[idx]
            stores.removeCheck(projectId: projectId, nodeId: node.id, checkId: check.id)
        }
    }

    private func checkSnippet(_ check: CheckResult) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(check.kind.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(MBColor.textPrimary)
                Text(check.summary)
                    .font(.caption2)
                    .foregroundStyle(MBColor.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                MBStatusPill(status: check.status)
                Text("\(check.bloomScore)")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(MBColor.highlight)
            }
        }
        .padding(.vertical, 4)
    }
}

struct RenameNodeSheet: View {
    @EnvironmentObject private var stores: AppStores
    @Environment(\.dismiss) private var dismiss
    let projectId: UUID
    let nodeId: UUID
    @Binding var text: String

    var body: some View {
        NavigationStack {
            ZStack {
                MBColor.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    MBCard {
                        TextField("Node name", text: $text)
                            .foregroundStyle(MBColor.textPrimary)
                    }
                    Spacer()
                    MBGradientButton(title: "Save", isEnabled: !text.trimmingCharacters(in: .whitespaces).isEmpty) {
                        stores.renameNode(projectId: projectId, nodeId: nodeId, name: text.trimmingCharacters(in: .whitespaces))
                        dismiss()
                    }
                }
                .padding(20)
            }
            .navigationTitle("Node")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
