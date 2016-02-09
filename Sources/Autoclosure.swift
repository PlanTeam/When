//
//  Autoclosure.swift
//  When
//
//  Created by Robbert Brandsma on 09-02-16.
//  Copyright © 2016 PlanTeam. All rights reserved.
//

import Foundation

extension Future {
    /// Initialize a new future and execute the given closure. The closure is executed asynchronously on a special dispatch queue.
    // needed because the compiler gets mad when we try to use the trailing closure syntax if we only have an initializer accepting @autoclosure(escaping)
    public convenience init(@autoclosure(escaping) execute closure: () -> (Wrapped)) {
        self.init(execute: closure)
    }
    
}

extension ThrowingFuture {
    /// Initialize a new future and execute the given closure. The closure is executed asynchronously on a special dispatch queue.
    public convenience init(@autoclosure(escaping) executeThrowing closure: () throws -> (Wrapped)) {
        self.init(executeThrowing: closure)
    }
}