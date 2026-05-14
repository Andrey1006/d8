
import SwiftUI

private enum HistoryStatusFilter: String, CaseIterable, Identifiable {
    case all = "Any status"
    case ok = "OK"
    case warn = "Warning"
    case critical = "Critical"

    var id: String { rawValue }

    func matches(_ status: MBCheckStatus) -> Bool {
        switch self {
        case .all: return true
        case .ok: return status == .ok
        case .warn: return status == .warn
        case .critical: return status == .critical
        }
    }
}

private enum HistoryKindFilter: String, CaseIterable, Identifiable {
    case all = "Any type"
    case shaftHole = "Shaft & hole"
    case clearanceOnly = "Clearance only"

    var id: String { rawValue }

    func matches(_ kind: CheckKind) -> Bool {
        switch self {
        case .all: return true
        case .shaftHole: return kind == .shaftHole
        case .clearanceOnly: return kind == .clearanceOnly
        }
    }
}

private enum HistoryDateFilter: String, CaseIterable, Identifiable {
    case all = "Any date"
    case today = "Today"
    case week = "Last 7 days"
    case month = "Last 30 days"

    var id: String { rawValue }

    func contains(_ date: Date, relativeTo now: Date = Date()) -> Bool {
        let cal = Calendar.current
        switch self {
        case .all:
            return true
        case .today:
            return cal.isDateInToday(date)
        case .week:
            guard let start = cal.date(byAdding: .day, value: -7, to: now) else { return false }
            return date >= start
        case .month:
            guard let start = cal.date(byAdding: .day, value: -30, to: now) else { return false }
            return date >= start
        }
    }
}

struct CheckHistoryView: View {
    @EnvironmentObject private var stores: AppStores
    @State private var searchText = ""
    @State private var statusFilter: HistoryStatusFilter = .all
    @State private var kindFilter: HistoryKindFilter = .all
    @State private var dateFilter: HistoryDateFilter = .all

    private var filteredHistory: [CheckResult] {
        stores.history.filter { item in
            guard statusFilter.matches(item.status) else { return false }
            guard kindFilter.matches(item.kind) else { return false }
            guard dateFilter.contains(item.createdAt) else { return false }
            guard matchesSearch(item) else { return false }
            return true
        }
    }

    private var filtersAreDefault: Bool {
        statusFilter == .all && kindFilter == .all && dateFilter == .all
            && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            MBColor.background.ignoresSafeArea()
            if stores.history.isEmpty {
                emptyTotalState
            } else {
                List {
                    Section {
                        Picker("Status", selection: $statusFilter) {
                            ForEach(HistoryStatusFilter.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        Picker("Task type", selection: $kindFilter) {
                            ForEach(HistoryKindFilter.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        Picker("Date", selection: $dateFilter) {
                            ForEach(HistoryDateFilter.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                    } header: {
                        Text("Filters")
                            .foregroundStyle(MBColor.textSecondary)
                    }
                    .listRowBackground(MBColor.surface)

                    if filteredHistory.isEmpty {
                        Section {
                            Text("No entries match your filters or search.")
                                .font(.subheadline)
                                .foregroundStyle(MBColor.textSecondary)
                                .listRowBackground(MBColor.surface)
                        }
                    } else {
                        Section {
                            ForEach(filteredHistory) { item in
                                NavigationLink(value: item) {
                                    historyRow(item)
                                }
                            }
                            .onDelete { indexSet in
                                let ids = Set(indexSet.map { filteredHistory[$0].id })
                                stores.deleteHistory(ids: ids)
                            }
                        } header: {
                            Text("Results (\(filteredHistory.count))")
                                .foregroundStyle(MBColor.textSecondary)
                        }
                        .listRowBackground(MBColor.surface)
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .searchable(text: $searchText, prompt: "Summary, type, status, Bloom…")
            }
        }
        .navigationTitle("History")
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !stores.history.isEmpty, !filtersAreDefault {
                    Button("Reset filters") {
                        statusFilter = .all
                        kindFilter = .all
                        dateFilter = .all
                        searchText = ""
                    }
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                if !stores.history.isEmpty {
                    Button("Clear", role: .destructive) {
                        stores.clearHistory()
                    }
                }
            }
        }
    }

    private var emptyTotalState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 40))
                .foregroundStyle(MBColor.textSecondary)
            Text("Nothing yet")
                .font(.headline)
                .foregroundStyle(MBColor.textPrimary)
            Text("Runs you perform will show up here.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(MBColor.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    private func historyRow(_ item: CheckResult) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                MBStatusPill(status: item.status)
                Spacer()
                Text("\(item.bloomScore)")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(MBColor.highlight)
            }
            Text(item.kind.rawValue)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(MBColor.textPrimary)
            Text(item.summary)
                .font(.caption)
                .foregroundStyle(MBColor.textSecondary)
                .lineLimit(2)
        }
    }

    private func matchesSearch(_ item: CheckResult) -> Bool {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return true }
        let ql = q.lowercased()
        if item.summary.lowercased().contains(ql) { return true }
        if item.kind.rawValue.lowercased().contains(ql) { return true }
        if item.status.title.lowercased().contains(ql) { return true }
        if String(item.bloomScore).contains(q) { return true }
        return false
    }
}
