import SwiftUI

// Example sub-component.
struct RadioactivityView: View {

    @EnvironmentObject var radioactivityViewModelProvider: RadioactivityView.RadioactivityViewModelProvider

    @StateObject var radioactivityLayout: MetricsSelector = Metrics.layout(forIndex: UIDevice.isNotchedDevice ? 0 : 1)

    typealias MetricType = CGFloat
    // The metric array is ordered as [default size, small size].
    // This is so that the items at index 0 and 1 are always the same
    // thing, even when we only have an array of 1 metric.
    typealias MetricsStorage = [MetricType]

    // MARK: - Metrics
    
    struct Metrics {
        struct Layout {
            let subCompIndicatorWidth: MetricsStorage = [250.0, 200.0]
        }

        static func layout(forIndex index: Int) -> MetricsSelector<Layout> {
            MetricsSelector(metrics: Metrics.Layout(), index: index)
        }
    }

    // MARK: - Body

    var body: some View {
        let viewModel = radioactivityViewModelProvider.radioactivityViewModel

        Text(viewModel.isRadioactive ? "RADIOACTIVE" : "CLEAR")
            .frame(maxWidth: radioactivityLayout(\.subCompIndicatorWidth))
            .background(radioactivityViewModelProvider.radioactivityViewModel.isRadioactive ? .red : .green)
    }
}

extension RadioactivityView {
    struct RadioactivityViewModel: Equatable {
        var isRadioactive: Bool
    }

    class RadioactivityViewModelProvider: ObservableObject {
        // private(set) to force update via updateModel only
        @Published private(set) var radioactivityViewModel: RadioactivityViewModel

        init(_ radioactivityViewModel: RadioactivityViewModel) {
            self.radioactivityViewModel = radioactivityViewModel
        }

        // @Published sends onChange events on assignment -- it doesn't care if it's
        // the same value. So this dedupes.
        func updateModel(_ newModel: RadioactivityViewModel) {
            if newModel.isRadioactive != radioactivityViewModel.isRadioactive {
                radioactivityViewModel = newModel
            }
        }
    }
}

#Preview {
    // NB if using a main app complicated model from JSON for now,
    // we can hydrate from a sample JSON for mock server. TODO example!

    // Note how we have a separate xViewModel for each component in this example.
    // This would be the likely design if different engineers/teams were doing the two part.
    return VStack(spacing: 20) {

        // demonstrate a state of the View
        Group {
            @ObservedObject var radioactivityViewModelProvider = RadioactivityView.RadioactivityViewModelProvider(
                RadioactivityView.RadioactivityViewModel(isRadioactive: false)
            )

            // Note how the viewModel is passed in via env, not via init.
            // This allows more easy composition of views further down with simpler interfaces.
            RadioactivityView()
                .environmentObject(radioactivityViewModelProvider)
        }
        Divider()

        // demonstrate a different state of the View

        Group {
            @ObservedObject var radioactivityViewModelProvider = RadioactivityView.RadioactivityViewModelProvider(
                RadioactivityView.RadioactivityViewModel(isRadioactive: true)
            )

            RadioactivityView()
                .environmentObject(radioactivityViewModelProvider)
        }
    }
}
