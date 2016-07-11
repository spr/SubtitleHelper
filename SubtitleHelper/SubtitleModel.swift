//
//  SubtitleModel.swift
//  SubtitleHelper
//
//  Created by Scott Robertson on 5/15/16.
//  Copyright © 2016 Scott Paul Robertson. All rights reserved.
//

import Foundation

struct Subtitle {
    var entry: UInt
    var start: TimeInterval
    var end: TimeInterval
    var content: String
    var include: Bool = true

    init?(json: NSDictionary) {
        guard let entryString = json["entry"] as? String,
            startNumber = json["start"] as? NSNumber,
            endNumber = json["end"] as? NSNumber,
            content = json["content"] as? String
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

    init(entry: UInt, start: TimeInterval, end: TimeInterval, content: String) {
        self.entry = entry
        self.start = start
        self.end = end
        self.content = content
    }
}
