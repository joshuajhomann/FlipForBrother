//
//  AppDelegate.swift
//  KeyframeAnimator
//
//  Created by Flip for Brother on 3/24/18.
//  Copyright © 2018 Flip for Brother. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        copyfileToDocs()
        print("\nDocuments: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)\n")
        return true
    }

    func copyfileToDocs() {
        let defaults = ["Test print 2 frame", "The Penguin and the Whale", "Penguonaut"]
        let sourcePaths = defaults.flatMap { Bundle.main.url(forResource: $0, withExtension: ".animation") }
        sourcePaths.forEach { path in
            let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let fileManager = FileManager.default
            let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent(path.lastPathComponent)
            try? fileManager.copyItem(atPath: path.path, toPath: fullDestPath.path)
        }
    }

}

