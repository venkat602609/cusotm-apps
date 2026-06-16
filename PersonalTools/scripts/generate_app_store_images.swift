import AppKit
import CoreGraphics
import Foundation

struct SizeSpec {
    let folder: String
    let width: Int
    let height: Int
    let deviceName: String
}

struct FeatureSpec {
    let filename: String
    let eyebrow: String
    let title: String
    let subtitle: String
    let primaryMetric: String
    let secondaryMetric: String
    let chartTitle: String
    let labels: [String]
    let values: [CGFloat]
    let colors: [NSColor]
}

let outputRoot = URL(fileURLWithPath: "AppStoreAssets/Screenshots/AppStore")

let sizes = [
    SizeSpec(folder: "iPhone-6.9", width: 1320, height: 2868, deviceName: "iPhone"),
    SizeSpec(folder: "iPhone-6.7", width: 1290, height: 2796, deviceName: "iPhone"),
    SizeSpec(folder: "iPhone-6.5", width: 1284, height: 2778, deviceName: "iPhone"),
    SizeSpec(folder: "iPhone-6.5-legacy", width: 1242, height: 2688, deviceName: "iPhone"),
    SizeSpec(folder: "iPad-13", width: 2064, height: 2752, deviceName: "iPad")
]

let blue = NSColor(calibratedRed: 37 / 255, green: 99 / 255, blue: 235 / 255, alpha: 1)
let teal = NSColor(calibratedRed: 15 / 255, green: 159 / 255, blue: 154 / 255, alpha: 1)
let coral = NSColor(calibratedRed: 249 / 255, green: 115 / 255, blue: 91 / 255, alpha: 1)
let amber = NSColor(calibratedRed: 244 / 255, green: 183 / 255, blue: 64 / 255, alpha: 1)
let ink = NSColor(calibratedRed: 23 / 255, green: 32 / 255, blue: 51 / 255, alpha: 1)
let muted = NSColor(calibratedRed: 93 / 255, green: 107 / 255, blue: 130 / 255, alpha: 1)
let surface = NSColor.white
let page = NSColor(calibratedRed: 247 / 255, green: 251 / 255, blue: 255 / 255, alpha: 1)

let features = [
    FeatureSpec(
        filename: "01-compound-interest.png",
        eyebrow: "Compound Interest",
        title: "See growth build over time",
        subtitle: "Estimate future value and compare your contributions against earned interest.",
        primaryMetric: "$42,580",
        secondaryMetric: "Projected value",
        chartTitle: "Contribution vs interest",
        labels: ["Now", "Year 5", "Year 10", "Year 15", "Year 20"],
        values: [0.18, 0.32, 0.48, 0.68, 0.92],
        colors: [blue, teal, amber, coral]
    ),
    FeatureSpec(
        filename: "02-mortgage-calculator.png",
        eyebrow: "Mortgage Calculator",
        title: "Plan monthly payments clearly",
        subtitle: "Estimate payments, interest, and amortization before making a home decision.",
        primaryMetric: "$2,148",
        secondaryMetric: "Estimated monthly payment",
        chartTitle: "Principal and interest",
        labels: ["Year 1", "Year 5", "Year 10", "Year 20", "Year 30"],
        values: [0.86, 0.72, 0.55, 0.31, 0.08],
        colors: [teal, blue, coral, amber]
    ),
    FeatureSpec(
        filename: "03-fasting-tracker.png",
        eyebrow: "Fasting Tracker",
        title: "Track elapsed fasting time",
        subtitle: "Start a fast, watch elapsed time, and follow milestones as progress builds.",
        primaryMetric: "16h 24m",
        secondaryMetric: "Current fast elapsed",
        chartTitle: "Milestone progress",
        labels: ["4h", "8h", "12h", "16h", "24h"],
        values: [0.22, 0.38, 0.55, 0.74, 0.92],
        colors: [coral, amber, teal, blue]
    )
]

func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
    CGRect(x: x, y: y, width: w, height: h)
}

func drawText(_ text: String, in rect: CGRect, font: NSFont, color: NSColor, alignment: NSTextAlignment = .left) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = alignment
    paragraph.lineBreakMode = .byWordWrapping
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph
    ]
    NSString(string: text).draw(in: rect, withAttributes: attributes)
}

