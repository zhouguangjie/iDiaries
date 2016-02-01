//
//  iDiariesTests.swift
//  iDiariesTests
//
//  Created by AlexChow on 16/1/16.
//  Copyright © 2016年 GStudio. All rights reserved.
//

import XCTest

class iDiariesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let date = DateHelper.generateDate(2016, month: 1, day: 16, hour: 18, minute: 34, second: 34)
        print(date)
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
