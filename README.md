# RateKit

<p>
    <img src="https://github.com/fserrazes/RateKit/actions/workflows/CI.yml/badge.svg" />
    <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" />
    </a>
    <img src="https://img.shields.io/badge/iOS-12.0+-orange.svg" />
    <img src="https://img.shields.io/badge/macOs-10.15+-orange.svg" />
</p>

RateKit is a straightforward utility designed to encourage users of your iOS or macOS apps to submit reviews after a specific number of app launches.

By default, this utility won't immediately request an app review. Instead, it monitors the app's usage until it reaches a minimum threshold of launches before prompting the user for a review. Additionally, it ensures that new review request will be made only after specified number of days have passed since the last review request.

# Requirements

The latest version of GameKitUI requires:

    - Swift 5+
    - Xcode 13+
    - macOS 10.15+
    - iOS 12+

# Installation

## Swift Package Manager

Using SPM add the following to your dependencies

'RateKit', 'main', 'https://github.com/fserrazes/RateKit.git'

# How to use? 

Default (will prompt after the app launches 5 times, the secound try will be made after 30 days)

```swift
    RateKit.displayRatingsIfRequired()
```

If you want to have a different threshold

```swift
    RateKit.displayRatingsIfRequired(
        launchesBeforeAskingForReview: 3,
        minTimeBetweenRequestsInDays: 90
    )
```

# Recommended placement

Recommended placement is in the AppDelegate.swift file in the didFinishLaunchingWithOptions function. That way it's guaranteed to check once per app launch.

```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //... other startup stuff
        
    RateKit.displayRatingsIfRequired()
}
```
