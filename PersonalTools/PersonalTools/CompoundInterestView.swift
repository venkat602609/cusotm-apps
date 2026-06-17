import SwiftUI
import Charts

struct CompoundInterestView: View {
    @State private var principal = 10000.0
    @State private var monthlyContribution = 250.0
    @State private var annualRate = 7.0
    @State private var years = 20.0
    @State private var compoundsPerYear = 12.0

    private var result: CompoundInterestResult {
        let months = Int(years * 12)
        let periodicRate = annualRate / 100 / compoundsPerYear
        let monthlyRate = pow(1 + periodicRate, compoundsPerYear / 12) - 1
        var balance = principal

        for _ in 0..<months {
            balance += monthlyContribution
            balance *= 1 + monthlyRate
        }

        let contributed = principal + monthlyContribution * Double(months)
        return CompoundInterestResult(
            finalBalance: balance,
            totalContributed: contributed,
            interestEarned: max(balance - contributed, 0)
        )
    }

    private var projectionPoints: [CompoundProjectionPoint] {
        let totalYears = Int(years)
        let periodicRate = annualRate / 100 / compoundsPerYear
        let monthlyRate = pow(1 + periodicRate, compoundsPerYear / 12) - 1
        var balance = principal
        var points: [CompoundProjectionPoint] = [
            CompoundProjectionPoint(year: 0, balance: principal, contributed: principal)
        ]

        guard totalYears > 0 else { return points }

        for month in 1...(totalYears * 12) {
            balance += monthlyContribution
            balance *= 1 + monthlyRate

            if month % 12 == 0 {
                let year = month / 12
                points.append(
                    CompoundProjectionPoint(
                        year: year,
                        balance: balance,
                        contributed: principal + monthlyContribution * Double(month)
                    )
                )
            }
        }

        return points
    }

    private var growthSegments: [CompoundGrowthSegment] {
        projectionPoints
            .filter { $0.year > 0 }
            .flatMap { point in
                [
                    CompoundGrowthSegment(year: point.year, category: "Contributed", amount: point.contributed),
                    CompoundGrowthSegment(year: point.year, category: "Interest", amount: max(point.balance - point.contributed, 0))
                ]
            }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Inputs") {
                    currencyField("Starting amount", value: $principal)
                    currencyField("Monthly contribution", value: $monthlyContribution)
                    percentField("Annual return", value: $annualRate)

                    VStack(alignment: .leading) {
                        HStack {
                            Text("Years")
                            Spacer()
                            Text("\(Int(years))")
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $years, in: 1...50, step: 1)
                    }

                    Picker("Compounds", selection: $compoundsPerYear) {
                        Text("Monthly").tag(12.0)
                        Text("Quarterly").tag(4.0)
                        Text("Annually").tag(1.0)
                    }
                }

                Section("Projection") {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricTile(title: "Future value", value: result.finalBalance.currencyText, systemImage: "banknote")
                        MetricTile(title: "Interest", value: result.interestEarned.currencyText, systemImage: "sparkles")
                        MetricTile(title: "Contributed", value: result.totalContributed.currencyText, systemImage: "tray.and.arrow.down")
                        MetricTile(title: "Time", value: "\(Int(years)) years", systemImage: "calendar")
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }

                Section("Growth") {
                    VStack(alignment: .leading, spacing: 14) {
                        Chart(growthSegments) { segment in
                            BarMark(
                                x: .value("Year", segment.year),
                                y: .value("Amount", segment.amount)
                            )
                            .foregroundStyle(by: .value("Type", segment.category))
                            .cornerRadius(4)
                        }
                        .chartForegroundStyleScale([
                            "Contributed": Color.appBlue,
                            "Interest": Color.appAmber
                        ])
                        .chartLegend(position: .bottom, alignment: .leading)
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let amount = value.as(Double.self) {
                                        Text(amount.currencyText)
                                    }
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let year = value.as(Int.self) {
                                        Text("\(year)y")
                                    }
                                }
                            }
                        }
                        .frame(height: 230)

                        HStack(spacing: 12) {
                            Image(systemName: "chart.bar.xaxis")
                                .foregroundStyle(Color.appTeal)
                            Text("Each bar stacks your contributed money with the interest earned by that year.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
            }
            .navigationTitle("Compound Interest")
        }
    }

    private func currencyField(_ title: String, value: Binding<Double>) -> some View {
        LabeledContent(title) {
            TextField(title, value: value, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }

    private func percentField(_ title: String, value: Binding<Double>) -> some View {
        LabeledContent("\(title) (%)") {
            TextField(title, value: value, format: .number.precision(.fractionLength(0...2)))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct CompoundInterestResult {
    let finalBalance: Double
    let totalContributed: Double
    let interestEarned: Double
}

private struct CompoundProjectionPoint: Identifiable {
    let year: Int
    let balance: Double
    let contributed: Double

    var id: Int {
        year
    }
}

private struct CompoundGrowthSegment: Identifiable {
    let year: Int
    let category: String
    let amount: Double

    var id: String {
        "\(year)-\(category)"
    }
}

struct CompoundInterestView_Previews: PreviewProvider {
    static var previews: some View {
        CompoundInterestView()
    }
}
