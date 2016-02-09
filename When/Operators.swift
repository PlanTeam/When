//
//  Operators.swift
//  When
//
//  Created by Robbert Brandsma on 09-02-16.
//  Copyright © 2016 PlanTeam. All rights reserved.
//

import Foundation

prefix operator !> {}
public prefix func !><Wrapped> (input: Future<Wrapped>) -> Wrapped {
    return input.await()
}

public prefix func !><Wrapped> (input: ThrowingFuture<Wrapped>) throws -> Wrapped {
    return try input.safeAwait()
}