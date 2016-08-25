//
//  TimeFormatter.swift
//  SubtitleHelper
//
//  Created by Scott Robertson on 5/15/16.
//  Copyright © 2016 Scott Paul Robertson. All rights reserved.
//

import Cocoa

class TimeFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        guard let number = obj as? NSNumber else {
            return nil
        }

        let time: TimeInterval = number.doubleValue

        return displayTimeRepresentation(time)
    }

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        do {
            let interval = try timeIntervalFromDisplayTime(string)
            let number = NSNumber(value: interval)
            obj?.pointee = number
            
            return true
        } catch TimeConversionError.improperFormat {
            error?.pointee = "Passed invalid format, expected: '00:00:00.000'" as NSString

            return false
        } catch TimeConversionError.tooManyHours(let passed) {
            error?.pointee = "Passed too many hours: '\(passed)', maximum is '99'" as NSString

            return false
        } catch TimeConversionError.tooManyMinutes(let passed) {
            error?.pointee = "Passed too many minutes: '\(passed)', maximum is '59'" as NSString

            return false
        } catch TimeConversionError.tooManySeconds(let passed) {
            error?.pointee = "Passed too many seconds: '\(passed)', maximum is '59'" as NSString

            return false
        } catch TimeConversionError.tooManyMilliseconds(let passed) {
            error?.pointee = "Passed too many milliseconds: '\(passed)', maximum is '999'" as NSString

            return false
        } catch {
            // Impossible
            return false
        }
    }

}
