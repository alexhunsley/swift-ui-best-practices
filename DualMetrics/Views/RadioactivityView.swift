import SwiftUI

//struct IsLargeDesignPreferenceKey: PreferenceKey {
//    static var defaultValue: Bool = false
//
//    static func reduce(value: inout Bool, nextValue: () -> Bool) {
//        value = nextValue()
//    }
//}

// Example sub-component.
struct RadioactivityView: View {
    @EnvironmentObject var radioactivityViewModelProvider: RadioactivityView.RadioactivityViewModelProvider
    
    // MARK: - Metrics
    enum Metrics {
        static let subCompIndicatorWidth = DualMetric(small: 200.0, default: 250.0)
    }

    // MARK: - Body

    var isLargeDesign: Bool //IsLargeDesignPreferenceKey

    var body: some View {
        let viewModel = radioactivityViewModelProvider.radioactivityViewModel

//        var isLargeDesign = UIDevice.current.hasNotch

        // GeometryReader a bit of a mare.
        // Alternatives?
        // good info on GR:
        // https://stackoverflow.com/a/65547384
        //
        //    https://swiftwithmajid.com/2020/11/04/how-to-use-geometryreader-without-breaking-swiftui-layout/
        //
        // PrefernceKeu possible! Can write a bool from the backgeround idea below (commented out)
        // https://medium.com/@manojaher/mastering-swiftui-a-deep-dive-into-preferencekey-82ccb43ab9de
        // just keep with this for now. One for another time.
//        GeometryReader { proxy in
//            let isLargeDesign = proxy.isNotchedDevice
//            let isLargeDesign = true
            VStack {
                // why the as String needed?
//                Text("It is \(isLargeDesign)" as String)

                Text(viewModel.isRadioactive ? "RADIOACTIVE" : "CLEAR")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: Metrics.subCompIndicatorWidth(isLargeDesign))
                    .background(radioactivityViewModelProvider.radioactivityViewModel.isRadioactive ? .red : .green)
            }
//            .background(
//                GeometryReader { geometry in
//        // need to add a PrefernceKey for this. see e.g. https://medium.com/@manojaher/mastering-swiftui-a-deep-dive-into-preferencekey-82ccb43ab9de
//                    isLargeDesign.preference(true)
//                }
//            )
//            .overlay(GeometryReader { geometry in
//                //geometry.isNotchedDevice
//            })

//            .frame(maxWidth: proxy.size.width) //, maxHeight: proxy.size.height)
//       }
    }
}

extension RadioactivityView {

    // the updateModel deduping requires Equatable
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
        // the same value. So this deduplicates values.
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
        // removing Groups doesn't help the layout weirdness
//        Group {
            @ObservedObject var radioactivityViewModelProvider = RadioactivityView.RadioactivityViewModelProvider(
                    RadioactivityView.RadioactivityViewModel(isRadioactive: false)
            )

            // Note how the viewModel is passed in via env, not via init.
            // This allows more easy composition of views further down with simpler interfaces.
        RadioactivityView(isLargeDesign: true)
                .environmentObject(radioactivityViewModelProvider)
//        }
        Divider()

        // demonstrate a different state of the View

//        Group {
            @ObservedObject var radioactivityViewModelProvider2 = RadioactivityView.RadioactivityViewModelProvider(
                    RadioactivityView.RadioactivityViewModel(isRadioactive: true)
            )

        RadioactivityView(isLargeDesign: true)
                .environmentObject(radioactivityViewModelProvider2)
//        }
    }
}
