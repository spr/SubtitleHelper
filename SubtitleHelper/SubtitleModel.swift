//
//  SubtitleModel.swift
//  SubtitleHelper
//
//  Created by Scott Robertson on 5/15/16.
//  Copyright © 2016 Scott Paul Robertson. All rights reserved.
//

import Foundation

protocol SubRipSubtitle {
    func subRipRepresentation() -> String
}

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

extension Subtitle : SubRipSubtitle {
    func subRipRepresentation() -> String {
        return "\(entry)\n\(subRipTimeRepresentation(start)) --> \(subRipTimeRepresentation(end))\n\(content)\n\n"
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

func subRipTimeRepresentation(_ time: TimeInterval) -> String {
    guard time >= 0.0 else {
        return "00:00:00,000"
    }

    let (hours, minutes, seconds, milliseconds) = timeComponents(time)

    return NSString(format: "%02d:%02d:%02d,%03d", hours, minutes, seconds, milliseconds) as String
}

func displayTimeRepresentation(_ time: TimeInterval) -> String {
    guard time >= 0.0 else {
        return "00:00:00.000"
    }

    let (hours, minutes, seconds, milliseconds) = timeComponents(time)

    return NSString(format: "%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds) as String
}

func editingTimeRepresentation(_ time: TimeInterval) -> String {
    guard time >= 0.0 else {
        return "000000000"
    }

    let (hours, minutes, seconds, milliseconds) = timeComponents(time)

    return NSString(format: "%02d%02d%02d%03d", hours, minutes, seconds, milliseconds) as String
}

private func timeComponents(_ time: TimeInterval) -> (UInt, UInt, UInt, UInt) {
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

enum TimeConversionError : ErrorProtocol {
    case improperFormat, tooManyHours(hours: UInt), tooManyMinutes(minutes: UInt), tooManySeconds(seconds: UInt), tooManyMilliseconds(milliseconds: UInt)
}

func timeIntervalFromDisplayTime(_ displayTime: String) throws -> TimeInterval {
    let scanner = Scanner.init(string: displayTime)
    let ptr: UnsafeMutablePointer<UInt64> = UnsafeMutablePointer<UInt64>(allocatingCapacity: 1)

    if !scanner.scanUnsignedLongLong(ptr) {
        throw TimeConversionError.improperFormat
    }
    let hours = ptr.pointee
    if hours > 99 {
        throw TimeConversionError.tooManyHours(hours: UInt(hours))
    }

    if !scanner.scanString(":", into: nil) {
        throw TimeConversionError.improperFormat
    }

    if !scanner.scanUnsignedLongLong(ptr) {
        throw TimeConversionError.improperFormat
    }
    let minutes = ptr.pointee
    if minutes > 59 {
        throw TimeConversionError.tooManyMinutes(minutes: UInt(minutes))
    }

    if !scanner.scanString(":", into: nil) {
        throw TimeConversionError.improperFormat
    }

    if !scanner.scanUnsignedLongLong(ptr) {
        throw TimeConversionError.improperFormat
    }
    let seconds = ptr.pointee
    if seconds > 59 {
        throw TimeConversionError.tooManySeconds(seconds: UInt(seconds))
    }

    if !scanner.scanString(".", into: nil) {
        throw TimeConversionError.improperFormat
    }

    if !scanner.scanUnsignedLongLong(ptr) {
        throw TimeConversionError.improperFormat
    }
    let milliseconds = ptr.pointee
    if milliseconds > 999 {
        throw TimeConversionError.tooManyMilliseconds(milliseconds: UInt(milliseconds))
    }

    ptr.deallocateCapacity(1)

    let total = (hours * 60 * 60 * 1000) + (minutes * 60 * 1000) + (seconds * 1000) + milliseconds
    let interval: TimeInterval = Double(total)/1000.0
    
    return interval
}
