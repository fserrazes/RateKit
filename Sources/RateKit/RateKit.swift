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
    private static let kAppCurrentVersionKey   = "AppCurrentVersion"
    private static let kAppLaunchesKey         = "AppLaunches"
    private static let kLastReviewRequestedKey = "LastReviewRequested"

    /// Requests a review prompt if all conditions are met.
    /// - Parameters:
    ///   - launchesBeforeAskingForReview: The number of launches before requesting a review. Default is 5.
    ///   - minTimeBetweenRequestsInDays: The minimum time in days between review requests. Default is 30 days.
    /// - Returns: The current app version.
    @discardableResult
    public static func displayRatingsIfRequired(launchesBeforeAskingForReview: Int = 5, minTimeBetweenRequestsInDays: Int = 30) -> String? {
        if canRequestReview(minLaunches: launchesBeforeAskingForReview, delayInDays: minTimeBetweenRequestsInDays) {
            SKStoreReviewController.requestReview()
            setLastReviewRequested()
        }
        return userDefaults.string(forKey: kAppCurrentVersionKey)
    }
}

// MARK: - Helper methods

extension RateKit {
    private static func canRequestReview(minLaunches: Int, delayInDays: Int) -> Bool {
        checkAppCurrentVersion()
        let launches = incrementLaunches()
        let lastReviewRequested = checkLastReviewRequested()
        let minTimeInterval = TimeInterval(delayInDays * 24 * 60 * 60)
        
        debugPrint("Number of launches \(launches) since \(lastReviewRequested)")
        return launches >= minLaunches && Date().timeIntervalSince(lastReviewRequested) > minTimeInterval
    }
    
    private static func incrementLaunches() -> Int {
        var launches = userDefaults.integer(forKey: kAppLaunchesKey)
        launches += 1
        set(value: launches, forKey: kAppLaunchesKey)
        return launches
    }

    private static func checkLastReviewRequested() -> Date {
        let time = userDefaults.double(forKey: kLastReviewRequestedKey)
        return Date(timeIntervalSince1970: time)
    }
    
    private static func setLastReviewRequested() {
        set(value: Date().timeIntervalSince1970, forKey: kLastReviewRequestedKey)
    }
    
    private static func checkAppCurrentVersion() {
        let infoDictionaryKey = kCFBundleVersionKey as String

        guard let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
              let appBuild = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            debugPrint("Expected to find a bundle version in the info dictionary")
            return
        }

        let appCurrentVersion = "\(appVersion).\(appBuild)"

        // Save if new version and reset
        if appCurrentVersion != userDefaults.string(forKey: kAppCurrentVersionKey) {
            set(value: appCurrentVersion, forKey: kAppCurrentVersionKey)
            reset()
        }
    }

    private static func reset() {
        set(value: 0, forKey: kAppLaunchesKey)
        set(value: nil, forKey: kLastReviewRequestedKey)
    }

    private static func set(value: Any?, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
}
