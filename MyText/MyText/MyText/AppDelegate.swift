//
//  AppDelegate.swift
//  MyText
//
//  Created by MacBook Pro on 2020/4/2.
//  Copyright © 2020 MacBook Pro. All rights reserved.
//

import Cocoa




@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    
    @IBOutlet weak var StatueBar: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    
    @IBAction func Srceenshot_Touched(_ sender: Any) {
        print("Screenshot")
        MyOCR()
    }
    
    @IBAction func Typed_Quited(_ sender: Any) {
        print("Quit")
        NSApplication.shared.terminate(self)
    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        statusItem.button?.title = "MyText"
        statusItem.menu = StatueBar
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

