//
//  DualMetricsApp.swift
//  DualMetrics
//
//  Created by Alex Hunsley on 12/03/2024.
//

import SwiftUI

// AHHH! this 'problem' is just swift acting as expected!
// published always notifies on assignment, even if same actual value!
//
// https://stackoverflow.com/questions/65905731/does-combine-have-publishers-that-only-publish-when-a-value-actually-changes
// does the SW app actually deal with this, when providing stuff to the views?
// check out how they handle this thing around changing vlaues to same value again -- do they guard against that?
// Obviously the proider is a good plae to handle this issue, with setter on the thing, or an updateX func
// that checks for new value.

@main
struct DualMetricsApp: App {

    @StateObject var appEngine = DualMetricsAppEngine(appModel: .empty)

    var body: some Scene {

        WindowGroup {
            Group {
                UserInfoView()
                    .environmentObject(appEngine.userInfoViewModelProvider)
                    .environmentObject(appEngine.radioactivityViewModelProvider)
            }
            .task() {
                print("LOG onAppear entered")

                try? await Task.sleep(nanoseconds: 1_000_000_000)

                print("LOG after the sleep")
                let aModelUpdate = AppModelThatSwiftUIWantsDataFrom(name: "Sue", age: 29, isRadioactive: true, address: "A street", orderCount: 5)
                appEngine.modelUpdated(aModelUpdate)

                try? await Task.sleep(nanoseconds: 1_000_000_000)

                // now change some data we don't care about in our Views.
                // we expect no view update as a result of this.
                //   -- I'm seeing a view update for this! Why?
                let aModelUpdate2 = AppModelThatSwiftUIWantsDataFrom(name: "Sue", age: 29, isRadioactive: true, address: "Another street", orderCount: 1)
                appEngine.modelUpdated(aModelUpdate2)

                try? await Task.sleep(nanoseconds: 1_000_000_000)

                // now change something we expect to see updated in our Views
                let aModelUpdate3 = AppModelThatSwiftUIWantsDataFrom(name: "Sue2", age: 29, isRadioactive: false, address: "Another street", orderCount: 1)
                appEngine.modelUpdated(aModelUpdate3)


                let _ = print("LOG   ... onAppear exiting")
            }

        }
    }

}

// Model for core app.
// This must *not* be expsosed to SwiftUI because we want to:
//    * avoid over-rendeing SwiftUI views
//    * insulate swiftUI views from json/core app model churn
//    * make SwiftUI previews easily
//    * have option of separating out SwiftUI previews into their own modules/SPMs etc with minimum hassle
class DualMetricsAppEngine: ObservableObject {

    // main app model - keep this away from SwiftUI views
    var appModel: AppModelThatSwiftUIWantsDataFrom

    // The SwiftUI view models used by UserInfoView and any of its children
    @Published var userInfoViewModelProvider: UserInfoView.UserInfoViewModelProvider
    @Published var radioactivityViewModelProvider: RadioactivityView.RadioactivityViewModelProvider

    init(appModel: AppModelThatSwiftUIWantsDataFrom) {
        self.appModel = appModel

        // use builder pattern here? with proxy obj? naaaah....
        self.userInfoViewModelProvider = UserInfoView.UserInfoViewModelProvider(
            UserInfoView.UserInfoViewModel(name: appModel.name, age: appModel.age)
        )

        self.radioactivityViewModelProvider = RadioactivityView.RadioactivityViewModelProvider(
            RadioactivityView.RadioactivityViewModel(isRadioactive: false)
        )
    }

    func modelUpdated(_ appData: AppModelThatSwiftUIWantsDataFrom) {
        print("LOG Enter model updated: \(appData)")
//        userInfoViewModelProvider.userInfoViewModel = UserInfoView.UserInfoViewModel(name: appData.name, age: appData.age)
        // forcing false every time, still get updates.

//        radioactivityViewModelProvider.radioactivityViewModel = RadioactivityView.RadioactivityViewModel(isRadioactive: false) //appData.isRadioactive)

        // even this causes a rerender!
//        radioactivityViewModelProvider.radioactivityViewModel.isRadioactive = false //RadioactivityView.RadioactivityViewModel(isRadioactive: false) //appData.isRadioactive)

        // so this at least works - we don't see any updates
        userInfoViewModelProvider.updateModel(UserInfoView.UserInfoViewModel(name: appData.name, age: appData.age))
        radioactivityViewModelProvider.updateModel(RadioactivityView.RadioactivityViewModel(isRadioactive: appData.isRadioactive))
        print("LOG ... exit model updated")
    }
}

struct AppModelThatSwiftUIWantsDataFrom {
    let name: String
    let age: Int
    let isRadioactive: Bool
    let address: String
    let orderCount: Int

    static let empty = AppModelThatSwiftUIWantsDataFrom(name: "",
                                                        age: 0,
                                                        isRadioactive: false,
                                                        address: "",
                                                        orderCount: 0)
}
