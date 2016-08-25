//
//  SubtitleModel.swift
//  SubtitleHelper
//
//  Created by Scott Robertson on 5/15/16.
//  Copyright © 2016 Scott Paul Robertson. All rights reserved.
//

import Foundation

/// A generic class to represent a single subtitle
/// 
/// Fields originally based on what is provided by SubRip, but
/// is intended to be generic enough for many formats. In the future
/// I'd expect to at least add color.
struct Subtitle {
    /// A number representing where this falls in order.
    /// Required by SubRip.
    /// Consider autogenerating this.
    var entry: UInt
    
    /// When to start displaying the subtitle
    var start: TimeInterval
    
    /// When to stop displaying the subtitle
    var end: TimeInterval
    
    /// The actual text of the subtitle
    var content: String
    
    /// Whether or not to include this subtitle when saving
    var include: Bool = true

    /// Init from a JSON format (via the perl script)
    /// This is SubRip specific today
    init?(json: NSDictionary) {
        guard let entryString = json["entry"] as? String,
            let startNumber = json["start"] as? NSNumber,
            let endNumber = json["end"] as? NSNumber,
            let content = json["content"] as? String
            else {
                return nil
        }

        guard let entry = UInt(entryString) else {
            return nil
        }

        self.entry = entry
        self.start = startNumber.doubleValue
        self.end = endNumber.doubleValue
        self.content = content
    }

    /// Init by providing parameters
    init(entry: UInt, start: TimeInterval, end: TimeInterval, content: String) {
        self.entry = entry
        self.start = start
        self.end = end
        self.content = content
    }
}
