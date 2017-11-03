//
// Barceloneta.swift
//
// Created by Arnaud Schloune on 17/05/16.
// The MIT License (MIT)
//
// Copyright © 2016 Arnaud Schloune. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

///Protocol for Barceloneta events
public protocol BarcelonetaDelegate: class {
    ///Called when the user started dragging the view
    func barcelonetaDidStartMoving(_ view: Barceloneta)
    ///Called when the value changed
    func barcelonetaDidChangeValue(_ view: Barceloneta, value: Double)
    ///Called when the user released the view
    func barcelonetaDidRelease(_ view: Barceloneta)
    ///Called when the view reached a new setting (and the setting has been applied)
    func barcelonetaDidReachNewTimerSetting(_ view: Barceloneta, setting: TimerSetting)
}

///Axis on which the view can be dragged
public enum Axis {
    ///Horizontal
    case horizontal
    ///Vertical
    case vertical
}

public typealias TimerSetting = (range: CountableRange<Int>, timer: Double, increment: Double)

///The Barceloneta class
open class Barceloneta: UIView {
    //Configuration variables
    ///Values loop or not
    public var loops = true
    ///The dragging limit
    public var draggingLimit: CGFloat = 50.0
    ///The initial and current value
    public var value: Double = 0.0
    ///The minimal value
    public var minimumValue: Double = 0.0
    ///The maximal value
    public var maximumValue: Double = 50.0
    ///Timer and increment settings
    public var timerSettings: [TimerSetting] = []
    ///The delegate, to receive events
    weak var delegate: BarcelonetaDelegate?
    ///The axis on which the view can be dragged
    public var axis: Axis = .vertical
    //Internal varibles
    fileprivate var incrementalValue: Double = 0.0
    fileprivate var percentage: Int = 100
    fileprivate var timer = Timer()
    fileprivate var timerHasBeenCalledAtLeastOnce = false
    fileprivate var elasticPanGesture: UIPanGestureRecognizer! = nil
    fileprivate weak var moveConstraint: NSLayoutConstraint! = nil
    fileprivate var originalConstant: CGFloat = 0.0
    fileprivate var movesUp = true
    fileprivate var currentTimerSetting: TimerSetting! = nil

