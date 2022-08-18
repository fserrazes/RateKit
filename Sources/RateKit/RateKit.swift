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
    private let kAppRatingCount     = "RatingShown"
    private let kAppNextRatingDate  = "InstallDate"
    private let kAppMaxRatingCount  = 3
    
    private var application: UIApplication!
    private var appId: String?
    private var appCurrentVersion: String?
    private var launchesBeforeRating: Int = 5
    
    // MARK: Lifecycle
    
    public static let shared: RateKit = RateKit()
    
    public func setup(application: UIApplication, appId: String, appCurrentVersion: String, launchesBeforeRating: Int) {
        self.appId = appId
        self.appCurrentVersion = appCurrentVersion
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
    
    private func getAppRatingCount() -> Int {
        return userDefaults.integer(forKey: kAppRatingCount)
    }
    
    private func incrementAppRatings() {
        var rates = userDefaults.integer(forKey: kAppRatingCount)
        rates = rates + 1
        set(value: rates, forKey: kAppRatingCount)
    }
    
    private func getAppLaunchSchedule() -> Date {
        if let date = userDefaults.value(forKey: kAppNextRatingDate) as? Date {
            return date
        }
        return Date()
    }
    
    private func setAppLaunchSchedule(date: Date) {
        set(value: date, forKey: kAppNextRatingDate)
    }
    
    public static func getAppCurrentVersion() {
        guard let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            return
        }
        print(currentAppVersion)
    }
    
    fileprivate func reset() {
        set(value: 0, forKey: kAppLaunches)
        set(value: 0, forKey: kAppRatingCount)
        setAppLaunchSchedule(date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
    }
    
    fileprivate func set(value: Any?, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    // MARK: Rating process
    
    public func displayRatingsIfRequired(isWrittenReview: Bool = false) {
        let launches = getAppLaunchCount()
        let ratings = getAppRatingCount()
        let schedule = getAppLaunchSchedule()
        
        if ratings <= kAppMaxRatingCount && launches >= launchesBeforeRating && schedule <= Date() {
            SKStoreReviewController.requestReview()
            setAppLaunchSchedule(date: Calendar.current.date(byAdding: .month, value: 3, to: Date())!)
            incrementAppRatings()
        }
    }
    
    @available(*, deprecated, message: "This will be removed in v1.0; please migrate to a displayRatingIfRequired.")
    public func displayRatingsPrompt(on view: UIViewController, title: String, text: String, cancel: String, submit: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancel, style: .default, handler: { (action) -> Void in
            self.setAppLaunchSchedule(date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!)
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
                self.setAppLaunchSchedule(date: Calendar.current.date(byAdding: .month, value: 3, to: Date())!)
                self.incrementAppRatings()
                NotificationCenter.default.post(name: .ratingsPageOpened, object: self)
            }
        })
    }
}

extension Notification.Name {
    public static let ratingsPageOpened = Notification.Name("RatingsPageOpened")
}
