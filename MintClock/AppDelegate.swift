//
//  AppDelegate.swift
//  MintClock
//
//  Created by mg on 2/11/21.
//

import SwiftUI
import Foundation
import Cocoa

struct EtherscanResponse: Codable {
    public var status: String
    public var message: String
    public var result: GasData
}
struct GasData: Codable, Hashable {
    public var LastBlock: String = ""
    public var SafeGasPrice: String = ""
    public var ProposeGasPrice: String = ""
    public var FastGasPrice: String = ""
    
    subscript(key: String) -> String {
        get {
            switch key {
            case "SafeGasPrice": return self.SafeGasPrice
            case "ProposeGasPrice": return self.ProposeGasPrice
            case "FastGasPrice": return self.FastGasPrice
            default: fatalError("Invalid price type")
            }
        }
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    private let popover = NSPopover()
    private var eventMonitor: EventMonitor?
    private var fetchTimer: Timer?
    private var defaultsChanged = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(
            withLength: NSStatusItem.variableLength)
        statusBarItem.button?.title = "loading..."
        
        let statusBarMenu = NSMenu(title: "MintClock Menu")
        statusBarItem.menu = statusBarMenu
        
        statusBarMenu.addItem(
            withTitle: "Configure",
            action: #selector(togglePopover),
            keyEquivalent: "C")
        
        statusBarMenu.addItem(
            withTitle: "Quit",
            action: #selector(AppDelegate.quit),
            keyEquivalent: "q")
        
        statusBarItem.menu = statusBarMenu
        statusBarItem.button?.action = #selector(togglePopover)
        
        popover.contentViewController = ConfigureViewController(nibName: "ConfigureViewController", bundle: nil)
        
        resetTimer()
        
        // Close popover if clicked outside the popover
        eventMonitor = EventMonitor(mask: .leftMouseDown) { [weak self] event in
            if self?.popover.isShown == true { self?.closePopover(event) }
        }
        eventMonitor?.start()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(defaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc func quit() {
        NSApp.terminate(self)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            defaultsChanged = true
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    private func showPopover(_ sender: AnyObject?) {
        if let button = statusBarItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
        eventMonitor?.start()
    }
    
    private func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    @objc func defaultsDidChange(_ sender: AnyObject?) {
        if defaultsChanged {
            defaultsChanged = false
            resetTimer()
        }
    }
    
    private func resetTimer() {
        fetchTimer?.invalidate()
        fetchTimer = Timer.scheduledTimer(
            timeInterval: 20.0,
            target: self,
            selector: #selector(getPrices),
            userInfo: nil, repeats: true
        )
        fetchTimer?.fire()
    }
    
    private func updateUI(price: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusBarItem.button?.title = String(price) + " gwei"
        }
    }
    
    @objc func getPrices() {
        let gasType = DefaultsManager.shared.gasType ?? "ProposeGasPrice"
        let apiKey = DefaultsManager.shared.etherscanAPIKey ?? "YourApiKeyToken"
        guard let url = URL(string: "https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=\(apiKey)") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let webData = data {
                if let decodedResponse = try? JSONDecoder().decode(EtherscanResponse.self, from: webData) {
                    print(decodedResponse)
                    DispatchQueue.main.async {
                        self.updateUI(price: decodedResponse.result[gasType])
                    }
                    return
                }
            }
            
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
}
