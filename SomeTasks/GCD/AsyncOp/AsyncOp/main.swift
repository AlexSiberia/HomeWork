//
//  main.swift
//  AsyncOp
//
//  Created by Alexander Kurbatov on 01.07.2023.
//

import Foundation

class AsyncOperation: Operation {
    override var isAsynchronous: Bool {
        return true
    }

    override func main() {
        /// Use a dispatch after to mimic the scenario of a long-running task.
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: {
            print("Executing")
        })
    }
}
