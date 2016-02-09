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
    
    enum TestError : ErrorType {
        case Henk, Fred, Sap, Saus
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
    
    func testThrowingFutures() {
        func testFunc() -> ThrowingFuture<Void> {
            return ThrowingFuture<Void> {
                throw TestError.Sap
            }
        }
        
        let errorExpectation = expectationWithDescription("The TestError is passed to the closure correctly")
        
        testFunc().then{
            XCTFail("The closure passed to then() should not be executed when an error is thrown")
        }.onError{ e in
            guard case TestError.Sap = e else {
                XCTFail()
                return
            }
            
            errorExpectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(0.1, handler: nil)
        
        // This should crash:
//        testFunc().then { XCTFail() }
    }
    
    func testOperators() {
        func throwingTestFunc() -> ThrowingFuture<Int> {
            return ThrowingFuture {
                throw TestError.Henk
            }
        }
        
        do {
            let _ = try !>throwingTestFunc()
            XCTFail()
        } catch TestError.Henk {
            
        } catch {
            XCTFail()
        }
    }
    
    func testCompleter() {
        let expectation = expectationWithDescription("Completer completes future")
        
        let completer = Completer<Void>()
        completer.future.then { expectation.fulfill() }
        completer.complete()
        
        waitForExpectationsWithTimeout(0.1, handler: nil)
    }
    
}
