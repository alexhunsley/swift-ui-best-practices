//
//  ContentView.swift
//  DualMetrics
//
//  Created by Alex Hunsley on 12/03/2024.
//

import SwiftUI

//
// [ ] get the index from the environment, which in turn comes from notch detection etc.
// [ ] make our own padding variant (modifier) that takes a keypath.
// [ ] make dualMetrics more ergo: remove need to put in isLargeDesign or not (single value)? annoying!
//         ideally not have to specify it.

// if we share layout via env, fofr our own stuff, DON'T share to other folk's components!

// Don't split out stringIds to diff file. It just slows us down if we have to rename or move things.

// So maye the GeometryProxy can have the layout passed in to the

// should name indicate it's a view for full screen? hmm think not? But could be useful.
// full screen views often have magic in them like nav, edge insets stuff etc, so I don't
// think it's a bad thing.
// Call this xScreenView?
struct UserInfoView: View {
    // top level View: make layout for the environment
    // TODO get proper index
    // Probably don't need state object here at all, actually! We don't care about that.
    //@StateObject
//    var layout = Metrics(index: UIDevice.current.isNotchedDevice ? 0 : 1).layout

    // do need stateObject, to be able to mutate!
    @StateObject var layout: MetricsSelector = Metrics.layout(forIndex: UIDevice.isNotchedDevice ? 0 : 1)

    // VERY IMPORTANT this var qualifies what model. Do NOT use 'viewModel'. Less confusion
    // this way, and We have to do this anyway as multiple models may in theory be in the enviroment.
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel

    var body: some View {
//        let mets = Metrics(index: 0)
//        let layout = mets.layout

        // so we need to defer getting the actual layout for index until in the loopy bit.
        // TODO use geometry proxy here, and call metrics.layout(forIndex: 0/1) here based on notched?
//        let layout = Metrics.layout(forIndex: 0) // use notch!

        // but how do I now set this on the environment below? Can only get hands on it in the body/geometryproxy.
        // OK, need to pass around the metrics pre-Layout call... <<<---------------------------

        // come back to fiddling with metrics later, you need to get most up to date code from waterfront app!
        VStack { //}(spacing: layout(\.mainStackSpacing)) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding(20)

            VStack(spacing: 20) {
                HStack {
                    Text("Name: \(userInfoViewModel.name)")
                }
                HStack {
                    Text("Age: \(userInfoViewModel.age)")
                }
            }
            .padding(layout(\.userInfoBoxPadding))
            .border(.gray)

            SubComponentView()
        }
        .onAppear {
//            let vertPadding = layout(\.vertPadding)
//            print("vertPadding: \(vertPadding)")
        }
        .environmentObject(layout)
    }

    // temp -- just for now
//    var isNotchedDev: Bool {
//        true
//    }
}

extension UserInfoView {
    // MainModel for this SwiftUI view. Or of course, the modelProvider protocol,
    // which avoieds writing @Published on everything,
    // but which would update on aboslutely everything
    // (defo an issue with what we do now!) -- this is
    // another reasonn to not use main app models directly -
    // you possibly over-render your view -- anyhting changing
    // in the model struct changes its value, hence a rerender.
    //
    // The correct strategy is for the main app to notice changes
    // to its main model object as a whole, then update
    // the SwiftUI model with the values. This way we don't
    // re-render if the SwiftUI model itself doesn't change any values.
    class UserInfoViewModel: ObservableObject {
        @Published var name: String
        @Published var age: Int

        init(name: String, age: Int) {
            self.name = name
            self.age = age
        }
    }
}

// example sub-component.
// so we can test environemnt for picking up the metrics
struct SubComponentView: View {

    @EnvironmentObject var layout: MetricsSelector<Metrics.Layout>

    var body: some View {
        Text("Sub-component")
            .padding(.horizontal, layout(\.subCompHorizPadding))
            .background(.yellow)
    }
}

// Metrics magic
//extension ContentView {
    // I've simplified to remove the metric type from the generics,
    // as I thik CGFloat is fine. We're not likely to have e.g. different
    // Colors for screen classes.
    // But I suppose CGSize could be v useful (but we'd get by without, for now).
    typealias MetricType = CGFloat
    // The metric array is ordered as [default size, small size].
    // This is so that the items at index 0 and 1 are always the same
    // thing, even when we only have an array of 1 metric.
    typealias MetricsStorage = [MetricType]

    struct Metrics {
//        let layout: MetricsSelector<Layout>

//        init(index: Int) {
//            layout = .init(metrics: Metrics.Layout(), index: index)
//        }

        static func layout(forIndex index: Int) -> MetricsSelector<Layout> {
            MetricsSelector(metrics: Metrics.Layout(), index: index)
        }

        struct Layout {
            let vertPadding: MetricsStorage = [60.0, 20.0]
            let userInfoBoxPadding: MetricsStorage = [60.0, 20.0]
            // a single value used for both scren sizes
            let mainStackSpacing = 40.0
            let subCompHorizPadding: MetricsStorage = [100.0, 50.0]
        }
    }

    // We must use a class because we have to be ObservableObject
    // per requirements for using Environment.
    // This class is not inteneded to update layout dyamically, though,
    // so we don't need any published properties
    // M = metric type
    class MetricsSelector<M>: ObservableObject {
        let metrics: M
        let index: Int

        init(metrics: M, index: Int) {
            self.metrics = metrics
            self.index = index
        }

        func callAsFunction(_ keyPath: KeyPath<M, MetricsStorage>) -> MetricType {
            let metricsForKeypath = metrics[keyPath: keyPath] //[index]
            let selectedIndex = index < metricsForKeypath.count ? index : 0
            return metricsForKeypath[selectedIndex]
        }
    }
//}

extension UIDevice {
    /// Returns `true` if the device has a notch
    static var isNotchedDevice: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
//        return true
        if UIDevice.current.orientation.isPortrait {
            print("A: \(window.safeAreaInsets.top)")
            return window.safeAreaInsets.top >= 44
        } else {
            print("B: \(window.safeAreaInsets.left) \(window.safeAreaInsets.right)")
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }
}

#Preview {
    // NB if using a main app complicated model from JSON for now,
    // we can hydrate from a sample JSON for mock server. TODO example!
    @ObservedObject var userInfoViewModel = UserInfoView.UserInfoViewModel(name: "Bob", age: 30)
    // Note how the viewModel is passed in via env, not via init.
    // This allows composition of views.
    return UserInfoView()
        .environmentObject(userInfoViewModel)
}
