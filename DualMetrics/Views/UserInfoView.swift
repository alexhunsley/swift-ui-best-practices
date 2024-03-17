import SwiftUI

//be careful about applying all this to the SW app code!
// if things go awry, you will get blame for messing around too much etc!
// -- maybe do changes post-release? or just for new stuff.

//
// [ ] get the index from the environment, which in turn comes from notch detection etc.
// [ ] make our own padding variant (modifier) that takes a keypath.
// [ ] make dualMetrics more ergo: remove need to put in isLargeDesign or not (single value)? annoying!
//         ideally not have to specify it.

// if we share layout via env, for our own stuff, DON'T share to other folk's components!

// Don't split out stringIds to diff file. It just slows us down if we have to rename or move things.

// So maye the GeometryProxy can have the layout passed in to the

// should name indicate it's a view for full screen? hmm think not? But could be useful.
// full screen views often have magic in them like nav, edge insets stuff etc, so I don't
// think it's a bad thing.
//
// Call this xScreenView? To make it clear it's a top level thing.
struct UserInfoView: View {
    // VERY IMPORTANT that all these view model var names are qualified; do NOT just use 'viewModel'
    // because multiple models may in be in the @EnviromentObjects shared between Views.
    // (A change to any of these will trigger re-render, even if a change is only in a subview of this one.)
    @EnvironmentObject var userInfoViewModelProvider: UserInfoViewModelProvider
    @EnvironmentObject var radioactivityViewModelProvider: RadioactivityView.RadioactivityViewModelProvider

    // IMPORTANT have your view name in this layout var name;
    // It gets passed everywhere so we need to avoid clashes in sub-Views.
//    @StateObject var userInfoLayout: MetricsSelector = Metrics.layout(forIndex: UIDevice.isNotchedDevice ? 0 : 1)
    enum Metrics {
        static let vertPadding = DualMetric(small: 20.0, default: 20.0)
        static let userInfoBoxPadding = DualMetric(small: 20.0, default: 60.0)
        // a single value used for both scren sizes
        static let mainStackSpacing = 40.0
        // now in sub-model
        static let subCompIndicatorWidth = DualMetric(small: 200.0, default: 250.0)
    }

    var body: some View {
        let _ = print("LOG_UserInfoView   Rendering body!")
//        let _ = Self._printChanges()

        let userInfoViewModel = userInfoViewModelProvider.userInfoViewModel

        GeometryReader { proxy in
            let isLargeDesign = proxy.isNotchedDevice

            VStack {
                VStack(spacing: 20) {
                    HStack {
                        Text("Name: \(userInfoViewModel.name)")
                    }
                    HStack {
                        Text("Age: \(userInfoViewModel.age)")
                    }
                }
                .padding(Metrics.userInfoBoxPadding(isLargeDesign))
                .border(.gray)

                RadioactivityView(isLargeDesign: true)
                // We just pass our env modelViews to *everything* (see further down).
                // Can't forget, this way.
                //                .environmentObject(radioactivityViewModel)
            }
            .frame(width: proxy.size.width)
            .onAppear {
                //            print("LOG_UserInfoView  in userView, userInfoViewModel.name = \(userInfoViewModel.name)")
                //            let vertPadding = layout(\.vertPadding)
                //            print("vertPadding: \(vertPadding)")
            }
            // we don't bother making layout a provider thing for layout; it's static per device type
//            .environmentObject(userInfoLayout)
            .environmentObject(radioactivityViewModelProvider)
        }
    }
}

extension UserInfoView {

    // ViewModel and ViewModelProvider are best inside the UserInfoView
    // rather than dangling externally. If you want more convenient access,
    // please use a typealias in your usage context, e.g:
    //
    //   typealias UserInfoViewModel = UserInfoView.UserInfoViewModel
    //   typealias UserInfoViewModelProvider = UserInfoView.UserInfoViewModelProvider
    //
    // the updateModel deduping requires Equatable
    struct UserInfoViewModel: Equatable {
        var name: String
        var age: Int
    }

    // The view model for this SwiftUI view. Or of course, the modelProvider protocol,
    // which avoids writing @Published on everything,
    // but which would update on absolutely everything
    // (defo an issue with what we do now!) -- this is
    // another reason to not use main app models directly -
    // you possibly over-render your view -- anyhting changing
    // in the model struct changes its value, hence a rerender.
    //
    // The correct strategy is for the main app to notice changes
    // to its main model object as a whole, then update
    // the SwiftUI model with the values. This way we don't
    // re-render if the SwiftUI model itself doesn't change any values.
    class UserInfoViewModelProvider: ObservableObject {
        // private(set) to force update via updateModel only
        @Published private(set) var userInfoViewModel: UserInfoViewModel

        init(_ userInfoViewModel: UserInfoViewModel) {
            self.userInfoViewModel = userInfoViewModel
        }

        // @Published sends onChange events on assignment -- it doesn't care if it's
        // the same value. So this deduplicates values.
        func updateModel(_ newModel: UserInfoViewModel) {
            if newModel != userInfoViewModel {
                userInfoViewModel = newModel
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
            @ObservedObject var userInfoViewModelProvider = UserInfoView.UserInfoViewModelProvider(
                UserInfoView.UserInfoViewModel(name: "Bob", age: 30)
            )
            @ObservedObject var radioactivityViewModelProvider = RadioactivityView.RadioactivityViewModelProvider(
                RadioactivityView.RadioactivityViewModel(isRadioactive: true)
            )

            // Note how the viewModel is passed in via env, not via init.
            // This allows composition of views.
            UserInfoView()
                .environmentObject(userInfoViewModelProvider)
                .environmentObject(radioactivityViewModelProvider)
        }
        Divider()
//        
//        // demonstrate a different state of the View
//        Group {
//            @ObservedObject var userInfoViewModel = UserInfoView.UserInfoViewModel(name: "Alice", age: 41)
//            @ObservedObject var radioactivityViewModel = RadioactivityView.RadioactivityViewModel(isRadioactive: false)
//
//            // Note how the viewModel is passed in via env, not via init.
//            // This allows composition of views.
//            UserInfoView()
//                .environmentObject(userInfoViewModel)
//                .environmentObject(radioactivityViewModel)
//        }
//        Divider()
//
//        // demonstrate the layout bounds of the view are appropriate (no excess padding; the
//        // red outline hugs the View content)
//        Group {
//            @ObservedObject var userInfoViewModel = UserInfoView.UserInfoViewModel(name: "NAME", age: 0)
//            @ObservedObject var radioactivityViewModel = RadioactivityView.RadioactivityViewModel(isRadioactive: false)
//
//            // Note how the viewModel is passed in via env, not via init.
//            // This allows composition of views.
//            UserInfoView()
//                .border(.red)
//                .environmentObject(userInfoViewModel)
//                .environmentObject(radioactivityViewModel)
//        }
    }
}
