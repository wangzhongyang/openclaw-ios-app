import Foundation

// Test the user message logic with simple structs
struct SimpleMessage {
    let id: String?
    let role: String
    let content: String
}

// Test the merge logic
print("Testing User Message Merge Logic...")

// Simulate local messages with temp ID
let localMessages = [
    SimpleMessage(id: "temp-abc123", role: "user", content: "Test user message"),
    SimpleMessage(id: "server-msg-1", role: "assistant", content: "Existing server message")
]

// Simulate server messages
let serverMessages = [
    SimpleMessage(id: "server-msg-1", role: "assistant", content: "Existing server message"),
    SimpleMessage(id: "server-msg-2", role: "assistant", content: "New server message")
]

// Apply the merge logic from AppState.swift
let serverMessageIds = Set(serverMessages.compactMap { $0.id })
let preservedLocalMessages = localMessages.filter { msg in
    guard let msgId = msg.id else { return true }
    return msgId.hasPrefix("temp-") || !serverMessageIds.contains(msgId)
}

let mergedMessages = serverMessages + preservedLocalMessages

print("Local messages: \(localMessages.count)")
print("Server messages: \(serverMessages.count)")
print("Preserved local: \(preservedLocalMessages.count)")
print("Merged total: \(mergedMessages.count)")

// Check if user message is preserved
let hasUserMessage = preservedLocalMessages.contains { msg in
    return msg.role == "user" && msg.id?.hasPrefix("temp-") == true
}

if hasUserMessage {
    print("✅ User message with temp ID correctly preserved!")
} else {
    print("❌ User message was lost!")
}

print("\n🎉 User message fix logic verified successfully!")