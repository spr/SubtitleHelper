//
//  SubtitleEntryItem.swift
//  SubtitleHelper
//
//  Created by Scott Robertson on 5/30/16.
//  Copyright © 2016 Scott Paul Robertson. All rights reserved.
//

import Cocoa

class SubtitleEntryItem: NSCollectionViewItem, NSTextFieldDelegate {

    @IBOutlet weak var startTime: NSTextField!
    @IBOutlet weak var endTime: NSTextField!
    @IBOutlet weak var content: NSTextField!
    @IBOutlet weak var include: NSButton!
    @IBOutlet weak var indexLabel: NSTextField!
    
    var referenceIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        startTime.objectValue = nil
        endTime.objectValue = nil
        content.stringValue = ""
        indexLabel.stringValue = "#"
        include.state = NSControlState.on.rawValue
    }

    func setupWithSubtitle(_ subtitle: Subtitle) {
        startTime.objectValue = NSNumber(value: subtitle.start)
        endTime.objectValue = NSNumber(value: subtitle.end)
        content.stringValue = subtitle.content
        indexLabel.stringValue = "\(subtitle.entry)"
        include.state = subtitle.include ? NSControlState.on.rawValue : NSControlState.off.rawValue
    }
    
    @IBAction func toggleInclude(_ sender: NSButton) {
        nextResponder?.try(toPerform: #selector(toggleInclude), with: NSNumber(value: referenceIndex))
    }


    override func controlTextDidEndEditing(_ obj: Notification) {
        guard let editor = obj.userInfo?["NSFieldEditor"] as? NSTextView,
            let field = obj.object as? NSTextField,
            let string = editor.textStorage?.string else {
            return
        }
        
        switch field {
        case startTime:
            nextResponder?.try(toPerform: Selector(("updateStartTime:")), with: ["entry": NSNumber(value: referenceIndex), "value": string])
        case endTime:
            nextResponder?.try(toPerform: Selector(("updateEndTime:")), with: ["entry": NSNumber(value: referenceIndex), "value": string])
        case content:
            nextResponder?.try(toPerform: Selector(("updateContent:")), with: ["entry": NSNumber(value: referenceIndex), "value": string])
        default: break
            
        }
    }
}
