//
//  WhenTests.swift
//  WhenTests
//
//  Created by Robbert Brandsma on 09-02-16.
//  Copyright © 2016 PlanTeam. All rights reserved.
//

import XCTest
import When

class WhenTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testVoidFutures() {
        let executionExpectation = expectationWithDescription("Futures get executed")
        let thenExpectation = expectationWithDescription("Future.then() works correctly")
        
        func testFunc() -> Future<Void> {
            return Future { executionExpectation.fulfill() }
        }
        
        testFunc().then {
            thenExpectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(0.1, handler: nil)
    }
    
}
