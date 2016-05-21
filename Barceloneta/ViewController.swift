//
//  ViewController.swift
//  Barceloneta
//
//  Created by Arnaud Schloune on 17/05/16.
//  Copyright © 2016 Arnaud Schloune. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BarcelonetaDelegate {

    @IBOutlet weak var barcelonetaView: Barceloneta!
    @IBOutlet weak var barcelontaViewVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        barcelonetaView.layer.cornerRadius = 3.0
        barcelonetaView.timerSettings = [
            (range:0..<70,timer:0.3,increment:1.0),
            (range:70..<120,timer:0.2,increment:2.0),
            (range:120..<500,timer:0.1,increment:3.0)
        ]
        barcelonetaView.makeVerticalElastic(barcelontaViewVerticalConstraint, delegate: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        //Set the default background color
        animateBarcelonetaBackgroundColor(getColorForMinimalRange(0))
        barcelonetaDidChangeValue(barcelonetaView, value: 0)
    }

    //MARK: - BarcelonetaDelegate
    
    func barcelonetaDidMovedUp(view: Barceloneta) {
        
    }
    func barcelonetaDidMovedDown(view: Barceloneta) {
        
    }
    func barcelonetaDidRestore(view: Barceloneta) {
        
    }
    func barcelonetaDidStartMoving(view: Barceloneta) {
        
    }
    
    func barcelonetaDidChangeValue(view:Barceloneta,value:Double){
        valueLabel.text = "\(Int(value))"
    }
    
    func barcelonetaDidRelease(view:Barceloneta){
        //the user released la barceloneta
        //Resset to default color
        animateBarcelonetaBackgroundColor(getColorForMinimalRange(0))
    }
    
    
    func barcelonetaDidReachNewTimerSetting(view:Barceloneta, setting:(range:Range<Int>,timer:Double,increment:Double)){
        let color = getColorForMinimalRange(setting.range.startIndex)
        animateBarcelonetaBackgroundColor(color)
    }
    
    private func getColorForMinimalRange(range:Int) -> UIColor{
        
        //Green
        var color = UIColor(red:0.22, green:0.80, blue:0.46, alpha:1.00)
        
        switch range {
        case 70:
            //Orange
            color = UIColor(red:1.00, green:0.66, blue:0.16, alpha:1.00)
        case 120:
            //Red
            color = UIColor(red:0.90, green:0.31, blue:0.26, alpha:1.00)
        default: break
        }
        
        return color
    }
    
    private func animateBarcelonetaBackgroundColor(color:UIColor){
        UIView.animateWithDuration(0.3, animations: { 
        
            self.barcelonetaView.backgroundColor = color
            
            }) { (finished) in
                
        }
        
    }
    
    //MARK: -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

