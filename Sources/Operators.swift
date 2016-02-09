//
//  Operators.swift
//  When
//
//  Created by Robbert Brandsma on 09-02-16.
//  Copyright © 2016 PlanTeam. All rights reserved.
//

import Foundation

prefix operator !> {}

/// Wait until the given `Future` has completed and extract its value.
public prefix func !><Wrapped> (input: Future<Wrapped>) -> Wrapped {
    return input.await()
}

/// Wait until the given `ThrowingFuture` has completed and extract its value. May throw errors, so use with `try`.
public prefix func !><Wrapped> (input: ThrowingFuture<Wrapped>) throws -> Wrapped {
    return try input.safeAwait()
}