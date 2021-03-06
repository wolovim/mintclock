//
//  ConfigureViewController.swift
//  MintClock
//
//  Created by mg on 2/11/21.
//

import Cocoa

class ConfigureViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var gasTypes: NSPopUpButton!
    @IBOutlet weak var etherscanKeyField: NSTextField!
    @IBOutlet weak var showGweiSwitch: NSSwitch!
    
    private let gasTypeStrings = ["Safe Price ($)", "Suggested Price ($$)", "Fast Price ($$$)"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // etherscan API key
        etherscanKeyField.delegate = self
        etherscanKeyField.placeholderString = "YourApiKeyToken"
        if (DefaultsManager.shared.etherscanAPIKey != nil) {
            etherscanKeyField.stringValue = DefaultsManager.shared.etherscanAPIKey!
        }
        
        // gas type
        gasTypes.removeAllItems()
        gasTypes.addItems(withTitles: gasTypeStrings)
        switch DefaultsManager.shared.gasType {
        case "SafeGasPrice": gasTypes.selectItem(at: 0)
        case "ProposeGasPrice": gasTypes.selectItem(at: 1)
        case "FastGasPrice": gasTypes.selectItem(at: 2)
        default: gasTypes.selectItem(at: 1)
        }
        
        // show gwei text
        if let showGweiText = DefaultsManager.shared.showGweiText {
            if showGweiText == true {
                showGweiSwitch.state = NSControl.StateValue.on
            } else {
                showGweiSwitch.state = NSControl.StateValue.off
            }
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        // etherscan API key
        if (etherscanKeyField.stringValue.isEmpty) {
            DefaultsManager.shared.etherscanAPIKey = "YourApiKeyToken"
        } else {
            DefaultsManager.shared.etherscanAPIKey = etherscanKeyField.stringValue
        }
        
        // gas type
        let gasType: String
        switch gasTypes.indexOfSelectedItem {
        case 0: gasType = "SafeGasPrice"
        case 1: gasType = "ProposeGasPrice"
        case 2: gasType = "FastGasPrice"
        default: gasType = "ProposeGasPrice"
        }
        DefaultsManager.shared.gasType = gasType
        
        // show gwei text
        DefaultsManager.shared.showGweiText = (showGweiSwitch.state.rawValue != 0)
        
        (NSApplication.shared.delegate as? AppDelegate)?.getPrices()
        (NSApplication.shared.delegate as? AppDelegate)?.closePopover(self)
        view.window?.close()
    }
}
