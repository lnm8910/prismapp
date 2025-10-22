# Sample Python code for testing syntax highlighting

class HelloWorld:
    """A simple class for greeting."""

    def __init__(self, message="Hello, Prism!"):
        self.message = message
        self.count = 0

    def greet(self):
        """Print the greeting message."""
        print(self.message)
        self.count += 1

    async def greet_async(self):
        """Asynchronous greeting."""
        import asyncio
        await asyncio.sleep(0.1)
        print(self.message)

    def greet_multiple(self, times):
        """Print greeting multiple times."""
        for i in range(times):
            print(f"{i + 1}: {self.message}")

# Function definition
def add(a, b):
    """Add two numbers."""
    return a + b

# List comprehension
numbers = [1, 2, 3, 4, 5]
doubled = [n * 2 for n in numbers]
evens = [n for n in numbers if n % 2 == 0]

# Dictionary
config = {
    "name": "Prism",
    "version": "0.1.0",
    "enabled": True,
    "count": 42
}

# Main execution
if __name__ == "__main__":
    hello = HelloWorld()
    hello.greet()
    hello.greet_multiple(3)
    print(f"Greeted {hello.count} times")
