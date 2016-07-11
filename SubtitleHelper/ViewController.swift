//
//  ViewController.swift
//  SubtitleHelper
//
//  Created by Scott Robertson on 5/12/16.
//  Copyright © 2016 Scott Paul Robertson. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSCollectionViewDataSource {

    @IBOutlet weak var subtitleEntryCollectionView: NSCollectionView!

    var document: SubRipText? {
        return view.window?.windowController?.document as? SubRipText
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        subtitleEntryCollectionView.isSelectable = false
        subtitleEntryCollectionView.dataSource = self
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        if document != nil {
            return 1
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if let srt = document {
            return srt.subtitles.count
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(withIdentifier: "EntryCell", for: indexPath)
        guard let entry = cell as? SubtitleEntryItem,
            let subtitle = document?.subtitles[(indexPath as NSIndexPath).item]
            else {
            return cell
        }
        entry.setupWithSubtitle(subtitle)
        entry.referenceIndex = (indexPath as NSIndexPath).item

        return entry
    }
    
    func toggleInclude(_ number: NSNumber) {
        if let document = document {
            var subtitles = document.subtitles
            var entry = subtitles[number.intValue]
            entry.include = !entry.include
            subtitles[number.intValue] = entry
            document.subtitles = subtitles
            document.updateChangeCount(NSDocumentChangeType.changeDone)
        }
    }
    
    func updateStartTime(_ info: [String: AnyObject]) {
        guard let num = (info["entry"] as? NSNumber)?.intValue,
            let startString = info["value"] as? String else {
                return
        }
        if let document = document, time = try? timeIntervalFromDisplayTime(startString) {
            var subtitles = document.subtitles
            var entry = subtitles[num]
            entry.start = time
            subtitles[num] = entry
            document.subtitles = subtitles
            document.updateChangeCount(NSDocumentChangeType.changeDone)
        }
    }
    
    func updateEndTime(_ info: [String: AnyObject]) {
        guard let num = (info["entry"] as? NSNumber)?.intValue,
            let endString = info["value"] as? String else {
                return
        }
        if let document = document, time = try? timeIntervalFromDisplayTime(endString) {
            var subtitles = document.subtitles
            var entry = subtitles[num]
            entry.end = time
            subtitles[num] = entry
            document.subtitles = subtitles
            document.updateChangeCount(NSDocumentChangeType.changeDone)
        }
    }
    
    func updateContent(_ info: [String: AnyObject]) {
        guard let num = (info["entry"] as? NSNumber)?.intValue,
            let content = info["value"] as? String else {
                return
        }
        if let document = document {
            var subtitles = document.subtitles
            var entry = subtitles[num]
            entry.content = content
            subtitles[num] = entry
            document.subtitles = subtitles
            document.updateChangeCount(NSDocumentChangeType.changeDone)
        }
    }

}

