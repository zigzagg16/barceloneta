//
//  Barceloneta.swift
//
//  Created by Arnaud Schloune on 17/05/16.
//  Copyright © 2016 Arnaud Schloune. All rights reserved.
//

//Some parts are based on : https://github.com/Produkt/RubberBandEffect

import UIKit

protocol BarcelonetaDelegate:class {
    func didMovedUp()
    func didMovedDown()
    func didRestore()
    func didChangeValue(value:Double)
}

class Barceloneta: UIView {
    
    var elasticPanGesture:UIPanGestureRecognizer! = nil
    var verticalConstraint:NSLayoutConstraint! = nil
    let verticalLimit : CGFloat = 50.0
    private var originalConstant : CGFloat = 0.0
    var value:Double = 0.0
    weak var delegate:BarcelonetaDelegate?
    
    func makeVerticalElastic(verticalConstraint:NSLayoutConstraint, delegate: BarcelonetaDelegate){
        originalConstant = verticalConstraint.constant
        self.verticalConstraint = verticalConstraint
        if elasticPanGesture == nil {
            elasticPanGesture = UIPanGestureRecognizer(target: self, action: #selector(Barceloneta.panned(_:)))
            addGestureRecognizer(elasticPanGesture)
        }
    }
    
    func panned(sender: UIPanGestureRecognizer) {
        let yTranslation = sender.translationInView(self).y

        //too low
        if yTranslation > verticalLimit {
            verticalConstraint.constant = logConstraintValueForYPosition(yTranslation)
            if(sender.state == UIGestureRecognizerState.Ended ){
                animateViewBackToOrigin()
                decrement()
            }
        } //Too high
        else if yTranslation < (verticalLimit * -1.0){
            verticalConstraint.constant = ((logConstraintValueForYPosition(yTranslation * -1)) * -1)
            if(sender.state == UIGestureRecognizerState.Ended ){
                animateViewBackToOrigin()
                increment()
            }
        }
        else {
            verticalConstraint.constant = yTranslation
        }
    }
    
    private func logConstraintValueForYPosition(yPosition : CGFloat) -> CGFloat {
        return verticalLimit * (1 + log10(yPosition/verticalLimit))
    }
    
    private func increment(){
        value += 1
        delegate?.didChangeValue(value)
    }
    
    private func decrement(){
        value -= 1
        delegate?.didChangeValue(value)
    }
    
    private func animateViewBackToOrigin() {
        
        verticalConstraint.constant = originalConstant
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 25, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.superview!.layoutIfNeeded()
            }, completion: nil)
    }
}