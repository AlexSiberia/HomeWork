import UIKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

let queue1 = DispatchQueue.global(qos: .userInitiated)
let queue2 = DispatchQueue.global(qos: .background)

let group1 = DispatchGroup()
let group2 = DispatchGroup()

queue1.async(group: group1) {
    group1.enter()
    
    defer {
        group1.leave()
        print("Group 1 worked.\(__dispatch_queue_get_label(nil))")
    }
    print("Group 1 working.")
    
    Thread.sleep(forTimeInterval: 2)
    
}

group1.notify(queue: queue2) {
    group2.enter()
    
    defer {
        group2.leave()
        print("Group 2 worked.\(__dispatch_queue_get_label(nil))")
    }
    print("Group 2 working.")
    
    Thread.sleep(forTimeInterval: 2)
    
}

group1.wait()
//PlaygroundPage.current.finishExecution()
print(__dispatch_queue_get_label(nil))
