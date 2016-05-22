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

protocol BarcelonetaDelegate:class {
    func barcelonetaDidStartMoving(view:Barceloneta)
    func barcelonetaDidMovedUp(view:Barceloneta)
    func barcelonetaDidMovedDown(view:Barceloneta)
    func barcelonetaDidRestore(view:Barceloneta)
    func barcelonetaDidChangeValue(view:Barceloneta,value:Double)
    func barcelonetaDidRelease(view:Barceloneta)
    func barcelonetaDidReachNewTimerSetting(view:Barceloneta, setting:(range:Range<Int>,timer:Double,increment:Double))
}

class Barceloneta: UIView {
    //Configuration variables
    var loops = true
    var verticalLimit:CGFloat = 50.0
    var value:Double = 0.0
    var minimumValue:Double = 0.0
    var maximumValue:Double = 50.0
    var timerSettings:[(range:Range<Int>,timer:Double,increment:Double)] = []
    weak var delegate:BarcelonetaDelegate?
    
    //Internal varibles
    private var incrementalValue:Double = 0.0
    private var percentage:Int = 100
    private var timer = NSTimer()
    private var timerHasBeenCalledAtLeastOnce = false
    private var elasticPanGesture:UIPanGestureRecognizer! = nil
    private weak var verticalConstraint:NSLayoutConstraint! = nil
    private var originalConstant : CGFloat = 0.0
    private var movesUp = true
    private var currentTimerSetting:(range:Range<Int>,timer:Double,increment:Double)! = nil
    
    func makeVerticalElastic(verticalConstraint:NSLayoutConstraint, delegate: BarcelonetaDelegate){
        
        //Check that the required settings are OK
        if timerSettings.count == 0{
            print("CANNOT CONTINUE WITHOUT TIMER SETTINGS")
            return
        }
        setDefaultIntervalSetting()
        self.delegate = delegate
        originalConstant = verticalConstraint.constant
        self.verticalConstraint = verticalConstraint
        if elasticPanGesture == nil {
            elasticPanGesture = UIPanGestureRecognizer(target: self, action: #selector(Barceloneta.panned(_:)))
            addGestureRecognizer(elasticPanGesture)
        }
    }
    
    func panned(sender: UIPanGestureRecognizer) {
        
        if(sender.state == .Began){
            delegate?.barcelonetaDidStartMoving(self)
            //The first set of the timer
            addTimer(timerSettings[0].timer)
            timerHasBeenCalledAtLeastOnce = false
        }
        
        let yTranslation = sender.translationInView(self).y
        
        //If ! movesUp, consider that the view moves down
        movesUp = yTranslation < 0
        
        //If the view is dragged beyond the verticalLimit (Up or down)
        //too low
        if yTranslation > verticalLimit {
            verticalConstraint.constant = originalConstant + logConstraintValueForYPosition(yTranslation)
        } //Too high
        else if yTranslation < (verticalLimit * -1.0){
            verticalConstraint.constant = originalConstant + ((logConstraintValueForYPosition(yTranslation * -1)) * -1)
        }
        else {
            verticalConstraint.constant = originalConstant + yTranslation
        }
        
        let prct = Int(100.0 / (verticalLimit/verticalConstraint.constant))
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
        
        if(sender.state == UIGestureRecognizerState.Ended ){
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
    private func setDefaultIntervalSetting(){
        incrementalValue = timerSettings[0].increment
    }
    
    private func addTimer(interval:Double){
        
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(Barceloneta.timerCalled), userInfo: nil, repeats: true);
    }
    
    func timerCalled() {
        timerHasBeenCalledAtLeastOnce = true
        if movesUp {
            increment()
        }else{
            decrement()
        }
    }
    
    private func logConstraintValueForYPosition(yPosition : CGFloat) -> CGFloat {
        return verticalLimit * (1 + log10(yPosition/verticalLimit))
    }
    
    private func increment(){
        checkAndApply(value + incrementalValue)
    }
    
    private func decrement(){
        checkAndApply(value - incrementalValue)
    }
    
    func checkAndApply(newValue:Double){
    
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
    
    private func animateViewBackToOrigin() {
        verticalConstraint.constant = originalConstant
        
        self.delegate?.barcelonetaDidRelease(self)
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 25, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.superview!.layoutIfNeeded()
        }) { _ in
            
        }
    }
}