// Sample JavaScript code for testing syntax highlighting

class HelloWorld {
    constructor(message = "Hello, Prism!") {
        this.message = message;
        this.count = 0;
    }

    greet() {
        console.log(this.message);
        this.count++;
    }

    async greetAsync() {
        await new Promise(resolve => setTimeout(resolve, 100));
        console.log(this.message);
    }

    greetMultiple(times) {
        for (let i = 0; i < times; i++) {
            console.log(`${i + 1}: ${this.message}`);
        }
    }
}

// Arrow function
const add = (a, b) => a + b;

// Template literal
const formatMessage = (name) => `Hello, ${name}!`;

// Object destructuring
const { message } = new HelloWorld();

// Array methods
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(n => n * 2);
const sum = numbers.reduce((acc, n) => acc + n, 0);

// Export
export default HelloWorld;
export { add, formatMessage };
