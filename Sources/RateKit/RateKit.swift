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
    
    private var application: UIApplication!
    private var appId: String?
    private var launchesBeforeRating: Int = 5
    
    // MARK: Lifecycle
    
    public static let shared: RateKit = RateKit()
    
    public func setup(application: UIApplication, appId: String, appCurrentVersion: String, launchesBeforeRating: Int) {
        self.appId = appId
        
        self.launchesBeforeRating = launchesBeforeRating
        self.application = application
        
        // Checks if it is a new version
        if appCurrentVersion != userDefaults.string(forKey: kAppCurrentVersion) {
            set(value: appCurrentVersion, forKey: kAppCurrentVersion)
            reset()
        }
        incrementAppLaunches()
    }
    
    // MARK: Private methods
    
    private func getAppLaunchCount() -> Int {
        return userDefaults.integer(forKey: kAppLaunches)
    }
    
    private func incrementAppLaunches() {
        var launches = userDefaults.integer(forKey: kAppLaunches)
        launches = launches + 1
        set(value: launches, forKey: kAppLaunches)
    }
    
    private func getAppCurrentVersion() {
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
    
    public func displayRatingsIfRequired(isWrittenReview: Bool = false) {
        let launches = getAppLaunchCount()
        
        if launches >= launchesBeforeRating {
            SKStoreReviewController.requestReview()
        }
    }
    
    @available(*, deprecated, message: "This will be removed in v1.0; please migrate to a displayRatingIfRequired.")
    public func displayRatingsPrompt(on view: UIViewController, title: String, text: String, cancel: String, submit: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancel, style: .default, handler: { (action) -> Void in
//            self.setAppLaunchSchedule(date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
        }))
        
        alert.addAction(UIAlertAction(title: submit, style: .default, handler: { (action) -> Void in
            self.displayRatingsPage()
        }))
        //self.application.windows[0].rootViewController?.present(alert, animated: true, completion: nil)
        view.present(alert, animated: true)
    }
    
    public func displayRatingsPage() {
        guard let appId = appId else { return }
        let url = "itms-apps://itunes.apple.com/app/id\(appId)?action=write-review"
        UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: { (success) in
            if success {
//                self.setAppLaunchSchedule(date: Calendar.current.date(byAdding: .month, value: 3, to: Date())!)
//                self.incrementAppRatings()
                NotificationCenter.default.post(name: .ratingsPageOpened, object: self)
            }
        })
    }
}

extension Notification.Name {
    public static let ratingsPageOpened = Notification.Name("RatingsPageOpened")
}
