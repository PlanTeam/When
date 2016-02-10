//
//  Completer.swift
//  When
//
//  Created by Robbert Brandsma on 09-02-16.
//  Copyright © 2016 PlanTeam. All rights reserved.
//

import Foundation

/// Produces `Future`s that can be completed with a value at a later time.
public class Completer<Wrapped> {
    /// The `Future` that will be completed by this `Completer`.
    public let future = Future<Wrapped>()
    
    /// Create a new completer.
    public init() {}
    
    /// Create a new completer, and execute the given closure asynchronously using the completer.
    public init(closure: (Completer<Wrapped>) -> ()) {
        dispatch_async(backgroundExecutionQueue) { closure(self) }
    }
    
    /// Complete the `future` with given value.
    public func complete(value: Wrapped) {
        future.complete(value)
    }
}

/// Produces `ThrowingFuture`s that can be completed with a value or error at a later time.
public class ThrowingCompleter<Wrapped> {
    /// The `ThrowingFuture` that will be completed by this `ThrowingCompleter`.
    public let future = ThrowingFuture<Wrapped>()
    
    /// Create a new completer.
    public init() {}
    
    /// Create a new completer, and execute the given closure asynchronously using the completer.
    /// Errors thrown in the closure will be forwarded to the receving Future.
    public init(closure: (ThrowingCompleter<Wrapped>) throws -> ()) {
        dispatch_async(backgroundExecutionQueue) {
            do {
                try closure(self)
            } catch let e {
                self.completeWithError(e)
            }
        }
    }
    
    /// Complete the `future` with given value.
    public func complete(value: Wrapped) {
        future.complete(value)
    }
    
    /// Complete the `future` with given error.
    public func completeWithError(error: ErrorType) {
        future.handleError(error)
    }
}
