import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FastingTrackerView()
                .tabItem {
                    Label("Fasting", systemImage: "timer")
                }

            CompoundInterestView()
                .tabItem {
                    Label("Compound", systemImage: "chart.line.uptrend.xyaxis")
                }

            MortgageCalculatorView()
                .tabItem {
                    Label("Mortgage", systemImage: "house")
                }
        }
        .tint(Color.appTeal)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FastingStore())
    }
}
