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
///Tuple defining a TimerSetting : Range, timer, and increment value
public typealias TimerSetting = (range: CountableRange<Int>, timer: Double, increment: Double)

///The Barceloneta class
open class Barceloneta: UIView {
    // MARK: Configuration variables
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
    //swiftlint:disable:next weak_delegate
    weak var delegate: BarcelonetaDelegate?
    ///The axis on which the view can be dragged
    public var axis: Axis = .vertical
    // MARK: Internal varibles
    fileprivate var incrementalValue: Double {
        guard let currentSetting = currentTimerSetting else {
            return firstTimerSetting != nil ? firstTimerSetting!.increment : 0.0
        }
        return currentSetting.increment
    }
    fileprivate var percentage: Int = 100
    fileprivate var timer = Timer()
    fileprivate var timerHasBeenCalledAtLeastOnce = false
    fileprivate var elasticPanGesture: UIPanGestureRecognizer! = nil
    fileprivate weak var moveConstraint: NSLayoutConstraint! = nil
    fileprivate var originalConstant: CGFloat = 0.0
    fileprivate var movesUp = true
    fileprivate var currentTimerSetting: TimerSetting! = nil

    // MARK: Methods
    ///Initializes the gesture
    /// - Parameter timerSettings: The timer settings
    /// - Parameter constraint: The constraint attached to the Barceloneta view
    /// - Parameter axis: The axis : .horizontal or .vertical
    /// - Parameter delegate: An optional BarcelonetaDelegate object receiving events
    public func makeElastic(timerSettings: [TimerSetting],
                            constraint: NSLayoutConstraint,
                            axis: Axis,
                            delegate: BarcelonetaDelegate?) {
        self.timerSettings = timerSettings
        self.moveConstraint = constraint
        self.axis = axis
        self.delegate = delegate
        self.originalConstant = moveConstraint.constant
        if elasticPanGesture == nil {
            elasticPanGesture = UIPanGestureRecognizer(target: self, action: #selector(Barceloneta.panned(_:)))
            addGestureRecognizer(elasticPanGesture)
        }
    }

    ///Called when the view moves (Panned by the user)
    @objc func panned(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began, let beginTimerSeeting = firstTimerSetting {
            startedPanning(timerSetting: beginTimerSeeting)
        }

        handlePanning(translation: axis == .vertical ? sender.translation(in: self).y : sender.translation(in: self).x)

        if sender.state == UIGestureRecognizer.State.ended { endedPanning() }
    }

    ///The user started dragging the view
    /// - Parameter timerSettings: The timer settings
    internal func startedPanning(timerSetting: TimerSetting) {
        delegate?.barcelonetaDidStartMoving(self)
        scheduleTimer(timerSetting.timer) //The first set of the timer
        timerHasBeenCalledAtLeastOnce = false
    }
    ///Handle the dragging
    /// - Parameter translation: The dragging translation movement
    internal func handlePanning(translation: CGFloat) {
        //If ! movesUp, consider that the view moves down
        movesUp = axis == .vertical ? (translation < 0) : (translation > 0)
        moveConstraint.constant = movingValue(translation: translation,
                                              limit: draggingLimit,
                                              constant: originalConstant)
        percentage = percentage(limit: draggingLimit, constant: moveConstraint.constant)
        //Find a timer setting matching the percentage
        if let timerSetting = timerSettings.filter({return $0.range ~= percentage}).first {
            if currentTimerSetting == nil || timerSetting != currentTimerSetting {
                delegate?.barcelonetaDidReachNewTimerSetting(self, setting: timerSetting)
                timer.invalidate()
                timerCalled() //Called first to avoid waiting after invalidating timers
                scheduleTimer(timerSetting.timer)
            }
            currentTimerSetting = timerSetting
        }
    }
    ///The dragging ended. If one timer has not been kicked yet, kick it "manually".
    internal func endedPanning() {
        currentTimerSetting = nil
        timer.invalidate()
        if !timerHasBeenCalledAtLeastOnce { //-> Allows a basic increment with a quick pan of the view
            timerCalled()
        }
        animateViewBackToOrigin()
    }
    ///Computed var returning the optional first TimerSetting in the list.
    var firstTimerSetting: TimerSetting? {
        return timerSettings.first
    }

    ///Sets the timer with the interval
    /// - Parameter interval: The double interval for executing the timer
    internal func scheduleTimer(_ interval: Double) {
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
    internal func percentage(limit: CGFloat, constant: CGFloat) -> Int {
        let prct = Int(100.0 / (limit / constant))
        return prct < 0 ? prct * -1 : prct
    }

    ///Calculates the value to move the view
    /// - Parameter translation: The gesture translation value
    /// - Parameter limit: The maximum dragging limit
    /// - Parameter constant: The constraint's actual constant
    /// - Returns: CGFloat: The new value to apply to the constraint's constant.
    internal func movingValue(translation: CGFloat, limit: CGFloat, constant: CGFloat) -> CGFloat {
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
    internal func logarithm(_ limit: CGFloat, _ yPosition: CGFloat) -> CGFloat {
        return limit * (1 + log10(yPosition / limit))
    }
    ///Increment the value
    internal func increment() {
        checkAndApply(value + incrementalValue)
    }
    ///Decrement the value
    internal func decrement() {
        checkAndApply(value - incrementalValue)
    }
    ///Checks what to do with the new value, depending if loops or not
    /// - Parameter newValue: The value to check and apply
    private func checkAndApply(_ newValue: Double) {
        var checkedValue = value
        if newValue > maximumValue {
            checkedValue = loops ? minimumValue : maximumValue
        } else if newValue < minimumValue {
            checkedValue = loops ? maximumValue : minimumValue
        } else {
            checkedValue = newValue
        }

        if value == checkedValue {
            feedback(positive: false)
        } else {
            value = checkedValue
            delegate?.barcelonetaDidChangeValue(self, value: value)
            feedback(positive: true)
        }
    }
    ///Restore the view to the original position with animation
    private func animateViewBackToOrigin() {
        moveConstraint.constant = originalConstant
        self.delegate?.barcelonetaDidRelease(self)
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 25,
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: { () -> Void in
            self.superview!.layoutIfNeeded()
        })
    }
    ///Haptick feedback, if supported. Min iOS 10.0.
    /// - Parameter positive: The value was changed.  If false, an impact feedback is launched
    private func feedback(positive: Bool) {
        if #available(iOS 10.0, *) {
            if positive {
                let selectionFeedback = UISelectionFeedbackGenerator()
                selectionFeedback.selectionChanged()
            } else {
                let feedback = UIImpactFeedbackGenerator(style: .medium)
                feedback.impactOccurred()
            }
        }
    }
}
