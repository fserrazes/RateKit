# RateKit

[![Swift 5](https://img.shields.io/badge/language-Swift-orange.svg)](https://swift.org)
[![macOS](https://img.shields.io/badge/OS-macOS-green.svg)](https://developer.apple.com/macos/)
[![iOS](https://img.shields.io/badge/OS-iOS-green.svg)](https://developer.apple.com/ios/)

RateKit is a simple utility to prompt the users of your iOS or macOS apps to submit a review after a certain number of runs.

This utility by default will not immediatly call for an app review, instead it keeps track until a minimum threshold of calls is hit before prompting the user for a review. It will also only request one review for each app version that is released.

# How to use

Default (will prompt after the app lauches this 5 times)

```
    RateKit().displayRatingsIfRequired
```

If you want to have a different threshold

```
    let review = RateKit(launchesBeforeRating: 3)
    review.displayRatingsIfRequired()

```
If you want to open a write/review page. 

```
    RateKit().displayRatingsPage()
```

After the write/review page is opened a notification is sent

```
    NotificationCenter.default.addObserver(self, selector: #selector(reviewPageOpened), name: .ratingsPageOpened, object: nil)
    
    @objc func reviewPageOpened(_ notification: Notification) {
        //... code process
    }
```

# Recommended placement

Recommended placement is in the AppDelegate.swift file in the didFinishLaunchingWithOptions function. That way it's guaranteed to check once per app launch.

```
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //... other startup stuff
        
    RateKit().displayRatingsPage()
}
```
