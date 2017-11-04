barceloneta
===============

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/barceloneta.svg)](https://img.shields.io/cocoapods/v/barceloneta.svg)
[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

The right way to increment/decrement values

![](https://raw.githubusercontent.com/arn00s/barceloneta/master/img/barceloneta.gif)

barceloneta is the right way to increment/decrement values with a simple gesture on iOS

## Features

- Customisation for timer and incremental values
- Easily customisable
- Horizontal/vertical mode
- Looping through values or not
- Customizable dragging limit
- Minimal/maximal values
- [Complete Documentation](http://arn00s.github.io/barceloneta/)

## Requirements

- Autolayout
- iOS 9.0+
- Swift 3.0
- Xcode 8.0 or higher

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/barceloneta). (Tag '#barceloneta')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/barceloneta).
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.
- If you **use the control**, contact me to mention your app on this page.

## Installation

### CocoaPods
Barceloneta is now available on [CocoaPods](http://cocoapods.org). 
Simply add the following to your project Podfile, and you'll be good to go.

```ruby
use_frameworks!

pod 'barceloneta'
```

### Carthage

Coming soon

### Manually

You can integrate `barceloneta` into your project manually.

#### Source File

Simply add the `Library/Barceloneta.swift` source file directly into your project.

---

## Usage

### Enabling the gesture (EASY !)
To enable the gesture, it is required to have :
- A UIView object
- A NSLayoutConstraint applied to the view, for the vertical position of the view
- Timer/Incremental settings
- A delegate (optional)

```swift
//Initialise the gesture
barcelonetaView.loops = true
barcelonetaView.minimumValue = 0.0
barcelonetaView.maximumValue = 50.0
let timerSettings = [
    (range: 0..<70, timer: 0.3, increment: 1.0),
    (range: 70..<120, timer: 0.2, increment: 2.0),
    (range: 120..<500, timer: 0.1, increment: 3.0)
]
barcelonetaView.makeElastic(timerSettings: timerSettings,
                            constraint: myNSLayoutConstraint
                            axis: .vertical,
                            delegate: self)
```

### Configuration

> That's where the fun begins.
> Keep in mind that the goal of this library is only to manage the incrementation of values. The display should be managed by you.

#### Looping of values

Determines if the values will stop on minimumValue/maximumValue. 

If looping is enabled, when the maximum value is reached, it will go back to the mimimum value. 

And vice-versa.

```swift
barcelonetaView.loops = true/false
```

#### Minimum/Maximum values
Determines the limits of the increment

```swift
barcelonetaView.minimumValue = 0.0
barcelonetaView.maximumValue = 50.0
```

#### Dragging limit
This value defines the dragging limit of your `barceloneta` object. If the user drags the view higher than this limit, a rubber effect will apply. The view will go up/down slower than your finger.

```swift
barcelonetaView.draggingLimit = 50.0
```

#### Timer Settings

The timerSettings property is an array of objects, defining the timer interval and incremental value for a specific range.
It is required to have at least an object in the timer setting.

Depending on the percentage, the matching settings will be applied.

A drag of 100% corresponds to the draggingLimit.

```swift
(range:0..<70, timer: 0.3, increment: 1.0)
```
This setting says that :

Between `0` and `70%`, the timer interval for incrementation is `0.3 seconds`, and the value incremented is `1.0`.

![](https://raw.githubusercontent.com/arn00s/barceloneta/master/img/barceloneta_explanation.png)

#### Crash when running the app ?

If you installed `barceloneta` via CocoaPods and use it with Storyboard/xib, you may need to set the module :

![](https://raw.githubusercontent.com/arn00s/barceloneta/master/img/custom-module-storyboard.png)

## TODO

- UI Testing

## Known issues

Check the ([GitHub issues](https://github.com/arn00s/barceloneta/issues))

## FAQ

### Why should I use `Barceloneta`?

You're looking for an innovative way to increment/decrement values


## Special thanks

[RuberBandEffect](https://github.com/Produkt/RubberBandEffect)

## Contact

- [LinkedIn](https://lu.linkedin.com/in/arnaudschloune)
- [twitter](https://twitter.com/mmommommomo)

### Creator

- [Arnaud Schloune](http://github.com/arn00s)

## License

Barceloneta is released under the MIT license. See LICENSE for details.
