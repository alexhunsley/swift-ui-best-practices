//
//  RadioactivityView.swift
//  DualMetrics
//
//  Created by Alex Hunsley on 16/03/2024.
//

import SwiftUI

// Example sub-component.
// So we can test environemnt for picking up the metrics
struct RadioactivityView: View {

    // don't bother with this for now.
//    @EnvironmentObject var userInfoLayout: MetricsSelector
    
    // this is available, but we don't need to use it in this View

    //    @EnvironmentObject var userInfoViewModel: UserInfoView.UserInfoViewModel
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
        Text(radioactivityViewModelProvider.radioactivityViewModel.isRadioactive ? "RADIOACTIVE" : "CLEAR")
            .frame(maxWidth: radioactivityLayout(\.subCompIndicatorWidth))
        // TODO get the model from the provider!
            .background(radioactivityViewModelProvider.radioactivityViewModel.isRadioactive ? .red : .green)
    }
}

extension RadioactivityView {
    class RadioactivityViewModelProvider: ObservableObject {
        @Published var radioactivityViewModel: RadioactivityViewModel

        init(_ radioactivityViewModel: RadioactivityViewModel) {
            self.radioactivityViewModel = radioactivityViewModel
        }
    }

    // explicit Equatable here doesn't help
    struct RadioactivityViewModel: Equatable {
        var isRadioactive: Bool

        init(isRadioactive: Bool) {
            self.isRadioactive = isRadioactive
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
//
//            Text("Hi")

            // Note how the viewModel is passed in via env, not via init.
            // This allows composition of views.
            RadioactivityView()
                .environmentObject(radioactivityViewModelProvider)
        }
        Divider()

        // demonstrate a different state of the View

        Group {
            @ObservedObject var radioactivityViewModelProvider = RadioactivityView.RadioactivityViewModelProvider(
                RadioactivityView.RadioactivityViewModel(isRadioactive: true)
            )
//
//            Text("Hi")

            // Note how the viewModel is passed in via env, not via init.
            // This allows composition of views.
            RadioactivityView()
                .environmentObject(radioactivityViewModelProvider)
        }
    }
}
