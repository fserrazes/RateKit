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
    
    public static func displayRatingsIfRequired(launchesBeforeRating: Int = 5) {
        incrementLaunches()
        let launches = launchCount()
        
        if launches >= launchesBeforeRating {
            SKStoreReviewController.requestReview()
            print("Review has requested in \(launches) lauches")
        }
    }
}

// MARK: - Helper methods

extension RateKit {
    private static func launchCount() -> Int {
        checkAppCurrentVersion()
        return userDefaults.integer(forKey: kAppLaunches)
    }
    
    private static func incrementLaunches() {
        var launches = userDefaults.integer(forKey: kAppLaunches)
        launches += 1
        set(value: launches, forKey: kAppLaunches)
    }
    
    private static func checkAppCurrentVersion() {
        let infoDictionaryKey = kCFBundleVersionKey as String
        
        guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
              let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
              let appBuild = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            print("Expected to find a bundle version in the info dictionary")
            return
        }
        
        let appCurrentVersion = "\(appVersion).\(appBuild)"
        print("\(appName) version: \(appVersion) build \(appBuild)\n")
        
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
