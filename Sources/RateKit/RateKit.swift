//
//  RateKit.swift
//
//  Created by Flavio Serrazes on 01.05.19.
//  Copyright © 2019 Serrazes. All rights reserved.
//

import StoreKit
import SystemConfiguration

public struct RateKit {
    private static var userDefaults = UserDefaults()
    private static let kAppCurrentVersion      = "Version"
    private static let kAppLaunches            = "Launches"

    /// Request for review after a define number of lauches
    /// - Parameter launchesBeforeRating: Lauches before prompt review message (default value is 5 times)
    /// - Returns: App version + build
    @discardableResult
    public static func displayRatingsIfRequired(launchesBeforeRating: Int = 5) -> String? {
        let launches = incrementLaunches()

        if launches >= launchesBeforeRating {
            SKStoreReviewController.requestReview()
            print("Review has requested in \(launches) lauches")
        }
        return userDefaults.string(forKey: kAppCurrentVersion)
    }
}

// MARK: - Helper methods

extension RateKit {
    private static func incrementLaunches() -> Int {
        checkAppCurrentVersion()
        var launches = userDefaults.integer(forKey: kAppLaunches)
        launches += 1
        set(value: launches, forKey: kAppLaunches)
        return launches
    }

    private static func checkAppCurrentVersion() {
        let infoDictionaryKey = kCFBundleVersionKey as String

        guard let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
              let appBuild = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            print("Expected to find a bundle version in the info dictionary")
            return
        }

        let appCurrentVersion = "\(appVersion).\(appBuild)"

        // Save if new version and reset launches
        if appCurrentVersion != userDefaults.string(forKey: kAppCurrentVersion) {
            set(value: appCurrentVersion, forKey: kAppCurrentVersion)
            reset()
        }
    }

    private static func reset() {
        set(value: 0, forKey: kAppLaunches)
    }

    private static func set(value: Any?, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
}
