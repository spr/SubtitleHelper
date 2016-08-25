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
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name.SubRipTextUpdatedEntry, object: document)
    }
    
    func update(notification: Notification) {
        guard let index = (notification.userInfo?[Notification.Name.SubRipTextUpdatedEntryIndexKey] as? NSNumber)?.intValue else {
                return
        }
        let indexPath = IndexPath(item: index, section: 0)
        let set = Set(arrayLiteral: indexPath)
        subtitleEntryCollectionView.reloadItems(at: set)
    }

    override var representedObject: Any? {
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
            var entry = document.subtitles[number.intValue]
            entry.include = !entry.include
            document.update(changedSubtitle: entry, subtitleIndex: number.intValue)
        }
    }
    
    func updateStartTime(_ info: [String: AnyObject]) {
        guard let num = (info["entry"] as? NSNumber)?.intValue,
            let startString = info["value"] as? String else {
                return
        }
        if let document = document, let time = try? timeIntervalFromDisplayTime(startString) {
            var entry = document.subtitles[num]
            entry.start = time
            document.update(changedSubtitle: entry, subtitleIndex: num)
        }
    }
    
    func updateEndTime(_ info: [String: AnyObject]) {
        guard let num = (info["entry"] as? NSNumber)?.intValue,
            let endString = info["value"] as? String else {
                return
        }
        if let document = document, let time = try? timeIntervalFromDisplayTime(endString) {
            var entry = document.subtitles[num]
            entry.end = time
            document.update(changedSubtitle: entry, subtitleIndex: num)
        }
    }
    
    func updateContent(_ info: [String: AnyObject]) {
        guard let num = (info["entry"] as? NSNumber)?.intValue,
            let content = info["value"] as? String else {
                return
        }
        if let document = document {
            var entry = document.subtitles[num]
            entry.content = content
            document.update(changedSubtitle: entry, subtitleIndex: num)
        }
    }

}

