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
            let mm = Metrics()
            print(mm)

            let k: KeyPath<Metrics, MetricsStorage> = \.horizPadding
            print("Keypath = \(k)")
            print("Value at m.keypath = \(mm[keyPath: k])")

            let k2: KeyPath<Metrics, MetricsStorage> = \.vertPadding
            print("Keypath = \(k2)")
            print("Value at m.keypath = \(mm[keyPath: k2])")

            let m0 = MetricsSelector(metrics: Metrics(), index: 0)
            let lookup0 = m0(\.vertPadding)
            print("Lookup: \(lookup0)")

            let m1 = MetricsSelector(metrics: Metrics(), index: 1)
            let lookup1 = m1(\.vertPadding)
            print("Lookup: \(lookup1)")
        }
    }

    // new stuff
    typealias MetricsStorage = [CGFloat]

    struct Metrics {
        let horizPadding: MetricsStorage = [10.0]
        let vertPadding: MetricsStorage = [20.0, 60.0]
    }

//    struct MetricsSelector<T> {
    struct MetricsSelector {
        let metrics: Metrics
        let index: Int

//        var data: [T]

//        init(from metrics: Metrics, keyPath: KeyPath<Pair<T>, T>) {
//        init(from metrics: Metrics, index: Int) {
//            self.data = metrics.map { $0[index] }
//                //$0[keyPath: keyPath] }
//        }

        // replace with the instance thing
//        func m(_ keyPath: KeyPath<Metrics, MetricsStorage>) -> CGFloat {
//            metrics[keyPath: keyPath][index]
//        }

        func callAsFunction(_ keyPath: KeyPath<Metrics, MetricsStorage>) -> CGFloat {
            metrics[keyPath: keyPath][index]
        }
    }
}

#Preview {
    ContentView()
}



// original stuff

struct Pair<T> {
    var first: T
    var second: T
}

struct PairStorage<T> {
    var pairs: [Pair<T>]
}

struct Echo<T> {
    var data: [T]

    init(from storage: PairStorage<T>, keyPath: KeyPath<Pair<T>, T>) {
        self.data = storage.pairs.map { $0[keyPath: keyPath] }
    }
}
