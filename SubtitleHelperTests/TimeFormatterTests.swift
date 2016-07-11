//
//  TimeFormatterTests.swift
//  SubtitleHelper
//
//  Created by Scott Robertson on 5/15/16.
//  Copyright © 2016 Scott Paul Robertson. All rights reserved.
//

import XCTest
@testable import SubtitleHelper

class TimeFormatterTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSuccessfullGetObjectValue() {
        let formatter = TimeFormatter()

        var numberOut: AnyObject? = nil
        var errorOut: NSString? = nil

        XCTAssertTrue(formatter.getObjectValue(&numberOut, for: "00:24:58.190", errorDescription: &errorOut))

        XCTAssertNil(errorOut)

        if let number = numberOut as? NSNumber {
            XCTAssertEqual(number.doubleValue, 1498.19)
        }
    }

    func testBadFormatGetObjectValue() {
        let formatter = TimeFormatter()

        var numberOut: AnyObject? = nil
        var errorOut: NSString? = nil

        XCTAssertFalse(formatter.getObjectValue(&numberOut, for: "BAD", errorDescription: &errorOut))

        XCTAssertNil(numberOut)

        if let error = errorOut {
            XCTAssertEqual(error, "Passed invalid format, expected: '00:00:00.000'")
        }
    }

    func testBadHoursGetObjectValue() {
        let formatter = TimeFormatter()

        var numberOut: AnyObject? = nil
        var errorOut: NSString? = nil

        XCTAssertFalse(formatter.getObjectValue(&numberOut, for: "100:00:00.000", errorDescription: &errorOut))

        XCTAssertNil(numberOut)

        if let error = errorOut {
            XCTAssertEqual(error, "Passed too many hours: '100', maximum is '99'")
        }
    }

    func testBadMinutesGetObjectValue() {
        let formatter = TimeFormatter()

        var numberOut: AnyObject? = nil
        var errorOut: NSString? = nil

        XCTAssertFalse(formatter.getObjectValue(&numberOut, for: "00:60:00.000", errorDescription: &errorOut))

        XCTAssertNil(numberOut)

        if let error = errorOut {
            XCTAssertEqual(error, "Passed too many minutes: '60', maximum is '59'")
        }
    }

    func testBadSecondsGetObjectValue() {
        let formatter = TimeFormatter()

        var numberOut: AnyObject? = nil
        var errorOut: NSString? = nil

        XCTAssertFalse(formatter.getObjectValue(&numberOut, for: "00:00:60.000", errorDescription: &errorOut))

        XCTAssertNil(numberOut)

        if let error = errorOut {
            XCTAssertEqual(error, "Passed too many seconds: '60', maximum is '59'")
        }
    }

    func testBadMillisecondsGetObjectValue() {
        let formatter = TimeFormatter()

        var numberOut: AnyObject? = nil
        var errorOut: NSString? = nil

        XCTAssertFalse(formatter.getObjectValue(&numberOut, for: "00:00:00.1000", errorDescription: &errorOut))

        XCTAssertNil(numberOut)

        if let error = errorOut {
            XCTAssertEqual(error, "Passed too many milliseconds: '1000', maximum is '999'")
        }
    }

    func testStringForObjectValue() {
        let formatter = TimeFormatter()

        XCTAssertEqual(formatter.string(for: NSNumber(value: 1498.19)), "00:24:58.190")

        let failed = formatter.string(for: "Kilroy was here!")
        XCTAssertNil(failed)
    }
    
    func testCuriousValue() {
        let formatter = TimeFormatter()
        
        var input = 0.7
        input += 0.1
        
        let result = formatter.string(for: NSNumber(value: input))
        
        XCTAssertEqual(result, "00:00:00.799")
        
        var numberOut: AnyObject? = nil
        var errorOut: NSString? = nil
        
        XCTAssertTrue(formatter.getObjectValue(&numberOut, for: "00:00:00.700", errorDescription: &errorOut))
        
        guard let num = (numberOut as? NSNumber)?.doubleValue else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(num, 0.7)
    }

}
