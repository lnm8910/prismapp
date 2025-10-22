// Sample Rust code for testing syntax highlighting

use std::fmt;

// Struct definition
struct HelloWorld {
    message: String,
    count: u32,
}

impl HelloWorld {
    // Constructor
    fn new(message: &str) -> Self {
        HelloWorld {
            message: message.to_string(),
            count: 0,
        }
    }

    // Method
    fn greet(&mut self) {
        println!("{}", self.message);
        self.count += 1;
    }

    fn greet_multiple(&mut self, times: u32) {
        for i in 0..times {
            println!("{}: {}", i + 1, self.message);
        }
    }
}

// Trait definition
trait Printable {
    fn print_description(&self);
}

impl Printable for HelloWorld {
    fn print_description(&self) {
        println!("HelloWorld with message: {}", self.message);
    }
}

// Enum
enum Status {
    Active,
    Inactive,
    Pending,
}

// Function
fn add(a: i32, b: i32) -> i32 {
    a + b
}

// Main function
fn main() {
    let mut hello = HelloWorld::new("Hello, Prism!");
    hello.greet();
    hello.greet_multiple(3);

    let sum = add(5, 7);
    println!("Sum: {}", sum);

    let status = Status::Active;
    match status {
        Status::Active => println!("Active"),
        Status::Inactive => println!("Inactive"),
        Status::Pending => println!("Pending"),
    }
}
