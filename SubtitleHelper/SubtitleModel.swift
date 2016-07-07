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
    var start: NSTimeInterval
    var end: NSTimeInterval
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

    init(entry: UInt, start: NSTimeInterval, end: NSTimeInterval, content: String) {
        self.entry = entry
        self.start = start
        self.end = end
        self.content = content
    }

    func subRipRepresentation() -> String {
        return "\(entry)\n\(subRipTimeRepresentation(start)) --> \(subRipTimeRepresentation(end))\n\(content)\n\n"
    }
}

func subRipTimeRepresentation(time: NSTimeInterval) -> String {
    guard time >= 0.0 else {
        return "00:00:00,000"
    }

    let (hours, minutes, seconds, milliseconds) = timeComponents(time)

    return NSString(format: "%02d:%02d:%02d,%03d", hours, minutes, seconds, milliseconds) as String
}

func displayTimeRepresentation(time: NSTimeInterval) -> String {
    guard time >= 0.0 else {
        return "00:00:00.000"
    }

    let (hours, minutes, seconds, milliseconds) = timeComponents(time)

    return NSString(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds) as String
}

func editingTimeRepresentation(time: NSTimeInterval) -> String {
    guard time >= 0.0 else {
        return "000000000"
    }

    let (hours, minutes, seconds, milliseconds) = timeComponents(time)

    return NSString(format: "%02d%02d%02d%03d", hours, minutes, seconds, milliseconds) as String
}

private func timeComponents(time: NSTimeInterval) -> (UInt, UInt, UInt, UInt) {
    let msTime = UInt(time * 1000)

    var next: UInt
    var milliseconds: UInt
    var seconds: UInt
    var minutes: UInt
    var hours: UInt

    (next, milliseconds) = (msTime / 1000, msTime % 1000)
    (next, seconds) = (next / 60, next % 60)
    (hours, minutes) = (next / 60, next % 60)

    return (hours, minutes, seconds, milliseconds)
}

enum TimeConversionError : ErrorType {
    case ImproperFormat, TooManyHours(hours: UInt), TooManyMinutes(minutes: UInt), TooManySeconds(seconds: UInt), TooManyMilliseconds(milliseconds: UInt)
}

func timeIntervalFromDisplayTime(displayTime: String) throws -> NSTimeInterval {
    let scanner = NSScanner.init(string: displayTime)
    let ptr: UnsafeMutablePointer<UInt64> = UnsafeMutablePointer<UInt64>.alloc(1)

    if !scanner.scanUnsignedLongLong(ptr) {
        throw TimeConversionError.ImproperFormat
    }
    let hours = ptr.memory
    if hours > 99 {
        throw TimeConversionError.TooManyHours(hours: UInt(hours))
    }

    if !scanner.scanString(":", intoString: nil) {
        throw TimeConversionError.ImproperFormat
    }

    if !scanner.scanUnsignedLongLong(ptr) {
        throw TimeConversionError.ImproperFormat
    }
    let minutes = ptr.memory
    if minutes > 59 {
        throw TimeConversionError.TooManyMinutes(minutes: UInt(minutes))
    }

    if !scanner.scanString(":", intoString: nil) {
        throw TimeConversionError.ImproperFormat
    }

    if !scanner.scanUnsignedLongLong(ptr) {
        throw TimeConversionError.ImproperFormat
    }
    let seconds = ptr.memory
    if seconds > 59 {
        throw TimeConversionError.TooManySeconds(seconds: UInt(seconds))
    }

    if !scanner.scanString(".", intoString: nil) {
        throw TimeConversionError.ImproperFormat
    }

    if !scanner.scanUnsignedLongLong(ptr) {
        throw TimeConversionError.ImproperFormat
    }
    let milliseconds = ptr.memory
    if milliseconds > 999 {
        throw TimeConversionError.TooManyMilliseconds(milliseconds: UInt(milliseconds))
    }

    ptr.dealloc(1)

    let total = (hours * 60 * 60 * 1000) + (minutes * 60 * 1000) + (seconds * 1000) + milliseconds
    let interval: NSTimeInterval = Double(total)/1000.0
    
    return interval
}