func drawRoundedRect(_ rect: CGRect, radius: CGFloat, fill: NSColor, stroke: NSColor? = nil, lineWidth: CGFloat = 1) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    fill.setFill()
    path.fill()
    if let stroke {
        stroke.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
}

func drawPill(_ rect: CGRect, text: String, color: NSColor, fontSize: CGFloat) {
    drawRoundedRect(rect, radius: rect.height / 2, fill: color.withAlphaComponent(0.12))
    drawText(text, in: rect.insetBy(dx: 22, dy: (rect.height - fontSize * 1.25) / 2), font: .systemFont(ofSize: fontSize, weight: .semibold), color: color)
}

func drawBars(in rect: CGRect, values: [CGFloat], colors: [NSColor]) {
    let count = values.count
    let gap = rect.width * 0.035
    let barWidth = (rect.width - gap * CGFloat(count - 1)) / CGFloat(count)
    for index in 0..<count {
        let value = max(0.05, min(values[index], 1))
        let height = rect.height * value
        let bar = CGRect(x: rect.minX + CGFloat(index) * (barWidth + gap), y: rect.maxY - height, width: barWidth, height: height)
        drawRoundedRect(bar, radius: min(18, barWidth / 3), fill: colors[index % colors.count])
    }
}

func drawLine(in rect: CGRect, values: [CGFloat], color: NSColor) {
    let path = NSBezierPath()
    for index in 0..<values.count {
        let x = rect.minX + CGFloat(index) * (rect.width / CGFloat(values.count - 1))
        let y = rect.maxY - rect.height * values[index]
        if index == 0 {
            path.move(to: CGPoint(x: x, y: y))
        } else {
            path.line(to: CGPoint(x: x, y: y))
        }
    }
    color.setStroke()
    path.lineWidth = 8
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    path.stroke()
}

func drawAppMockup(in frame: CGRect, feature: FeatureSpec, scale: CGFloat) {
    drawRoundedRect(frame, radius: 58 * scale, fill: NSColor(calibratedRed: 16 / 255, green: 24 / 255, blue: 39 / 255, alpha: 1))
    let screen = frame.insetBy(dx: 24 * scale, dy: 24 * scale)
    drawRoundedRect(screen, radius: 42 * scale, fill: NSColor(calibratedRed: 250 / 255, green: 253 / 255, blue: 255 / 255, alpha: 1))

    let safe = screen.insetBy(dx: 42 * scale, dy: 46 * scale)
    drawText("OrbitKit", in: rect(safe.minX, safe.minY, safe.width, 42 * scale), font: .systemFont(ofSize: 34 * scale, weight: .bold), color: ink)
    drawPill(rect(safe.minX, safe.minY + 58 * scale, 230 * scale, 48 * scale), text: feature.eyebrow, color: feature.colors[0], fontSize: 18 * scale)

    let metric = rect(safe.minX, safe.minY + 136 * scale, safe.width, 190 * scale)
    drawRoundedRect(metric, radius: 22 * scale, fill: surface, stroke: NSColor(calibratedWhite: 0.88, alpha: 1))
    drawText(feature.primaryMetric, in: metric.insetBy(dx: 28 * scale, dy: 26 * scale), font: .systemFont(ofSize: 58 * scale, weight: .bold), color: ink)
    drawText(feature.secondaryMetric, in: rect(metric.minX + 28 * scale, metric.minY + 105 * scale, metric.width - 56 * scale, 36 * scale), font: .systemFont(ofSize: 22 * scale, weight: .medium), color: muted)

    let chart = rect(safe.minX, metric.maxY + 28 * scale, safe.width, 360 * scale)
    drawRoundedRect(chart, radius: 22 * scale, fill: surface, stroke: NSColor(calibratedWhite: 0.88, alpha: 1))
    drawText(feature.chartTitle, in: rect(chart.minX + 28 * scale, chart.minY + 24 * scale, chart.width - 56 * scale, 34 * scale), font: .systemFont(ofSize: 22 * scale, weight: .semibold), color: ink)
    let chartArea = rect(chart.minX + 36 * scale, chart.minY + 86 * scale, chart.width - 72 * scale, 210 * scale)
    if feature.filename.contains("mortgage") {
        drawLine(in: chartArea, values: feature.values, color: feature.colors[0])
    } else {
        drawBars(in: chartArea, values: feature.values, colors: feature.colors)
    }
    for (index, label) in feature.labels.enumerated() {
        let w = chartArea.width / CGFloat(feature.labels.count)
        drawText(label, in: rect(chartArea.minX + CGFloat(index) * w, chartArea.maxY + 22 * scale, w, 28 * scale), font: .systemFont(ofSize: 15 * scale, weight: .medium), color: muted, alignment: .center)
    }

    let tabs = rect(safe.minX, screen.maxY - 106 * scale, safe.width, 64 * scale)
    drawRoundedRect(tabs, radius: 22 * scale, fill: NSColor(calibratedRed: 241 / 255, green: 247 / 255, blue: 251 / 255, alpha: 1))
    let tabLabels = ["Compound", "Mortgage", "Fasting"]
    for (index, label) in tabLabels.enumerated() {
        let tab = rect(tabs.minX + CGFloat(index) * tabs.width / 3, tabs.minY, tabs.width / 3, tabs.height)
        let active = feature.eyebrow.lowercased().contains(label.lowercased().split(separator: " ").first ?? "")
        drawText(label, in: tab.insetBy(dx: 8 * scale, dy: 20 * scale), font: .systemFont(ofSize: 16 * scale, weight: active ? .bold : .medium), color: active ? feature.colors[0] : muted, alignment: .center)
    }
}

