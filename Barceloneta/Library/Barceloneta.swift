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
    //Configuration variables
    var loops = true
    var numberOfValues = 10
    var initialValue = 0
    var verticalLimit:CGFloat = 50.0
    var value:Double = 0.0
    
    //Internal varibles
    private var elasticPanGesture:UIPanGestureRecognizer! = nil
    private var verticalConstraint:NSLayoutConstraint! = nil
    private var originalConstant : CGFloat = 0.0
    weak var delegate:BarcelonetaDelegate?
    
    func makeVerticalElastic(verticalConstraint:NSLayoutConstraint, delegate: BarcelonetaDelegate){
        self.delegate = delegate
        originalConstant = verticalConstraint.constant
        self.verticalConstraint = verticalConstraint
        if elasticPanGesture == nil {
            elasticPanGesture = UIPanGestureRecognizer(target: self, action: #selector(Barceloneta.panned(_:)))
            addGestureRecognizer(elasticPanGesture)
        }
    }
    
    func panned(sender: UIPanGestureRecognizer) {
        let yTranslation = sender.translationInView(self).y
        
        //If ! movesUp, consider that the view moves down
        let movesUp = yTranslation < 0
//        print(movesUp)

        //too low
        if yTranslation > verticalLimit {
            verticalConstraint.constant = logConstraintValueForYPosition(yTranslation)
            decrement()
            
        } //Too high
        else if yTranslation < (verticalLimit * -1.0){
            verticalConstraint.constant = ((logConstraintValueForYPosition(yTranslation * -1)) * -1)
            increment()
        }
        else {
            verticalConstraint.constant = yTranslation
        }
        
        if(sender.state == UIGestureRecognizerState.Ended ){
            animateViewBackToOrigin()
        }
        
        let percentage = 100.0 / (verticalLimit/verticalConstraint.constant)
//        print("\(yTranslation) == \(percentage)/100")
        print("\(Int(percentage))/100")
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