    ///Initializes the gesture
    /// - Parameter constraint: The constraint attached to the Barceloneta view
    /// - Parameter axis: The axis : .horizontal or .vertical
    /// - Parameter delegate: The object receiving events for the view
    public func makeElastic(withConstraint constraint: NSLayoutConstraint,
                            onAxis axis: Axis,
                            andDelegate delegate: BarcelonetaDelegate) {
        //Check that the required settings are OK
        if timerSettings.count == 0 {
            print("CANNOT CONTINUE WITHOUT TIMER SETTINGS")
            return
        }
        setDefaultIntervalSetting()
        self.axis = axis
        self.delegate = delegate
        self.moveConstraint = constraint
        self.originalConstant = moveConstraint.constant
        if elasticPanGesture == nil {
            elasticPanGesture = UIPanGestureRecognizer(target: self, action: #selector(Barceloneta.panned(_:)))
            addGestureRecognizer(elasticPanGesture)
        }
    }

    ///Called when the view moves (dragged by the user)
    @objc func panned(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began, let beginTimerSeeting = firstTimerSetting {
            delegate?.barcelonetaDidStartMoving(self)
            //The first set of the timer
            addTimer(beginTimerSeeting.timer)
            timerHasBeenCalledAtLeastOnce = false
        }

        let translationValue = self.axis == .vertical ? sender.translation(in: self).y : sender.translation(in: self).x
        //If ! movesUp, consider that the view moves down
        movesUp = self.axis == .vertical ? (translationValue < 0) : (translationValue > 0)
        moveConstraint.constant = movingValue(translation: translationValue,
                                              limit: draggingLimit,
                                              constant: originalConstant)
        percentage = percentage(limit: draggingLimit, constant: moveConstraint.constant)

        //Find a timer setting matching the percentage
        if let timerSetting = timerSettings.filter({return $0.range ~= percentage}).first {
            if currentTimerSetting == nil || timerSetting != currentTimerSetting {
                delegate?.barcelonetaDidReachNewTimerSetting(self, setting: timerSetting)
                timer.invalidate()
                //First called to avoid waiting after invalidating timers
                timerCalled()
                //Init and launch timer
                addTimer(timerSetting.timer)
            }
            currentTimerSetting = timerSetting
            //If a setting is found, the incremental value is applied
            incrementalValue = currentTimerSetting.increment
        }

        if sender.state == UIGestureRecognizerState.ended {
            currentTimerSetting = nil
            timer.invalidate()
            setDefaultIntervalSetting()
            //Allow a basic increment with a quick pan of the view
            if !timerHasBeenCalledAtLeastOnce {
                timerCalled()
            }
            animateViewBackToOrigin()
        }
    }
    ///Computed var returning the optional first TimerSetting in the list.
    var firstTimerSetting: TimerSetting? {
        return timerSettings.first
    }
    ///Set to the original incremental value
    fileprivate func setDefaultIntervalSetting() {
        incrementalValue = timerSettings[0].increment
    }

    ///Sets the timer with the interval
    /// - Parameter interval: The double interval for executing the timer
    fileprivate func addTimer(_ interval: Double) {
        timer = Timer.scheduledTimer(timeInterval: interval,
                                     target: self,
                                     selector: #selector(Barceloneta.timerCalled),
                                     userInfo: nil,
                                     repeats: true)
    }

    ///Increment/decrement depending if movesUp or not
    @objc func timerCalled() {
        timerHasBeenCalledAtLeastOnce = true
        movesUp ? increment() : decrement()
    }

    ///Calculates the percentage value of the move
    /// - Parameter limit: The maximum dragging limit
    /// - Parameter constant: The constraint's actual constant
    /// - Returns: Int: The percentage value
    func percentage(limit: CGFloat, constant: CGFloat) -> Int {
        let prct = Int(100.0 / (limit / constant))
        return prct < 0 ? prct * -1 : prct
    }

    ///Calculates the value to move the view
    /// - Parameter translation: The gesture translation value
    /// - Parameter limit: The maximum dragging limit
    /// - Parameter constant: The constraint's actual constant
    /// - Returns: CGFloat: The new value to apply to the constraint's constant.
    func movingValue(translation: CGFloat, limit: CGFloat, constant: CGFloat) -> CGFloat {
        //If the view is dragged beyond the draggingLimit (Up or down)
        //too low
        if translation > limit {
            return constant + logarithm(limit, translation)
        } else if translation < (limit * -1.0) {
            return constant + (logarithm(limit, translation * -1) * -1)
        } else {
            return constant + translation
        }
    }

    ///Calculate the value for the rubber effect
    ///A user may have several memberships, but on different markets.
    /// - Parameter limit: the dragging limit of the view
    /// - Parameter yPosition: the position of the view
    /// - Returns: CGFloat: The updated position for the rubber effect
    fileprivate func logarithm(_ limit: CGFloat, _ yPosition: CGFloat) -> CGFloat {
        return limit * (1 + log10(yPosition / limit))
    }
    ///Increment the value
    fileprivate func increment() {
        checkAndApply(value + incrementalValue)
    }
    ///Decrement the value
    fileprivate func decrement() {
        checkAndApply(value - incrementalValue)
    }
    ///Checks what to do with the new value, depending if loops or not
    /// - Parameter newValue: The value to check and apply
    func checkAndApply(_ newValue: Double) {
        var checkedValue = value
        if newValue > maximumValue {
            checkedValue = loops ? minimumValue : maximumValue
        } else if newValue < minimumValue {
            checkedValue = loops ? maximumValue : minimumValue
        } else {
            checkedValue = newValue
        }

        if value != checkedValue {
            value = checkedValue
            delegate?.barcelonetaDidChangeValue(self, value: value)
        }
    }

    ///Restore the view to the original position with animation
    fileprivate func animateViewBackToOrigin() {
        moveConstraint.constant = originalConstant
        self.delegate?.barcelonetaDidRelease(self)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 25,
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: { () -> Void in
            self.superview!.layoutIfNeeded()
        })
    }
}
