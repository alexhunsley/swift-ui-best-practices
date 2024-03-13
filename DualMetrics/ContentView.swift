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
//

// So maye the GeometryProxy can have the layout passed in to the

struct ContentView: View {
    // top level View: make layout for the environment
    // TODO get proper index
    // Probably don't need state object here at all, actually! We don't care about that.
    //@StateObject
//    var layout = Metrics(index: UIDevice.current.isNotchedDevice ? 0 : 1).layout

    // do need stateObject, to be able to mutate!
    @StateObject var layout: MetricsSelector<any Layout>

    var body: some View {
//        let mets = Metrics(index: 0)
//        let layout = mets.layout

        // so we need to defer getting the actual layout for index until in the loopy bit.
        // TODO use geometry proxy here, and call metrics.layout(forIndex: 0/1) here based on notched?
        let layout = Metrics.layout(forIndex: 0) // use notch!

        // but how do I now set this on the environment below? Can only get hands on it in the body/geometryproxy.
        // OK, need to pass around the metrics pre-Layout call... <<<---------------------------

        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding(20)
            Text("Hello, world!")
                .padding(layout(\.vertPadding))

            SubComponentView()
        }
        .onAppear {
            let vertPadding = layout(\.vertPadding)
            print("vertPadding: \(vertPadding)")
        }
        .environmentObject(layout)
    }

    // temp -- just for now
    var isNotchedDev: Bool {
        true
    }
}

// example sub-component.
// so we can test environemnt for picking up the metrics
struct SubComponentView: View {

//    @Environment(Metrics.Layout.self) var layout: MetricsSelector<Layout>
    @EnvironmentObject var layout: MetricsSelector<Metrics.Layout>

    var body: some View {
        Text("Sub-component")
            .padding(.horizontal, layout(\.horizPadding))
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
            let horizPadding: MetricsStorage = [100.0, 50.0]
            let vertPadding: MetricsStorage = [60.0, 20.0]
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
    var isNotchedDevice: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
        if UIDevice.current.orientation.isPortrait {
            return window.safeAreaInsets.top >= 44
        } else {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        }
    }
}

#Preview {
    ContentView()
}
