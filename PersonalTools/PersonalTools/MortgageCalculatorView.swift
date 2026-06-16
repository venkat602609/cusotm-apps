import SwiftUI
import Charts

struct MortgageCalculatorView: View {
    @State private var homePrice = 450000.0
    @State private var downPayment = 90000.0
    @State private var interestRate = 6.75
    @State private var loanYears = 30.0
    @State private var propertyTaxAnnual = 5400.0
    @State private var insuranceAnnual = 1800.0
    @State private var hoaMonthly = 0.0

    private var loanAmount: Double {
        max(homePrice - downPayment, 0)
    }

    private var principalAndInterest: Double {
        let months = loanYears * 12
        let monthlyRate = interestRate / 100 / 12

        guard loanAmount > 0, months > 0 else { return 0 }
        guard monthlyRate > 0 else { return loanAmount / months }

        let factor = pow(1 + monthlyRate, months)
        return loanAmount * monthlyRate * factor / (factor - 1)
    }

    private var monthlyTaxes: Double {
        propertyTaxAnnual / 12
    }

    private var monthlyInsurance: Double {
        insuranceAnnual / 12
    }

    private var totalMonthlyPayment: Double {
        principalAndInterest + monthlyTaxes + monthlyInsurance + hoaMonthly
    }

    private var totalInterest: Double {
        max(principalAndInterest * loanYears * 12 - loanAmount, 0)
    }

    private var amortizationPoints: [MortgageBalancePoint] {
        let months = Int(loanYears * 12)
        let monthlyRate = interestRate / 100 / 12
        var balance = loanAmount
        var points: [MortgageBalancePoint] = [
            MortgageBalancePoint(year: 0, balance: loanAmount, principalPaid: 0, interestPaid: 0)
        ]
        var cumulativePrincipal = 0.0
        var cumulativeInterest = 0.0

        guard months > 0, loanAmount > 0 else { return points }

        for month in 1...months {
            let interest = balance * monthlyRate
            let principal = min(max(principalAndInterest - interest, 0), balance)
            balance = max(balance - principal, 0)
            cumulativePrincipal += principal
            cumulativeInterest += interest

            if month % 12 == 0 || month == months {
                points.append(
                    MortgageBalancePoint(
                        year: Int(ceil(Double(month) / 12)),
                        balance: balance,
                        principalPaid: cumulativePrincipal,
                        interestPaid: cumulativeInterest
                    )
                )
            }
        }

        return points
    }

    private var paymentBreakdown: [PaymentBreakdownSegment] {
        [
            PaymentBreakdownSegment(name: "Principal & Interest", amount: principalAndInterest, color: Color.appTeal),
            PaymentBreakdownSegment(name: "Taxes", amount: monthlyTaxes, color: Color.appBlue),
            PaymentBreakdownSegment(name: "Insurance", amount: monthlyInsurance, color: Color.appMint),
            PaymentBreakdownSegment(name: "HOA", amount: hoaMonthly, color: Color.appAmber)
        ]
        .filter { $0.amount > 0 }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Home") {
                    currencyField("Home price", value: $homePrice)
                    currencyField("Down payment", value: $downPayment)
                    percentField("Interest rate", value: $interestRate)

                    Picker("Loan term", selection: $loanYears) {
                        Text("15 years").tag(15.0)
                        Text("20 years").tag(20.0)
                        Text("30 years").tag(30.0)
                    }
                }

                Section("Monthly extras") {
                    currencyField("Annual property tax", value: $propertyTaxAnnual)
                    currencyField("Annual insurance", value: $insuranceAnnual)
                    currencyField("Monthly HOA", value: $hoaMonthly)
                }

                Section("Payment") {
                    VStack(alignment: .leading, spacing: 14) {
                        Text(totalMonthlyPayment.currencyWithCentsText)
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(Color.appInk)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            MetricTile(title: "Loan", value: loanAmount.currencyText, systemImage: "house.fill")
                            MetricTile(title: "P&I", value: principalAndInterest.currencyWithCentsText, systemImage: "percent")
                            MetricTile(title: "Taxes", value: monthlyTaxes.currencyWithCentsText, systemImage: "building.columns")
                            MetricTile(title: "Interest", value: totalInterest.currencyText, systemImage: "chart.pie")
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }

                Section("Amortization") {
                    VStack(alignment: .leading, spacing: 14) {
                        Chart {
                            ForEach(amortizationPoints) { point in
                                AreaMark(
                                    x: .value("Year", point.year),
                                    y: .value("Remaining Balance", point.balance)
                                )
                                .foregroundStyle(Color.appTeal.opacity(0.16))

                                LineMark(
                                    x: .value("Year", point.year),
                                    y: .value("Remaining Balance", point.balance)
                                )
                                .foregroundStyle(Color.appTeal)
                                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            }
                        }
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
                        .frame(height: 210)

                        Text("Remaining loan balance over the selected term")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }

                Section("Monthly Breakdown") {
                    VStack(alignment: .leading, spacing: 14) {
                        Chart(paymentBreakdown) { segment in
                            BarMark(
                                x: .value("Amount", segment.amount),
                                y: .value("Category", segment.name)
                            )
                            .foregroundStyle(segment.color)
                            .annotation(position: .trailing) {
                                Text(segment.amount.currencyWithCentsText)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .chartXAxis {
                            AxisMarks { value in
                                AxisGridLine()
                                AxisValueLabel {
                                    if let amount = value.as(Double.self) {
                                        Text(amount.currencyText)
                                    }
                                }
                            }
                        }
                        .frame(height: 180)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
            }
            .navigationTitle("Mortgage")
        }
    }

    private func currencyField(_ title: String, value: Binding<Double>) -> some View {
        TextField(title, value: value, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
            .keyboardType(.decimalPad)
    }

    private func percentField(_ title: String, value: Binding<Double>) -> some View {
        TextField(title, value: value, format: .number.precision(.fractionLength(0...2)))
            .keyboardType(.decimalPad)
    }
}

private struct MortgageBalancePoint: Identifiable {
    let year: Int
    let balance: Double
    let principalPaid: Double
    let interestPaid: Double

    var id: Int {
        year
    }
}

private struct PaymentBreakdownSegment: Identifiable {
    let name: String
    let amount: Double
    let color: Color

    var id: String {
        name
    }
}

struct MortgageCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        MortgageCalculatorView()
    }
}