func createImage(size: SizeSpec, feature: FeatureSpec) throws {
    let width = CGFloat(size.width)
    let height = CGFloat(size.height)
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size.width,
        pixelsHigh: size.height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ), let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw NSError(domain: "OrbitKitImageGenerator", code: 1)
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphicsContext
    defer { NSGraphicsContext.restoreGraphicsState() }

    page.setFill()
    rect(0, 0, width, height).fill()

    let gradient = NSGradient(colors: [
        feature.colors[0].withAlphaComponent(0.22),
        NSColor.white.withAlphaComponent(0.2),
        feature.colors[2].withAlphaComponent(0.18)
    ])!
    gradient.draw(in: rect(0, 0, width, height), angle: -35)

    let margin = width * 0.075
    let top = height * 0.065
    let titleSize = size.folder.contains("iPad") ? width * 0.065 : width * 0.092
    let bodySize = size.folder.contains("iPad") ? width * 0.024 : width * 0.04

    drawPill(rect(margin, top, width * 0.33, height * 0.034), text: feature.eyebrow, color: feature.colors[0], fontSize: bodySize * 0.72)
    drawText(feature.title, in: rect(margin, top + height * 0.06, width - margin * 2, height * 0.15), font: .systemFont(ofSize: titleSize, weight: .heavy), color: ink)
    drawText(feature.subtitle, in: rect(margin, top + height * 0.205, width - margin * 2, height * 0.085), font: .systemFont(ofSize: bodySize, weight: .regular), color: muted)

    let mockWidth: CGFloat
    let mockHeight: CGFloat
    if size.folder.contains("iPad") {
        mockWidth = width * 0.64
        mockHeight = height * 0.52
    } else {
        mockWidth = width * 0.72
        mockHeight = height * 0.50
    }
    let mock = rect((width - mockWidth) / 2, height - mockHeight - height * 0.08, mockWidth, mockHeight)
    drawAppMockup(in: mock, feature: feature, scale: mockWidth / 760)

    drawText("OrbitKit", in: rect(margin, height - height * 0.048, width - margin * 2, height * 0.03), font: .systemFont(ofSize: bodySize * 0.78, weight: .semibold), color: muted, alignment: .center)

    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "OrbitKitImageGenerator", code: 2)
    }

    let directory = outputRoot.appendingPathComponent(size.folder)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try png.write(to: directory.appendingPathComponent(feature.filename))
}

for size in sizes {
    for feature in features {
        try createImage(size: size, feature: feature)
    }
}

print("Generated App Store images in \(outputRoot.path)")
