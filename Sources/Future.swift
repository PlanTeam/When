//
//  Future.swift
//  When
//
//  Created by Robbert Brandsma on 09-02-16.
//  Copyright © 2016 PlanTeam. All rights reserved.
//

import Foundation

private var backgroundExecutionQueue = dispatch_queue_create("planteam.when.backgroundexecution", DISPATCH_QUEUE_CONCURRENT)
private var futureManipulationQueue = dispatch_queue_create("planteam.when.futuremanipulation", DISPATCH_QUEUE_SERIAL)

/**
 Use a future for doing work asynchronously and returning a result.
 
 A future can represent a value. Receivers of a Future can register callbacks that handle the value
 a future represents.
 
 ```swift
 func intensiveFunction() -> Future<String> {
    return Future {
        // Intensive computation
        return "Result"
    }
 }
 
 expensiveFunction().then { result in
    print("The result: \(result)")
 }
 ```
 
 If you want to wait until the future completes, you can use the `!>` prefix operator:
 
 ```swift
 let value = !>expensiveFunction()
 ```
 
 If you need error handling, use a `ThrowingFuture`.
*/
public class Future<Wrapped> {
    private typealias FutureCallback = (Wrapped) -> ()
    
    private final var value: Wrapped?
    private final var closures = [FutureCallback]()
    
    internal final func complete(value: Wrapped) {
        dispatch_sync(futureManipulationQueue) { self.value = value }
        for c in closures {
            c(value)
        }
    }
    
    internal func await() -> Wrapped {
        while value == nil { usleep(1) }
        return value!
    }
    
    /// Execute a given closure after the Future has copmleted.
    public final func then(closure: (Wrapped) -> ()) -> Self {
        dispatch_async(futureManipulationQueue) {
            if let value = self.value {
                closure(value)
            } else {
                self.closures.append(closure)
            }
        }
        return self
    }
    
    /// Initialize a new future and execute the given closure. The closure is executed asynchronously on a special dispatch queue.
    public init(execute closure: () -> (Wrapped)) {
        dispatch_async(backgroundExecutionQueue) {
            self.complete(closure())
        }
    }
    
    internal init() {}
}

/**
 A `Future` with support for error handling.
 
 ```swift
 expensiveComputation().then {
    print("result: \($0)")
 }.onError{
    print("error: \($0)")
 }
 ```
 
 The `!>` operator also throws when used with a ThrowingFuture.
 
 ```swift
 let result = try !>expensiveComputation()
 ```
 
 Not handling errors coming from a ThrowingFuture will result in an error.
*/
public final class ThrowingFuture<Wrapped> : Future<Wrapped> {
    typealias ErrorCallback = (ErrorType) -> ()
    
    private var error: ErrorType?
    private var errorClosures = [ErrorCallback]()
    
    internal override func await() -> Wrapped {
        return try! safeAwait()
    }
    
    internal func safeAwait() throws -> Wrapped {
        errorClosures.append({_ in})
        
        repeat {
            if let value = value {
                return value
            } else if let error = error {
                throw error
            }
            usleep(1)
        } while true
    }
    
    /// Initialize a new future and execute the given closure. The closure is executed asynchronously on a special dispatch queue.
    public init(executeThrowing closure: () throws -> (Wrapped)) {
        super.init()
        dispatch_async(backgroundExecutionQueue) {
            do {
                self.complete(try closure())
            } catch let e {
                self.handleError(e)
            }
        }
    }
    
    /// If an error is thrown for this Future, handle it trough the given handler.
    public func onError(handler: (ErrorType) -> ()) -> Self {
        dispatch_async(futureManipulationQueue) {
            if let error = self.error {
                handler(error)
            } else {
                self.errorClosures.append(handler)
            }
        }
        return self
    }
    
    internal func handleError(error: ErrorType) {
        dispatch_sync(futureManipulationQueue) { self.error = error }
        
        for c in errorClosures {
            c(error)
        }
    }
    
    internal override init() { super.init() }
    
    deinit {
        if let error = error where errorClosures.count == 0 {
            // Crash if an error wasn't handled!
            print("An error was not handled in a ThrowingFuture of type \(self.dynamicType). You should provide error handling logic.")
            try! { throw error }()
        }
    }
}