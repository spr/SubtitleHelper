//
//  ModelTests.swift
//  SubtitleHelper
//
//  Created by Scott Robertson on 5/15/16.
//  Copyright © 2016 Scott Paul Robertson. All rights reserved.
//

import XCTest
@testable import SubtitleHelper

class ModelTests: XCTestCase {
    let exampleJSON: NSDictionary = [
        "content": "\"Idea Notebook for Obtaining\na Spaceship of My Own.\"",
        "entry": "462",
        "start": NSNumber(double: 1476.44),
        "end": NSNumber(double: 1479.37)
    ]
    let badJSON: NSDictionary = [
        "content": "\"Idea Notebook for Obtaining\na Spaceship of My Own.\"",
        "entry": "462"
    ]
    let moreBadJSON: NSDictionary = [
        "content": "\"Idea Notebook for Obtaining\na Spaceship of My Own.\"",
        "entry": "Not a Number",
        "start": NSNumber(double: 1476.44),
        "end": NSNumber(double: 1479.37)
    ]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSubtitleCreation() {
        let subtitle = Subtitle(entry: 1, start: 1.0, end: 3.0, content: "Hi Everyone!")
        XCTAssertEqual(subtitle.entry, 1)
        XCTAssertEqual(subtitle.start, 1.0)
        XCTAssertEqual(subtitle.end, 3.0)
        XCTAssertEqual(subtitle.content, "Hi Everyone!")
    }

    func testSubtitleCreationFromJSON() {
        let subtitle = Subtitle(json: exampleJSON)
        XCTAssertNotNil(subtitle)
        if let valid = subtitle {
            XCTAssertEqual(valid.entry, 462)
            XCTAssertEqual(valid.start, 1476.44)
            XCTAssertEqual(valid.end, 1479.37)
            XCTAssertEqual(valid.content, "\"Idea Notebook for Obtaining\na Spaceship of My Own.\"")
        }

        let broken = Subtitle(json: badJSON)
        XCTAssertNil(broken)

        let reallyBroken = Subtitle(json: moreBadJSON)
        XCTAssertNil(reallyBroken)
    }

    func testSubtitleJSONCreationPerformance() {
        self.measureBlock {
            for _ in 0...1000 {
                _ = Subtitle(json: self.exampleJSON)
            }
        }
    }

    func testSubRipRepresentation() {
        let subtitle = Subtitle(json: exampleJSON)
        if let valid = subtitle {
            let srt = valid.subRipRepresentation()
            XCTAssertEqual(srt, "462\n00:24:36,440 --> 00:24:39,370\n\"Idea Notebook for Obtaining\na Spaceship of My Own.\"\n\n")
        } else {
            XCTFail()
        }
    }

    func testDisplayTimeConversion() {
        // Some basics
        XCTAssertEqual(displayTimeRepresentation(0.6), "00:00:00.600")
        XCTAssertEqual(displayTimeRepresentation(1498.19), "00:24:58.190")
        XCTAssertEqual(displayTimeRepresentation(19999.051), "05:33:19.051")

        // Test extremes
        XCTAssertEqual(displayTimeRepresentation(0.0), "00:00:00.000")
        XCTAssertEqual(displayTimeRepresentation(359999.999), "99:59:59.999")
        XCTAssertEqual(displayTimeRepresentation(1.0001), "00:00:01.000")
        XCTAssertEqual(displayTimeRepresentation(1.0005), "00:00:01.000")
        XCTAssertEqual(displayTimeRepresentation(1.0009), "00:00:01.000")

        // Techincally invalid, and will never happen
        XCTAssertEqual(displayTimeRepresentation(360000.0), "100:00:00.000")
        XCTAssertEqual(displayTimeRepresentation(-1.0), "00:00:00.000")
    }

    func testTimeIntervalFromDisplayTime() {
        XCTAssertEqual(try! timeIntervalFromDisplayTime("00:00:00.600"), 0.6)
        XCTAssertEqual(try! timeIntervalFromDisplayTime("00:24:58.190"), 1498.19)
        XCTAssertEqual(try! timeIntervalFromDisplayTime("05:33:19.051"), 19999.051)

        XCTAssertEqual(try! timeIntervalFromDisplayTime("00:00:00.000"), 0.0)
        XCTAssertEqual(try! timeIntervalFromDisplayTime("99:59:59.999"), 359999.999)

        XCTAssertThrowsError(try timeIntervalFromDisplayTime("Kilroy was here!"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00:"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00:Kilroy"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00:00"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00:00:"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00:00:Kilroy"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00:00:00"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00:00:00."))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00:00:00.Kilroy"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("100:00:00.000"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00:60:00.000"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00:00:60.000"))
        XCTAssertThrowsError(try timeIntervalFromDisplayTime("00:00:00.1000"))
    }

    func testTimeIntervalFromDisplayTimePerformance() {
        self.measureBlock {
            for _ in 0...100 {
                try! timeIntervalFromDisplayTime("00:00:00.000")
                try! timeIntervalFromDisplayTime("05:24:13.500")
                try! timeIntervalFromDisplayTime("01:42:44.607")
            }
        }
    }

    func testEditingTimeConversion() {
        XCTAssertEqual(editingTimeRepresentation(0.6), "000000600")
        XCTAssertEqual(editingTimeRepresentation(1498.19), "002458190")
        XCTAssertEqual(editingTimeRepresentation(19999.051), "053319051")

        XCTAssertEqual(editingTimeRepresentation(0.0), "000000000")
        XCTAssertEqual(editingTimeRepresentation(359999.999), "995959999")
        XCTAssertEqual(editingTimeRepresentation(1.0001), "000001000")
        XCTAssertEqual(editingTimeRepresentation(1.0005), "000001000")
        XCTAssertEqual(editingTimeRepresentation(1.0009), "000001000")

        // Techincally invalid, and will never happen
        XCTAssertEqual(editingTimeRepresentation(360000.0), "1000000000")
        XCTAssertEqual(editingTimeRepresentation(-1.0), "000000000")
    }

    func testSubRipTimeConversion() {
        // Some basics
        XCTAssertEqual(subRipTimeRepresentation(0.6), "00:00:00,600")
        XCTAssertEqual(subRipTimeRepresentation(1498.19), "00:24:58,190")
        XCTAssertEqual(subRipTimeRepresentation(19999.051), "05:33:19,051")

        // Test extremes
        XCTAssertEqual(subRipTimeRepresentation(0.0), "00:00:00,000")
        XCTAssertEqual(subRipTimeRepresentation(359999.999), "99:59:59,999")
        XCTAssertEqual(subRipTimeRepresentation(1.0001), "00:00:01,000")
        XCTAssertEqual(subRipTimeRepresentation(1.0005), "00:00:01,000")
        XCTAssertEqual(subRipTimeRepresentation(1.0009), "00:00:01,000")

        // Techincally invalid, and will never happen
        XCTAssertEqual(subRipTimeRepresentation(360000.0), "100:00:00,000")
        XCTAssertEqual(subRipTimeRepresentation(-1.0), "00:00:00,000")
    }

    func testSubRipTimeConversionPerformance() {
        self.measureBlock {
            // Put the code you want to measure the time of here.
            for i in 0.0.stride(through: 500, by: 0.1) {
                subRipTimeRepresentation(i)
            }
        }
    }

}
