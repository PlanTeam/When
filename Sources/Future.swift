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
    
    private final var value: Wrapped?
    private final var closures = [FutureCallback]()
    
    private final func complete(value: Wrapped) {
        dispatch_sync(futureManipulationQueue) { self.value = value }
        for c in closures {
            c(value)
        }
    }
    
    public func await() -> Wrapped {
        while value == nil { usleep(1) }
        return value!
    }
    
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
    
    public init(execute closure: () -> (Wrapped)) {
        dispatch_async(backgroundExecutionQueue) {
            self.complete(closure())
        }
    }
    
    private init() {}
}

public final class ThrowingFuture<Wrapped> : Future<Wrapped> {
    typealias ErrorCallback = (ErrorType) -> ()
    
    private var error: ErrorType?
    private var errorClosures = [ErrorCallback]()
    
    public override func await() -> Wrapped {
        return try! safeAwait()
    }
    
    public func safeAwait() throws -> Wrapped {
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
    
    private func handleError(error: ErrorType) {
        dispatch_sync(futureManipulationQueue) { self.error = error }
        
        for c in errorClosures {
            c(error)
        }
    }
    
    deinit {
        if let error = error where errorClosures.count == 0 {
            // Crash if an error wasn't handled!
            print("An error was not handled in a ThrowingFuture of type \(self.dynamicType). You should provide error handling logic.")
            try! { throw error }()
        }
    }
}