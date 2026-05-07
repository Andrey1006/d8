
import UIKit

enum MBExportPDF {
    private static let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)

    static func buildReportData(
        history: [CheckResult],
        projects: [MBProject],
        compareScenarios: [SavedCompareScenario]
    ) -> Data {
        let text = buildPlainText(history: history, projects: projects, compareScenarios: compareScenarios)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let bodyAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black,
        ]
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 15),
            .foregroundColor: UIColor.black,
        ]
        return renderer.pdfData { ctx in
            ctx.beginPage()
            let margin: CGFloat = 44
            var y: CGFloat = margin
            ("Metric Bloom — Report" as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttrs)
            y += 26
            let lines = text.components(separatedBy: "\n")
            for line in lines {
                if y > pageRect.height - margin - 18 {
                    ctx.beginPage()
                    y = margin
                }
                let ns = line as NSString
                let size = ns.boundingRect(
                    with: CGSize(width: pageRect.width - 2 * margin, height: 800),
                    options: [.usesLineFragmentOrigin],
                    attributes: bodyAttrs,
                    context: nil
                ).size
                ns.draw(
                    with: CGRect(x: margin, y: y, width: pageRect.width - 2 * margin, height: max(14, ceil(size.height))),
                    options: [.usesLineFragmentOrigin],
                    attributes: bodyAttrs,
                    context: nil
                )
                y += max(14, ceil(size.height)) + 2
            }
        }
    }

    static func buildPlainText(
        history: [CheckResult],
        projects: [MBProject],
        compareScenarios: [SavedCompareScenario]
    ) -> String {
        var lines: [String] = ["Metric Bloom", ""]
        lines.append("History (\(history.count)):")
        for h in history.prefix(20) {
            lines.append("— \(h.kind.rawValue) | Bloom \(h.bloomScore) | \(h.status.title)")
            lines.append("  \(h.summary)")
        }
        lines.append("")
        lines.append("Projects (\(projects.count)):")
        for p in projects.prefix(15) {
            lines.append("— \(p.name) | Bloom \(p.projectBloom) | \(p.worstStatus.title)")
        }
        lines.append("")
        lines.append("Saved comparisons (\(compareScenarios.count)):")
        for s in compareScenarios.prefix(15) {
            lines.append("— \(s.title) | A: Bloom \(s.resultA.bloomScore) | B: Bloom \(s.resultB.bloomScore)")
        }
        return lines.joined(separator: "\n")
    }

    static func temporaryPDFURL(
        history: [CheckResult],
        projects: [MBProject],
        compareScenarios: [SavedCompareScenario]
    ) -> URL {
        let data = buildReportData(history: history, projects: projects, compareScenarios: compareScenarios)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("MetricBloom-report-\(Int(Date().timeIntervalSince1970)).pdf")
        try? data.write(to: url)
        return url
    }
}
