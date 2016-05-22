Barceloneta
===============

![](https://raw.githubusercontent.com/arn00s/barceloneta/master/img/barceloneta.gif)


Barceloneta is the right way to increment/decrement values with a simple gesture on iOS

## Features

- [x] Customisation for timer and incremental values
- [x] Looping through values or not 
- [x] Customizable dragging limit
- [x] Minimal/maximal values
- [x] Easily customisable
- [x] [Complete Documentation](http://arn00s.github.io/barceloneta/)

## Requirements

- Autolayout
- iOS 8.0+
- Swift 2
- Xcode 7.0 or higher

## Communication

- If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/Barceloneta). (Tag 'Barceloneta')
- If you'd like to **ask a general question**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/Barceloneta).
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.
- If you **use the control**, contact me to mention your app on this page.


## Installation

### CocoaPods/Carthage

Support for CocoaPods/Carthage is coming soon


### Manually

You can integrate `Barceloneta` into your project manually.

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
barcelonetaView.timerSettings = [
            (range:0..<70,timer:0.3,increment:1.0),
            (range:70..<120,timer:0.2,increment:2.0),
            (range:120..<500,timer:0.1,increment:3.0)
        ]
barcelonetaView.makeVerticalElastic(barcelontaViewVerticalConstraint, delegate: self)
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

#### Vertical limit
This value defines the dragging limit of your `barceloneta` object. If the user draggs the view higher than this limit, a rubber effect will apply. The view will go up/down slower than your finger.

```swift
barcelonetaView.verticalLimit = 50.0
```

#### Timer Settings

The timerSettings property is an array of bjects, defining the timer interval and incremental value for a specific range.
It is required to have at least an object in the timer setting.

Depending on the percentage, the matching settings will be applied.

A deplacement of 100% corresponds to the verticalLimit.

```swift
(range:0..<70,timer:0.3,increment:1.0)
```
This setting says that :

Between `0` and `70%`, the timer interval for incrementation is `0.3 seconds`, and the value incremented is `1.0`.

![](https://raw.githubusercontent.com/arn00s/barceloneta/master/img/barceloneta_explanation.png)

## TODO

- Support horizontal dragging

## Known issues

Check the ([GitHub issues](https://github.com/arn00s/barceloneta/issues))

## FAQ

### Why should I use `Barceloneta`?

You're looking for an innovative way to increment/decrement values


## Special thanks

[RuberBandEffect](https://github.com/Produkt/RubberBandEffect)

## Contact

- [LinkedIn](https://lu.linkedin.com/in/arnaudschloune)
- [twitter](https://twitter.com/arnaud_momo)

### Creator

- [Arnaud Schloune](http://github.com/arn00s)

## License

Barceloneta is released under the MIT license. See LICENSE for details.
