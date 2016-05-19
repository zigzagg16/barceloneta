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
        barcelonetaView.makeVerticalElastic(barcelontaViewVerticalConstraint, delegate: self)
    }

    //MARK: - BarcelonetaDelegate
    
    func barcelonetaDidMovedUp(){}
    func barcelonetaDidMovedDown(){}
    func barcelonetaDidRestore(){}
    func barcelonetaDidChangeValue(view:Barceloneta,value:Double){
        valueLabel.text = "\(value)"
    }
    func barcelonetaDidRelease(view:Barceloneta){
        print("the suer released the barceloneta")
    }
    
    
    //MARK: -
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

