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

struct ContentView: View {
    // top level View: make layout for the environment
    // TODO get proper index
    @StateObject var layout = Metrics(index: 0).layout

    var body: some View {
        let mets = Metrics(index: 0)
        let layout = mets.layout

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
        let layout: MetricsSelector<Layout>

        init(index: Int) {
            layout = .init(metrics: Metrics.Layout(), index: index)
        }

        struct Layout {
            let horizPadding: MetricsStorage = [100.0]
            let vertPadding: MetricsStorage = [60.0, 20.0]
        }
    }

    // We must use a class because we have to be ObservableObject
    // per environment requirements.
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
            metrics[keyPath: keyPath][index]
        }
    }
//}

#Preview {
    ContentView()
}

