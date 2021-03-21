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
    @IBOutlet weak var alertSetSwitch: NSSwitch!
    @IBOutlet weak var alertValueField: NSTextField!
    
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

        self.loadAlertDefaults()
    }

    override func viewWillAppear() {
        self.loadAlertDefaults()
    }

    func loadAlertDefaults() {
        alertValueField.delegate = self
        alertValueField.placeholderString = "100"
        if (DefaultsManager.shared.alertValue != nil) {
            alertValueField.stringValue = DefaultsManager.shared.alertValue!
        }

        if let alertSet = DefaultsManager.shared.alertSet {
            if alertSet == true {
                alertSetSwitch.state = NSControl.StateValue.on
                alertValueField.isEditable = true
                alertValueField.isEnabled = true
            } else {
                alertSetSwitch.state = NSControl.StateValue.off
                alertValueField.isEditable = false
                alertValueField.isEnabled = false
            }
        }
    }
    
    @IBAction func enableAlertPressed(_ sender: Any) {
        if alertSetSwitch.state.rawValue == 1 {
            alertValueField.isEditable = true
            alertValueField.isEnabled = true
        } else {
            alertValueField.isEditable = false
            alertValueField.isEnabled = false
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

        // alert set switch
        DefaultsManager.shared.alertSet = (alertSetSwitch.state.rawValue != 0)

        // price alert field
        if (alertValueField.stringValue.isEmpty) {
            DefaultsManager.shared.alertValue = "100"
        } else {
            DefaultsManager.shared.alertValue = alertValueField.stringValue
        }

        (NSApplication.shared.delegate as? AppDelegate)?.getPrices()
        (NSApplication.shared.delegate as? AppDelegate)?.closePopover(self)
        view.window?.close()
    }
}
