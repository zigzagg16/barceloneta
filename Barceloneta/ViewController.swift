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
        barcelonetaView.incrementalValue = 1.0
        barcelonetaView.incrementalSettings = [(range:0..<50,value:1.0),(range:50..<70,value:2.0),(range:70..<500,value:3.0)]
        barcelonetaView.makeVerticalElastic(barcelontaViewVerticalConstraint, delegate: self)
    }

    //MARK: - BarcelonetaDelegate
    
    func barcelonetaDidMovedUp(){}
    func barcelonetaDidMovedDown(){}
    func barcelonetaDidRestore(){}
    
    func barcelonetaDidChangeValue(view:Barceloneta,value:Double){
//        print("new value \(value)")
        valueLabel.text = "\(value)"
    }
    
    func barcelonetaDidRelease(view:Barceloneta){
        print("the user released la barceloneta")
    }
    
    func barcelonetaDidReachNewIncrementalSetting(view:Barceloneta, incrementalSetting:(range:Range<Int>,value:Double)){
//        print("reached !!")
        print(incrementalSetting)
    }
    
    //MARK: -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

