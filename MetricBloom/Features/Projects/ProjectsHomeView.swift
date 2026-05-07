
import SwiftUI

struct ProjectsHomeView: View {
    @EnvironmentObject private var stores: AppStores
    @State private var showNew = false

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            if stores.projects.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.down.forward")
                        .font(.system(size: 40))
                        .foregroundStyle(MBColor.textSecondary)
                    Text("No projects")
                        .font(.headline)
                        .foregroundStyle(MBColor.textPrimary)
                    Text("Create a project or save a check from the result screen.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(MBColor.textSecondary)
                    MBGradientButton(title: "New project") {
                        showNew = true
                    }
                    .padding(.top, 8)
                }
                .padding(32)
            } else {
                List {
                    ForEach(stores.projects) { project in
                        NavigationLink(value: project) {
                            projectRow(project)
                        }
                    }
                    .onDelete(perform: stores.deleteProject)
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }
        }
        .navigationTitle("Projects")
        .toolbar {
            Button {
                showNew = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .navigationDestination(for: MBProject.self) { project in
            ProjectDetailView(project: project)
        }
        .sheet(isPresented: $showNew) {
            NewProjectSheet()
                .environmentObject(stores)
        }
    }

    private func projectRow(_ project: MBProject) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(project.name)
                    .font(.headline)
                    .foregroundStyle(MBColor.textPrimary)
                Text("\(project.nodes.count) nodes · Bloom \(project.projectBloom)")
                    .font(.caption)
                    .foregroundStyle(MBColor.textSecondary)
            }
            Spacer()
            MBStatusPill(status: project.worstStatus)
        }
        .padding(.vertical, 4)
    }
}

struct NewProjectSheet: View {
    @EnvironmentObject private var stores: AppStores
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        NavigationStack {
            ZStack {
                MBColor.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 16) {
                    MBCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(MBColor.textSecondary)
                            TextField("e.g. Gearbox R3", text: $name)
                                .foregroundStyle(MBColor.textPrimary)
                        }
                    }
                    Spacer()
                    MBGradientButton(title: "Create", isEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty) {
                        let p = MBProject(name: name.trimmingCharacters(in: .whitespaces))
                        stores.upsertProject(p)
                        dismiss()
                    }
                }
                .padding(20)
            }
            .navigationTitle("New project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
