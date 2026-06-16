import SwiftUI

extension Color {
    static let appTeal = Color(red: 0.96, green: 0.31, blue: 0.38)
    static let appInk = Color(red: 0.16, green: 0.12, blue: 0.22)
    static let appSurface = Color(red: 0.98, green: 0.98, blue: 1.0)
    static let appBlue = Color(red: 0.13, green: 0.52, blue: 0.96)
    static let appMint = Color(red: 0.15, green: 0.72, blue: 0.56)
    static let appAmber = Color(red: 0.96, green: 0.63, blue: 0.18)
}

struct MetricTile: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(Color.appTeal)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.appInk)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [Color.appSurface, Color.appBlue.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

enum Formatters {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static let currencyWithCents: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

extension Double {
    var currencyText: String {
        Formatters.currency.string(from: NSNumber(value: self)) ?? "$0"
    }

    var currencyWithCentsText: String {
        Formatters.currencyWithCents.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}
