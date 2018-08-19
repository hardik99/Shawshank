//
//  AppDelegate.swift
//  Shawshank
//
//  Created by Harry Twan on 2018/8/11.
//  Copyright © 2018 Harry Twan. All rights reserved.
//

import UIKit
import CocoaLumberjack

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Initial CocoaLumberjack
//        DDLog.add(DDTTYLogger.sharedInstance) // TTY = Xcode console
        DDLog.add(DDASLLogger.sharedInstance) // ASL = Apple System Logs
        let fileLogger: DDFileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60 * 60 * 24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}

    func applicationDidEnterBackground(_ application: UIApplication) {}

    func applicationWillEnterForeground(_ application: UIApplication) {}

    func applicationDidBecomeActive(_ application: UIApplication) {}

    func applicationWillTerminate(_ application: UIApplication) {}
}

