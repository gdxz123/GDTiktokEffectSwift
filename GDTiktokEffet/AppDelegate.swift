//
//  AppDelegate.swift
//  GDTiktokEffet
//
//  Created by GDzqw on 2019/11/6.
//  Copyright © 2019 gdAOE. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var winodw: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.makeupWindow()
        return true
    }
    
    private func makeupWindow() {
        self.winodw = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = ShaderController()
        self.winodw?.rootViewController = rootVC
        self.winodw?.backgroundColor = .white
        self.winodw?.makeKeyAndVisible()
    }
}

