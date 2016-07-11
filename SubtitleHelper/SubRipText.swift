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
    var generalTimeShift: TimeInterval = 0
    var loadingComplete = false

    override class func autosavesInPlace() -> Bool {
        return false
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: "SRTWindow") as! NSWindowController
        self.addWindowController(windowController)
    }

    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
    }

    override func data(ofType typeName: String) throws -> Data {
        guard let output = NSMutableData(capacity: subtitles.count * 1000) else {
            throw NSError(domain: NSOSStatusErrorDomain, code: -1, userInfo: nil)
        }

        for subtitle in subtitles where subtitle.include {
            var current = subtitle
            current.start += generalTimeShift
            current.end += generalTimeShift
            guard let data = current.subRipRepresentation().data(using: String.Encoding.utf8) else {
                continue
            }
            output.append(data)
        }

        return (NSData(data: output as Data) as Data)
    }

    override var isEntireFileLoaded: Bool {
        return loadingComplete
    }

    override func read(from url: URL, ofType typeName: String) throws {
        guard let filename = url.path else {
            throw NSError(domain: NSCocoaErrorDomain, code: NSCocoaError.fileReadInvalidFileNameError.rawValue, userInfo: nil)
        }

        guard let scriptPath = Bundle.main.pathForResource("convert", ofType: "pl") else {
            throw NSError(domain: "SubtitleHelper", code: -1, userInfo: nil)
        }

        let task = Task()
        task.arguments = [scriptPath, filename]
        task.launchPath = "/usr/bin/perl"
        let tmpFile = NSTemporaryDirectory() + "processzz.json"
        guard FileManager.default.createFile(atPath: tmpFile, contents: nil, attributes: nil) else {
            throw NSError(domain: "SubtitleHelper", code: -1, userInfo: nil)
        }
        defer {
            try! FileManager.default.removeItem(atPath: tmpFile)
        }

        guard let output = FileHandle(forWritingAtPath: tmpFile) else {
            throw NSError(domain: "SubtitleHelper", code: -1, userInfo: nil)
        }
        task.standardOutput = output
        task.standardError = FileHandle.withNullDevice

        task.launch()
        task.waitUntilExit()

        output.closeFile()

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: tmpFile)) else {
            throw NSError(domain: "SubtitleHelper", code: -1, userInfo: nil)
        }

        var json: [[String:AnyObject]]?
        do {
            json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [[String:AnyObject]]
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
