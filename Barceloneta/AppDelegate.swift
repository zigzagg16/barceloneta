//
//  AppDelegate.swift
//  Barceloneta
//
//  Created by Arnaud Schloune on 17/05/16.
//  Copyright © 2016 Arnaud Schloune. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, COSTouchVisualizerWindowDelegate {

    var window: UIWindow?
//    var window: UIWindow? = {
//        var customWindow = COSTouchVisualizerWindow(frame: UIScreen.main.bounds)
//        customWindow.touchVisualizerWindowDelegate = self
//        
//        customWindow.fillColor = UIColor(red:0.07, green:0.73, blue:0.86, alpha:1)
//        customWindow.strokeColor = UIColor.clear
//        customWindow.touchAlpha = 0.4
//        
//        customWindow.rippleFillColor = UIColor(red:0.98, green:0.68, blue:0.22, alpha:1)
//        customWindow.rippleStrokeColor = UIColor.clear
//        customWindow.rippleAlpha = 0.4
//        
//        return customWindow
//    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func touchVisualizerWindowShouldAlwaysShowFingertip(_ window: COSTouchVisualizerWindow!) -> Bool {
        return true
    }
}
