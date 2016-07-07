//
//  SubRipText.swift
//  SubtitleHelper
//
//  Created by Scott Robertson on 5/30/16.
//  Copyright © 2016 Scott Paul Robertson. All rights reserved.
//

import Cocoa

class SubRipText: NSDocument {

    var subtitles: [Subtitle] = []
    var loadingComplete = false

    override class func autosavesInPlace() -> Bool {
        return false
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateControllerWithIdentifier("SRTWindow") as! NSWindowController
        self.addWindowController(windowController)
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    override func dataOfType(typeName: String) throws -> NSData {
        guard let output = NSMutableData(capacity: subtitles.count * 1000) else {
            throw NSError(domain: NSOSStatusErrorDomain, code: -1, userInfo: nil)
        }

        for subtitle in subtitles where subtitle.include {
            guard let data = subtitle.subRipRepresentation().dataUsingEncoding(NSUTF8StringEncoding) else {
                continue
            }
            output.appendData(data)
        }

        return NSData(data: output)
    }

    override var entireFileLoaded: Bool {
        return loadingComplete
    }

    override func readFromURL(url: NSURL, ofType typeName: String) throws {
        guard let filename = url.path else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSCocoaError.FileReadInvalidFileNameError.rawValue, userInfo: nil)
        }

        guard let scriptPath = NSBundle.mainBundle().pathForResource("convert", ofType: "pl") else {
            throw NSError(domain: "SubtitleHelper", code: -1, userInfo: nil)
        }

        let task = NSTask()
        task.arguments = [scriptPath, filename]
        task.launchPath = "/usr/bin/perl"
        let tmpFile = NSTemporaryDirectory().stringByAppendingString("processzz.json")
        guard NSFileManager.defaultManager().createFileAtPath(tmpFile, contents: nil, attributes: nil) else {
            throw NSError(domain: "SubtitleHelper", code: -1, userInfo: nil)
        }
        defer {
            try! NSFileManager.defaultManager().removeItemAtPath(tmpFile)
        }

        guard let output = NSFileHandle(forWritingAtPath: tmpFile) else {
            throw NSError(domain: "SubtitleHelper", code: -1, userInfo: nil)
        }
        task.standardOutput = output
        task.standardError = NSFileHandle.fileHandleWithNullDevice()

        task.launch()
        task.waitUntilExit()

        output.closeFile()

        guard let data = NSData(contentsOfFile: tmpFile) else {
            throw NSError(domain: "SubtitleHelper", code: -1, userInfo: nil)
        }

        var json: [[String:AnyObject]]?
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [[String:AnyObject]]
        } catch let e {
            throw e
        }

        guard let models = json else {
            throw NSError(domain: "SubtitleHelper", code: -1, userInfo: nil)
        }

        for model in models {
            if let generated = Subtitle(json: model) {
                subtitles.append(generated)
            }
        }

        loadingComplete = true
    }

}
