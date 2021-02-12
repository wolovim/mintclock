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
    
    private let gasTypeStrings = ["SafeGasPrice", "ProposeGasPrice", "FastGasPrice"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gasTypes.removeAllItems()
        gasTypes.addItems(withTitles: gasTypeStrings)
        gasTypes.setTitle(gasTypeStrings[0])
        
        etherscanKeyField.delegate = self
        etherscanKeyField.placeholderString = DefaultsManager.shared.etherscanAPIKey
        
        switch DefaultsManager.shared.gasType {
        case "SafeGasPrice": gasTypes.selectItem(at: 0)
        case "ProposeGasPrice": gasTypes.selectItem(at: 1)
        case "FastGasPrice": gasTypes.selectItem(at: 2)
        default: gasTypes.selectItem(at: 1)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        let gasType: String
        switch gasTypes.indexOfSelectedItem {
        case 0: gasType = "SafeGasPrice"
        case 1: gasType = "ProposeGasPrice"
        case 2: gasType = "FastGasPrice"
        default: gasType = "ProposeGasPrice"
        }
        
        DefaultsManager.shared.gasType = gasType
        DefaultsManager.shared.etherscanAPIKey = etherscanKeyField.stringValue
        
        (NSApplication.shared.delegate as? AppDelegate)?.getPrices()
        
        view.window?.close()
    }
}
