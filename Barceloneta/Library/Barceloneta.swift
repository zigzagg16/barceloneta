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
protocol BarcelonetaDelegate:class {
    ///Called when the user started dragging the view
    func barcelonetaDidStartMoving(_ view:Barceloneta)
    ///Called when the value changed
    func barcelonetaDidChangeValue(_ view:Barceloneta,value:Double)
    ///Called when the user released the view
    func barcelonetaDidRelease(_ view:Barceloneta)
    ///Called when the view reached a new setting (and the setting has been applied)
    func barcelonetaDidReachNewTimerSetting(_ view:Barceloneta, setting:(range:CountableRange<Int>,timer:Double,increment:Double))
}

///Axis on which the view can be dragged
enum axis {
    ///Horizontal
    case x
    ///Vertical
    case y
}

typealias timerSetting = (range:CountableRange<Int>,timer:Double,increment:Double)

///The Barceloneta class
class Barceloneta: UIView {
    //Configuration variables
    ///Values loop or not
    var loops = true
    ///The dragging vertical limit
    var verticalLimit:CGFloat = 50.0
    ///The initial and current value
    var value:Double = 0.0
    ///The minimal value
    var minimumValue:Double = 0.0
    ///The maximal value
    var maximumValue:Double = 50.0
    ///Timer and increment settings
    var timerSettings:[timerSetting] = []
    ///The delegate, to receive events
    weak var delegate:BarcelonetaDelegate?
    ///The axis on which the view can be dragged
    var axis:axis = .y
    
    //Internal varibles
    fileprivate var incrementalValue:Double = 0.0
    fileprivate var percentage:Int = 100
    fileprivate var timer = Timer()
    fileprivate var timerHasBeenCalledAtLeastOnce = false
    fileprivate var elasticPanGesture:UIPanGestureRecognizer! = nil
    fileprivate weak var moveConstraint:NSLayoutConstraint! = nil
    fileprivate var originalConstant : CGFloat = 0.0
    fileprivate var movesUp = true
    fileprivate var currentTimerSetting:timerSetting! = nil
    
    /**
        Initializes the gesture
        - parameters:
          - constraint: The constraint attached to the Barceloneta view
          - axis: The axis : .x or .y
          - delegate: The object receiving events for the view
     */
    func makeElastic(withConstraint constraint:NSLayoutConstraint, onAxis axis:axis, andDelegate delegate: BarcelonetaDelegate){
        
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
    func panned(_ sender: UIPanGestureRecognizer) {
        
        if(sender.state == .began){
            delegate?.barcelonetaDidStartMoving(self)
            //The first set of the timer
            addTimer(timerSettings[0].timer)
            timerHasBeenCalledAtLeastOnce = false
        }
        
        let translation = self.axis == .y ? sender.translation(in: self).y : sender.translation(in: self).x
        
        //If ! movesUp, consider that the view moves down
        movesUp = self.axis == .y ? (translation < 0) : (translation > 0)
        
        //If the view is dragged beyond the verticalLimit (Up or down)
        //too low
        if translation > verticalLimit {
            moveConstraint.constant = originalConstant + logConstraintValueForYPosition(translation)
        } //Too high
        else if translation < (verticalLimit * -1.0){
            moveConstraint.constant = originalConstant + ((logConstraintValueForYPosition(translation * -1)) * -1)
        }
        else {
            moveConstraint.constant = originalConstant + translation
        }
        
        let prct = Int(100.0 / (verticalLimit/moveConstraint.constant))
        percentage = prct < 0 ? prct * -1 : prct

        //Find a timer setting matching the percentage
        let timerSetting = timerSettings.filter({return $0.range ~= percentage})
        
        if timerSetting.count == 1{
                        
            if currentTimerSetting == nil || timerSetting[0] != currentTimerSetting{
                
                delegate?.barcelonetaDidReachNewTimerSetting(self, setting: timerSetting[0])
                
                timer.invalidate()
                
                //First called to avoid waiting after invalidating timers
                timerCalled()
                //Init and launch timer
                addTimer(timerSetting[0].timer)
            }
            
            currentTimerSetting = timerSetting[0]
            
            //If a setting is found, the incremental value is applied
            incrementalValue = currentTimerSetting.increment
        }
        
        if(sender.state == UIGestureRecognizerState.ended ){
            currentTimerSetting = nil
            timer.invalidate()
            setDefaultIntervalSetting()
            //Allow a basic increment with a quick pan of the view
            if !timerHasBeenCalledAtLeastOnce{
                timerCalled()
            }
            animateViewBackToOrigin()
        }
    }
    
    
    ///Set to the original incremental value
    fileprivate func setDefaultIntervalSetting(){
        incrementalValue = timerSettings[0].increment
    }
    
    /**
        Sets the timer with the interval
        - parameters:
          - interval: The double interval for executing the timer
     */
    fileprivate func addTimer(_ interval:Double){
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(Barceloneta.timerCalled), userInfo: nil, repeats: true);
    }
    
    ///Increment/decrement depending if movesUp or not
    func timerCalled() {
        timerHasBeenCalledAtLeastOnce = true
        if movesUp {
            increment()
        }else{
            decrement()
        }
    }
    
    /**
        Calculate the constraint value for the rubber effect
        - parameters:
          - yPosition: the position of the view
        - returns: The updated position for the rubber effect
     */
    fileprivate func logConstraintValueForYPosition(_ yPosition : CGFloat) -> CGFloat {
        return verticalLimit * (1 + log10(yPosition/verticalLimit))
    }
    
    ///Increment the value
    fileprivate func increment(){
        checkAndApply(value + incrementalValue)
    }
    
    ///Decrement the value
    fileprivate func decrement(){
        checkAndApply(value - incrementalValue)
    }
    
    /**
     Checks what to do with the new value, depending if loops or not
        - parameters:
          - newValue: The value to check and apply
     */
    func checkAndApply(_ newValue:Double){
    
        var checkedValue = value
        
        if newValue > maximumValue{
            checkedValue = loops ? minimumValue : maximumValue
        }
        else if newValue < minimumValue {
            checkedValue = loops ? maximumValue : minimumValue
        }
        else {
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
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 25, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
            self.superview!.layoutIfNeeded()
        }) { _ in
            
        }
    }
}
