//
//  ContentView.swift
//  DualMetrics
//
//  Created by Alex Hunsley on 12/03/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .padding(20)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            // original stuff
            //            let storage = PairStorage(pairs: [Pair(first: 1, second: 2), Pair(first: 3, second: 4)])
            //
            //            // Echoing the 'first' property of each pair
            //            let echoFirst = Echo(from: storage, keyPath: \.first)
            //            print(echoFirst.data) // [1, 3]
            //
            //            // Echoing the 'second' property of each pair
            //            let echoSecond = Echo(from: storage, keyPath: \.second)
            //            print(echoSecond.data) // [2, 4]
            //

            // new stuff
//            let mm = Metrics()
//            print(mm)

//            let k: KeyPath<Metrics<CGFloat>, MetricsStorageCGFloat> = \.horizPadding


//            print("Keypath = \(k)")
//            print("Value at m.keypath = \(mm[keyPath: k])")
//
//            let k2: KeyPath<Metrics, MetricsStorage> = \.vertPadding
//            print("Keypath = \(k2)")
//            print("Value at m.keypath = \(mm[keyPath: k2])")
//

            // TODO get the index from the environment, which in turn comes from notch detection etc.
            //
//            let m0 = MetricsSelector<CGFloat>(metrics: Metrics(), index: 0)
//            let m0 = MetricsSelector<Metrics<CGFloat>, CGFloat>(metrics: MetricsOuter.Metrics(), index: 0)
            

//
//            let m1 = MetricsSelector<CGFloat>(metrics: Metrics(), index: 1)
//            let lookup1 = m1(\.vertPadding)
//            print("Lookup: \(lookup1)")

            let mc = MetricsSelector<Metrics.ColorsX, Color>(metrics: Metrics.ColorsX(), index: 0)
            let lookup2 = mc(\.myColor)
            print("Lookup: \(lookup2)")


            // proper test here:
            let mets = Metrics(index: 1)
            let layout = mets.layout
            let color = mets.colors2

            let vertPadding = layout(\.vertPadding)
            print("vertPadding: \(vertPadding)")

            let textColor = color(\.myColor)
            print("textColor: \(textColor)")
        }
    }

    // new stuff
    typealias MetricsStorage<T> = [T]

    struct Metrics {
        // use typealias here? to reduce need to mention CGFloat....?
        // TODO make these in init, which takes the index we want to use.
        let layout: MetricsSelector<Layout, CGFloat> //(metrics: Metrics.Layout(), index: 0)
        let colors2: MetricsSelector<ColorsX, Color> //(metrics: Metrics.ColorsX(), index: 0)

        init(index: Int) {
            layout = .init(metrics: Metrics.Layout(), index: index)
            colors2 = .init(metrics: Metrics.ColorsX(), index: index)
        }

        struct Layout {
            // Without the annoation, this bit compiles, but the references
            // to it can't see the type.
            let horizPadding: MetricsStorage<CGFloat> = [10.0]
            let vertPadding: MetricsStorage<CGFloat> = [20.0, 60.0]
        }

        struct ColorsX {
            let myColor: MetricsStorage<Color> = [Color.yellow, Color.green]
        }
    }

    // M = metric type (struct)
    // T = type stored (CGFloat, Color, etc)
    struct MetricsSelector<M, T> {
        let metrics: M
        let index: Int

        func callAsFunction(_ keyPath: KeyPath<M, MetricsStorage<T>>) -> T {
            metrics[keyPath: keyPath][index]
        }
    }
}

#Preview {
    ContentView()
}

