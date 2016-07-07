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
    }

    func setupWithSubtitle(subtitle: Subtitle) {
        startTime.objectValue = NSNumber(double: subtitle.start)
        endTime.objectValue = NSNumber(double: subtitle.end)
        content.stringValue = subtitle.content
        indexLabel.stringValue = "\(subtitle.entry)"
    }
    
    @IBAction func toggleInclude(sender: NSButton) {
        print("Toggled: \(sender)")
    }


    override func controlTextDidEndEditing(obj: NSNotification) {
        print("Received: \(obj)")
    }
}
