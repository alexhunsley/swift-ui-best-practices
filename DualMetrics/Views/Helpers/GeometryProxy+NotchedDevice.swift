//
// Copyright © 2022 Scottish Widows Limited. All rights reserved.
//

import SwiftUI

extension GeometryProxy {
    /**
     Returns true if height value of current device screen dimensions great or equal to height of smallest notched device.

     ```
     GeometryReader { proxy in
        if proxy.isNotchedDevice {
            // layout variant for notched device
        } else {
            // layout variant for device without notch
        }
     }
     ```
     > Warning: Please note that it currently works only for iPhone devices + simulators locked for Portrait device orientation and depends on `GeometryProxy` provider position in view hierarchy.
     I believe it's not a greater idea to have this one as tool. Need to be eliminated in future if possible after agreements for moving to the dynamic layout instead.
     */
    public var isNotchedDevice: Bool {
        let smallestNotchedDeviceHeight = CGFloat(812.0)
        let deviceScreenHeight = size.height + safeAreaInsets.top + safeAreaInsets.bottom
        return deviceScreenHeight >= smallestNotchedDeviceHeight
    }
}

// Doesn't seem to work, not in preview/sim at least
//extension UIDevice {
//    /// Returns `true` if the device has a notch
//    var hasNotch: Bool {
//        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
//            return false
//        }
//        if UIDevice.current.orientation.isPortrait {
//            return window.safeAreaInsets.top >= 44
//        } else {
//            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
//        }
//    }
//}
