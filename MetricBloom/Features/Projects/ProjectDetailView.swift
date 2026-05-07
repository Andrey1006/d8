
import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject private var stores: AppStores
    let project: MBProject
    @State private var notes: String = ""
    @State private var showAddNode = false
    @State private var showRenameProject = false
    @State private var renameProjectText = ""
    @State private var showDeleteConfirm = false

    private var live: MBProject {
        stores.projects.first(where: { $0.id == project.id }) ?? project
    }

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    MBCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Assembly status")
                                    .foregroundStyle(MBColor.textSecondary)
                                Spacer()
                                MBStatusPill(status: live.worstStatus)
                            }
                            MBBloomGauge(score: live.projectBloom)
                            Text("Updated \(live.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(MBColor.textSecondary)
                        }
                    }
                    MBCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MBColor.textSecondary)
                            TextField("Notes for the team…", text: $notes, axis: .vertical)
                                .lineLimit(3 ... 8)
                                .foregroundStyle(MBColor.textPrimary)
                                .onAppear { notes = live.notes }
                                .onChange(of: notes) { _ in persistNotes() }
                        }
                    }
                    HStack {
                        Text("Nodes")
                            .font(.headline)
                            .foregroundStyle(MBColor.textPrimary)
                        Spacer()
                        Button {
                            showAddNode = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(LinearGradient.mbBrand)
                        }
                    }
                    ForEach(live.nodes) { node in
                        NavigationLink(value: node) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(node.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(MBColor.textPrimary)
                                    Text("\(node.checks.count) checks · Bloom \(node.minBloom)")
                                        .font(.caption2)
                                        .foregroundStyle(MBColor.textSecondary)
                                }
                                Spacer()
                                MBStatusPill(status: node.worstStatus)
                            }
                            .padding(14)
                            .background(MBColor.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(MBColor.border, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(live.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: AssemblyNode.self) { node in
            NodeDetailView(projectId: live.id, node: node)
        }
        .sheet(isPresented: $showAddNode) {
            AddNodeSheet(projectId: live.id)
                .environmentObject(stores)
        }
        .sheet(isPresented: $showRenameProject) {
            RenameProjectSheet(projectId: live.id, text: $renameProjectText)
                .environmentObject(stores)
        }
        .confirmationDialog("Delete project “\(live.name)”?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                stores.deleteProject(live)
            }
            Button("Cancel", role: .cancel) {}
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Rename") {
                        renameProjectText = live.name
                        showRenameProject = true
                    }
                    Button("Delete project", role: .destructive) {
                        showDeleteConfirm = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    private func persistNotes() {
        var p = live
        p.notes = notes
        p.updatedAt = Date()
        stores.upsertProject(p)
    }
}

struct RenameProjectSheet: View {
    @EnvironmentObject private var stores: AppStores
    @Environment(\.dismiss) private var dismiss
    let projectId: UUID
    @Binding var text: String

    var body: some View {
        NavigationStack {
            ZStack {
                MBColor.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    MBCard {
                        TextField("Name", text: $text)
                            .foregroundStyle(MBColor.textPrimary)
                    }
                    Spacer()
                    MBGradientButton(title: "Save", isEnabled: !text.trimmingCharacters(in: .whitespaces).isEmpty) {
                        stores.renameProject(projectId: projectId, name: text.trimmingCharacters(in: .whitespaces))
                        dismiss()
                    }
                }
                .padding(20)
            }
            .navigationTitle("Rename")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct AddNodeSheet: View {
    @EnvironmentObject private var stores: AppStores
    @Environment(\.dismiss) private var dismiss
    let projectId: UUID
    @State private var name = "New node"

    var body: some View {
        NavigationStack {
            ZStack {
                MBColor.background.ignoresSafeArea()
                VStack(spacing: 16) {
                    MBCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Node name")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MBColor.textSecondary)
                            TextField("Node", text: $name)
                                .foregroundStyle(MBColor.textPrimary)
                        }
                    }
                    Spacer()
                    MBGradientButton(title: "Add", isEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty) {
                        guard var project = stores.projects.first(where: { $0.id == projectId }) else { return }
                        project.nodes.append(AssemblyNode(name: name.trimmingCharacters(in: .whitespaces)))
                        project.updatedAt = Date()
                        stores.upsertProject(project)
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
