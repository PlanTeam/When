//
//  Autoclosure.swift
//  When
//
//  Created by Robbert Brandsma on 09-02-16.
//  Copyright © 2016 PlanTeam. All rights reserved.
//

import Foundation

extension Future {
    // needed because the compiler gets mad when we try to use the trailing closure syntax if we only have an initializer accepting @autoclosure(escaping)
    public convenience init(@autoclosure(escaping) execute closure: () -> (Wrapped)) {
        self.init(execute: closure)
    }
    
}

extension ThrowingFuture {
    public convenience init(@autoclosure(escaping) executeThrowing closure: () throws -> (Wrapped)) {
        self.init(executeThrowing: closure)
    }
}