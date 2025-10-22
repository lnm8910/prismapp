import Foundation

// Sample Swift code for testing syntax highlighting
class HelloWorld {
    let message: String = "Hello, Prism!"
    var count: Int = 0

    func greet() {
        print(message)
        count += 1
    }

    func greetMultiple(times: Int) {
        for i in 0..<times {
            print("\(i + 1): \(message)")
        }
    }
}

// Protocol definition
protocol Printable {
    func printDescription()
}

// Extension
extension HelloWorld: Printable {
    func printDescription() {
        print("HelloWorld with message: \(message)")
    }
}

// Enum
enum Status {
    case active
    case inactive
    case pending
}

// Test usage
let hello = HelloWorld()
hello.greet()
hello.greetMultiple(times: 3)
