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

    override var isEntireFileLoaded: Bool {
        return loadingComplete
    }
    
    override class func autosavesInPlace() -> Bool {
        return false
    }
    
    override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        return true
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


    override func read(from url: URL, ofType typeName: String) throws {
        let filepath = url.path
        let filename = url.lastPathComponent
        guard !filepath.isEmpty && !filename.isEmpty else {
            throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.fileReadInvalidFileName.rawValue, userInfo: nil)
        }

        guard let scriptPath = Bundle.main.path(forResource: "convert", ofType: "pl") else {
            throw NSError(domain: "SubtitleHelper", code: -1, userInfo: nil)
        }

        let task = Process()
        task.arguments = [scriptPath, filepath]
        task.launchPath = "/usr/bin/perl"
        let tmpFile = NSTemporaryDirectory() + "process\(filename).json"
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
        task.standardError = FileHandle.nullDevice

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
            if let generated = Subtitle(json: model as NSDictionary) {
                subtitles.append(generated)
            }
        }

        loadingComplete = true
    }

}

extension Notification.Name {
    static let SubRipTextUpdatedEntry = Notification.Name("SubRipTextUpdatedEntry")
    static let SubRipTextUpdatedEntryIndexKey = "index"
    static let SubRipTextUpdatedTimeshift = Notification.Name("SubRipTextUpdatedTimeshift")
}

// Undo handling
extension SubRipText {
    
    class SubRipTextUndoState : NSObject {
        var changedSubtitle: Subtitle? = nil
        var subtitleIndex: Int? = nil
        var generalTimeShift: TimeInterval? = nil
        
        init(changedSubtitle: Subtitle? = nil, subtitleIndex: Int? = nil, generalTimeShift: TimeInterval? = nil) {
            self.changedSubtitle = changedSubtitle
            self.subtitleIndex = subtitleIndex
            self.generalTimeShift = generalTimeShift
            super.init()
        }
    }
    
    func update(changedSubtitle: Subtitle? = nil, subtitleIndex: Int? = nil, newTimeshift: TimeInterval? = nil) {
        var oldSubtitle: Subtitle? = nil
        var oldTimeshift: TimeInterval? = nil
        
        if let changedSubtitle = changedSubtitle, let subtitleIndex = subtitleIndex {
            oldSubtitle = subtitles[subtitleIndex]
            subtitles[subtitleIndex] = changedSubtitle
        }
        if let newTimeshift = newTimeshift {
            oldTimeshift = generalTimeShift
            generalTimeShift = newTimeshift
        }
        
        let undoState = SubRipTextUndoState(changedSubtitle: oldSubtitle, subtitleIndex: subtitleIndex, generalTimeShift: oldTimeshift)

        undoManager?.registerUndo(withTarget: self, handler: { (obj) in
            obj.update(undoState: undoState)
        })

        updateChangeCount(NSDocumentChangeType.changeDone)
    }
    
    func update(undoState: SubRipTextUndoState) {
        var redoSubtitle: Subtitle? = nil
        var redoTimeshift: TimeInterval? = nil
        
        if let subtitle = undoState.changedSubtitle, let index = undoState.subtitleIndex {
            redoSubtitle = subtitles[index]
            subtitles[index] = subtitle
            NotificationCenter.default.post(name: Notification.Name.SubRipTextUpdatedEntry, object: self, userInfo: [Notification.Name.SubRipTextUpdatedEntryIndexKey: NSNumber(value: index)])
        }
        if let timeshift = undoState.generalTimeShift {
            redoTimeshift = generalTimeShift
            generalTimeShift = timeshift
            NotificationCenter.default.post(name: Notification.Name.SubRipTextUpdatedTimeshift, object: self)
        }
        
        let redoState = SubRipTextUndoState(changedSubtitle: redoSubtitle, subtitleIndex: undoState.subtitleIndex, generalTimeShift: redoTimeshift)

        undoManager?.registerUndo(withTarget: self, handler: { (obj) in
            obj.update(undoState: redoState)
        })
    }
}

// Extensions for the low level model
protocol SubRipSubtitle {
    func subRipRepresentation() -> String
}

extension Subtitle : SubRipSubtitle {
    func subRipRepresentation() -> String {
        return "\(entry)\n\(Subtitle.subRipTimeRepresentation(start)) --> \(Subtitle.subRipTimeRepresentation(end))\n\(content)\n\n"
    }
    
    static func subRipTimeRepresentation(_ time: TimeInterval) -> String {
        guard time >= 0.0 else {
            return "00:00:00,000"
        }
        
        let (hours, minutes, seconds, milliseconds) = timeComponents(time)
        
        return NSString(format: "%02d:%02d:%02d,%03d", hours, minutes, seconds, milliseconds) as String
    }
}

extension Array where Element:SubRipSubtitle {
    func subRipRepresentation() -> String {
        let output = self.reduce("") { (output, srs) -> String in
            output + srs.subRipRepresentation()
        }
        return output
    }
}
