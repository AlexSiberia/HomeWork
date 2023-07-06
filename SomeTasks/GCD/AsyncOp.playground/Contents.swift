import UIKit

let queue = OperationQueue()

class AsyncOperation: Operation {
    private let lockQueue = DispatchQueue(label: "com.alexkurbatov", attributes: .concurrent)
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _isExecuting: Bool = false
    override private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _isFinished: Bool = false
    override private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override func start() {
        print("Starting")
        guard !isCancelled else {
            finish()
            return
        }
        isFinished = false
        isExecuting = true
        main()
    }
    
    override func main() {
        /// Use a dispatch after to mimic the scenario of a long-running task.
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute: {
            print("Executing")
            var image1 = UIImageView()
            let url = URL(string: "https://lgz.ru/upload/iblock/413/413c06c5f580aeaee2070d28dd823d27.jpg")
            image1.load(url: url!)
            self.finish()
        })
    }
    
    func finish() {
        isExecuting = false
        isFinished = true
    }
}

let operation = AsyncOperation()
queue.addOperations([operation], waitUntilFinished: true)
print("Operations finished")

extension UIImageView {
    func load(url: URL) {
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}



