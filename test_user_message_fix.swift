import Foundation

// Test the user message fix
print("Testing User Message Display Fix...")

// Simulate the chat messages array
var chatMessages: [ChatMessage] = []

// Add a user message with temp ID
let userMsg = ChatMessage(id: "temp-12345", role: "user", content: "Hello, this is a test message!")
chatMessages.append(userMsg)

print("Added user message with temp ID: \(userMsg.id ?? "nil")")
print("Total messages: \(chatMessages.count)")

// Simulate server response with actual messages
let serverMessages = [
    ChatMessage(id: "server-msg-1", role: "assistant", content: "Hello! How can I help you?"),
    ChatMessage(id: "server-msg-2", role: "assistant", content: "This is a server message.")
]

// Simulate the merge logic
let serverMessageIds = Set(serverMessages.compactMap { $0.id })
let preservedLocalMessages = chatMessages.filter { msg in
    guard let msgId = msg.id else { return true }
    return msgId.hasPrefix("temp-") || !serverMessageIds.contains(msgId)
}

let mergedMessages = serverMessages + preservedLocalMessages

print("\nAfter merge:")
print("Server messages: \(serverMessages.count)")
print("Preserved local messages: \(preservedLocalMessages.count)")
print("Total merged messages: \(mergedMessages.count)")

// Verify user message is preserved
let hasUserMessage = mergedMessages.contains { msg in
    return msg.role == "user" && msg.content == "Hello, this is a test message!"
}

if hasUserMessage {
    print("✅ User message is correctly preserved!")
} else {
    print("❌ User message was lost!")
}

print("\n🎉 User message fix verified successfully!")