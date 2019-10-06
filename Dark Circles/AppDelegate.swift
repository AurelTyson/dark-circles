//
//  AppDelegate.swift
//  Dark Circles
//
//  Created by Aurélien Tison on 01/10/2019.
//  Copyright © 2019 Aurel Tyson. All rights reserved.
//

import Cocoa
import IOKit.pwr_mgt

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: Graphic attributes
    
    @IBOutlet public weak var window: NSWindow!
    
    // MARK: Attributes
    
    private var letMacOSSleep = true
    
    private let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    private let contextMenu: NSMenu! = constructMenu()
    
    // MARK: AppDelegate
    
    public func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Menu icon
        if let button = self.statusItem.button {
            button.title = "😴"
            button.action = #selector(self.statusBarButtonClicked(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        // Notification center delegate
        NSUserNotificationCenter.default.delegate = self
        
    }
    
    // MARK: Actions
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        
        // Current event
        let currentEvent = NSApp.currentEvent!
        
        // If right click
        if currentEvent.type == .rightMouseUp {
            
            // Show menu
            self.statusItem.menu = self.contextMenu
            self.statusItem.popUpMenu(contextMenu)
            
            // This is critical, otherwise clicks won't be processed again
            self.statusItem.menu = nil
            
        }
        else {
            
            // Toggle sleep status
            self.letMacOSSleep.toggle()
            
            // Update sleep mode
            self.updateSleepMode(allowToSleep: self.letMacOSSleep)
            
            // Update icon
            self.updateIcon(allowToSleep: self.letMacOSSleep)
            
            // Send notification
            self.sendNotification(allowToSleep: self.letMacOSSleep)
            
        }
        
    }
    
    // MARK: Utils
    
    private class func constructMenu() -> NSMenu {
        
        // Init the menu entries
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
        
    }
    
    private func updateSleepMode(allowToSleep: Bool) {

        let assertionLevel = allowToSleep ? kIOPMAssertionLevelOff : kIOPMAssertionLevelOn
        
        // Update idle timer
        var assertionID: IOPMAssertionID = IOPMAssertionID(0)
        let success = IOPMAssertionCreateWithName(kIOPMAssertPreventUserIdleDisplaySleep as CFString,
                        IOPMAssertionLevel(assertionLevel),
                        "reasonForActivity" as CFString,
                        &assertionID)
        if success == kIOReturnSuccess {
            IOPMAssertionRelease(assertionID)
            
            NSLog(">> Success !")
            
            if self.letMacOSSleep {
                NSLog(">> The mac can now sleep 😴")
            }
            else {
                NSLog(">> The mac will not sleep anymore 😈")
            }
            
        }
        else {
            
            NSLog(">> Error during assertion creation")
            
        }
        
    }
    
    private func updateIcon(allowToSleep: Bool) {
        
        // Menu icon
        guard let button = self.statusItem.button else {
            return
        }
        
        button.title = allowToSleep ? "😴" : "😈"
        
    }
    
    private func sendNotification(allowToSleep: Bool) {
        
        // Notification
        let notification = NSUserNotification()
        notification.title = "Dark Circles"
        notification.subtitle = allowToSleep ? "The mac can now sleep 😴" : "The mac will not sleep anymore 😈"
        notification.deliveryDate = Date(timeIntervalSinceNow: 1)

        // Displaying notification
        NSUserNotificationCenter.default.deliver(notification)
        
    }
    
}

extension AppDelegate: NSUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        
        return true
        
    }
    
}
