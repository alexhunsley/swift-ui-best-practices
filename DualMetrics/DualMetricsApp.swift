//
// Sample SwiftUI app to demonstrate a possible structure, particularly useful with
// multiple collaborators.
//
// The motive is to code stuff in an optimal way from the start, rather than
// spending time changing the way things integrate (from multiple authors) after the individual work.
//
import SwiftUI

// AHHH! this 'problem' is just swift acting as expected!
// @published always notifies on assignment, even if the same actual value!
//
// https://stackoverflow.com/questions/65905731/does-combine-have-publishers-that-only-publish-when-a-value-actually-changes
// Does the SW app actually deal with this, when providing stuff to the views?
// Check out how they handle this thing around changing vlaues to same value again -- do they guard against that?
// Obviously the proider is a good place to handle this issue, with setter on the thing, or an updateX func
// that checks for new value.

//
// [x] DONE using new simpler way (Bring in Metrics from SW app and compare -- have newer changes to SW app I think...)
// [ ] Look at the SW integration of Chloe's stuff - in particular, get providers for the two viewmodels being used.
// [ ] look at getting Debanjan's stuff integrated now by doing a local-only merge of his work -- I don't expecct
//       his interfaces to change much at this point, just internals.
//
// Thought for iOS chapter: some of what I/we're doing here is kind of what TCA would do nicely for us anyway
// (and probably better) -- like composition of state.
//

@main
struct DualMetricsApp: App {

    @StateObject var appEngine = DualMetricsAppEngine(appModel: .empty)

    var body: some Scene {

        WindowGroup {
            Group {
                UserInfoView()
            }
            .environmentObject(appEngine.userInfoViewModelProvider)
            .environmentObject(appEngine.radioactivityViewModelProvider)
            .task() {
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                let aModelUpdate = AppModelThatSwiftUIWantsDataFrom(name: "Sue", age: 29, isRadioactive: true, address: "A street", orderCount: 5)
                print("LOG  main app updating the model...")
                appEngine.modelUpdated(aModelUpdate)

                try? await Task.sleep(nanoseconds: 1_000_000_000)

                // now change some data we don't care about in our Views.
                // we expect no view update as a result of this.
                //   -- I'm seeing a view update for this! Why?
                let aModelUpdate2 = AppModelThatSwiftUIWantsDataFrom(name: "Sue", age: 29, isRadioactive: true, address: "Another street", orderCount: 1)
                print("LOG  main app updating the model... (irrelevant change)")
                appEngine.modelUpdated(aModelUpdate2)

                try? await Task.sleep(nanoseconds: 1_000_000_000)

                // now change something we expect to see updated in our Views
                let aModelUpdate3 = AppModelThatSwiftUIWantsDataFrom(name: "Sue2", age: 29, isRadioactive: false, address: "Another street", orderCount: 1)
                print("LOG  main app updating the model...")
                appEngine.modelUpdated(aModelUpdate3)
            }

        }
    }

}

// Engine for core app.
//
// This, and its appModel, must *not* be exposed to SwiftUI because we want to:
//
//    * avoid over-rendering SwiftUI views
//    * insulate swiftUI views from JSON/core app model churn
//    * make SwiftUI previews more easily
//    * have option of separating out SwiftUI previews into their own modules/SPMs etc with minimum hassle
class DualMetricsAppEngine: ObservableObject {

    // main app model - keep this away from SwiftUI views!
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
        userInfoViewModelProvider.updateModel(UserInfoView.UserInfoViewModel(name: appData.name, age: appData.age))
        radioactivityViewModelProvider.updateModel(RadioactivityView.RadioactivityViewModel(isRadioactive: appData.isRadioactive))
    }
}

// This represents a model in the main app that we do not want to expose
// our SwiftUI Views to. But we do want to get data from it, so that happend
// indirectly via SwiftUI specific view models.
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
