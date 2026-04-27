import Foundation

// Test the stream fix
var chatStream: String? = nil

// Simulate multiple delta events
let deltas = ["Hello", " world", "!"]

for delta in deltas {
    // This is the fixed logic: chatStream = (chatStream ?? "") + delta
    chatStream = (chatStream ?? "") + delta
    print("After delta '\(delta)': \(chatStream ?? "")")
}

print("Final result: \(chatStream ?? "")")
// Expected: "Hello world!"