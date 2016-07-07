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
        subtitleEntryCollectionView.selectable = false
        subtitleEntryCollectionView.dataSource = self
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        if document != nil {
            return 1
        } else {
            return 0
        }
    }

    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if let srt = document {
            return srt.subtitles.count
        } else {
            return 0
        }
    }

    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItemWithIdentifier("EntryCell", forIndexPath: indexPath)
        guard let entry = cell as? SubtitleEntryItem,
            let subtitle = document?.subtitles[indexPath.item]
            else {
            return cell
        }
        entry.setupWithSubtitle(subtitle)

        return entry
    }

}

