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
    
    var currentTimeShift: TimeInterval = 0 {
        didSet {
            guard let document = document else {
                return
            }
            
            var timeshift = currentTimeShift
            if (!positiveAdjustment) {
                timeshift = -1 * timeshift
            }
            
            document.generalTimeShift = timeshift
            print("Adjustment: \(timeshift)")
        }
    }
    private var positiveAdjustment: Bool = true
    
    var document: SubRipText? {
        return view.window?.windowController?.document as? SubRipText
    }

    @IBAction func changeSign(_ sender: NSButton) {
        if positiveAdjustment {
            positiveAdjustment = false
            signButton.title = "-"
        } else {
            positiveAdjustment = true
            signButton.title = "+"
        }
    }
}
