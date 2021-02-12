//
//  EventMonitor.swift
//  MintClock
//
//  Created by mg on 2/11/21.
//

import Cocoa

class EventMonitor {
    private var monitor: AnyObject?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit { stop() }
    
    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(
            matching: mask, handler: handler
        ) as AnyObject?
    }
    
    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
