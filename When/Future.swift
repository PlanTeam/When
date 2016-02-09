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

public class Future<Wrapped> {
    typealias FutureCallback = (Wrapped) -> ()
    
    private var value: Wrapped?
    private var closures = [FutureCallback]()
    
    public func complete(value: Wrapped) {
        dispatch_sync(futureManipulationQueue) { self.value = value }
        for c in closures {
            c(value)
        }
    }
    
    public func await() -> Wrapped {
        while value == nil { usleep(1) }
        return value!
    }
    
    public func then(closure: (Wrapped) -> ()) {
        dispatch_async(futureManipulationQueue) {
            if let value = self.value {
                closure(value)
            } else {
                self.closures.append(closure)
            }
        }
    }
    
    public init(execute closure: () -> (Wrapped)) {
        dispatch_async(backgroundExecutionQueue) {
            self.complete(closure())
        }
    }
}

prefix operator !> {}
prefix func !><Wrapped> (input: Future<Wrapped>) -> Wrapped {
    return input.await()
}