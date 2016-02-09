//
//  Completer.swift
//  When
//
//  Created by Robbert Brandsma on 09-02-16.
//  Copyright © 2016 PlanTeam. All rights reserved.
//

import Foundation

public class Completer<Wrapped> {
    public let future = Future<Wrapped>()
    public init() {}
    public func complete(value: Wrapped) {
        future.complete(value)
    }
}

public class ThrowingCompleter<Wrapped> {
    public let future = ThrowingFuture<Wrapped>()
    public init() {}
    public func complete(value: Wrapped) {
        future.complete(value)
    }
    public func completeWithError(error: ErrorType) {
        future.handleError(error)
    }
}
