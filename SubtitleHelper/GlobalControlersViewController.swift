//
//  GlobalControlersViewController.swift
//  SubtitleHelper
//
//  Created by Scott Robertson on 7/11/16.
//  Copyright © 2016 Scott Paul Robertson. All rights reserved.
//

import Cocoa

class GlobalControlersViewController: NSViewController {
    
    @IBOutlet weak var signButton: NSButton!
    @IBOutlet weak var timeshiftField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name.SubRipTextUpdatedTimeshift, object: document)
    }
    
    func update(notification: Notification) {
        guard let document = self.document else {
            return
        }
        ignoreUpdateOnce = true
        willChangeValue(forKey: "currentTimeShift")
        currentTimeShift = abs(document.generalTimeShift)
        didChangeValue(forKey: "currentTimeShift")
        positiveAdjustment = document.generalTimeShift >= 0
    }
    
    var ignoreUpdateOnce = false
    var currentTimeShift: TimeInterval = 0 {
        didSet {
            if !ignoreUpdateOnce {
                adjustTimeshift()
            }
            ignoreUpdateOnce = false
        }
    }
    
    private var positiveAdjustment: Bool = true {
        didSet {
            if positiveAdjustment {
                signButton.title = "+"
            } else {
                signButton.title = "-"
            }
        }
    }
    
    func adjustTimeshift() {
        guard let document = document else {
            return
        }
        
        var timeshift = currentTimeShift
        if (!positiveAdjustment) {
            timeshift = -1 * timeshift
        }
        
        document.update(newTimeshift: timeshift)
    }
    
    var document: SubRipText? {
        return view.window?.windowController?.document as? SubRipText
    }

    @IBAction func changeSign(_ sender: NSButton) {
        positiveAdjustment = !positiveAdjustment
        
        adjustTimeshift()
    }
}
