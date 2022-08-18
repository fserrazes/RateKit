//
//  RateKit.swift
//
//  Created by Flavio Serrazes on 01.05.19.
//  Copyright © 2019 Serrazes. All rights reserved.
//

import StoreKit
import SystemConfiguration

public class RateKit {
    private var userDefaults = UserDefaults()
    private let kAppCurrentVersion  = "Version"
    private let kAppLaunches        = "Launches"
    
    private var launchesBeforeRating: Int
    
    // MARK: Lifecycle
    
    public init(launchesBeforeRating: Int = 5) {
        self.launchesBeforeRating = launchesBeforeRating
        checkAppCurrentVersion()
    }
    
    // MARK: Private methods
    
    private func getAppLaunchCount() -> Int {
        return userDefaults.integer(forKey: kAppLaunches)
    }
    
    private func incrementAppLaunches() {
        var launches = userDefaults.integer(forKey: kAppLaunches)
        launches += 1
        set(value: launches, forKey: kAppLaunches)
    }
    
    private func checkAppCurrentVersion() {
        let infoDictionaryKey = kCFBundleVersionKey as String
        
        guard let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let appBuild = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            print("Expected to find a bundle version in the info dictionary")
            return
        }
        
        let appCurrentVersion = "\(appVersion).\(appBuild)"
        if appCurrentVersion != userDefaults.string(forKey: kAppCurrentVersion) {
            set(value: appCurrentVersion, forKey: kAppCurrentVersion)
            reset()
        }
        incrementAppLaunches()
        
        print("version: \(appVersion) build \(appBuild)\n")
    }
    
    fileprivate func reset() {
        set(value: 0, forKey: kAppLaunches)
    }
    
    fileprivate func set(value: Any?, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    // MARK: Rating process
    
    public func displayRatingsIfRequired() {
        let launches = getAppLaunchCount()
        
        if launches >= launchesBeforeRating {
            SKStoreReviewController.requestReview()
        }
    }
    
    public func displayRatingsPage(appId: String) {
        let url = "itms-apps://itunes.apple.com/app/id\(appId)?action=write-review"
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: { (success) in
            if success {
                NotificationCenter.default.post(name: .ratingsPageOpened, object: self)
            }
        })
    }
}

extension Notification.Name {
    public static let ratingsPageOpened = Notification.Name("RatingsPageOpened")
}
