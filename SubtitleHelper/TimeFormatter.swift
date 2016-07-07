//
//  TimeFormatter.swift
//  SubtitleHelper
//
//  Created by Scott Robertson on 5/15/16.
//  Copyright © 2016 Scott Paul Robertson. All rights reserved.
//

import Cocoa

class TimeFormatter: NSFormatter {
    override func stringForObjectValue(obj: AnyObject) -> String? {
        guard let number = obj as? NSNumber else {
            return nil
        }

        let time: NSTimeInterval = number.doubleValue

        return displayTimeRepresentation(time)
    }

    override func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>, forString string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        do {
            let interval = try timeIntervalFromDisplayTime(string)
            let number = NSNumber(double: interval)
            obj.memory = number
            
            return true
        } catch TimeConversionError.ImproperFormat {
            error.memory = "Passed invalid format, expected: '00:00:00.000'" as NSString

            return false
        } catch TimeConversionError.TooManyHours(let passed) {
            error.memory = "Passed too many hours: '\(passed)', maximum is '99'" as NSString

            return false
        } catch TimeConversionError.TooManyMinutes(let passed) {
            error.memory = "Passed too many minutes: '\(passed)', maximum is '59'" as NSString

            return false
        } catch TimeConversionError.TooManySeconds(let passed) {
            error.memory = "Passed too many seconds: '\(passed)', maximum is '59'" as NSString

            return false
        } catch TimeConversionError.TooManyMilliseconds(let passed) {
            error.memory = "Passed too many milliseconds: '\(passed)', maximum is '999'" as NSString

            return false
        } catch {
            // Impossible
            return false
        }
    }

}
