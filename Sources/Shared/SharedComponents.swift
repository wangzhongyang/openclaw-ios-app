import SwiftUI

// MARK: - DetailRow

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}

// MARK: - StatusIndicator

struct StatusIndicator: View {
    let text: String
    let active: Bool

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(active ? .green : .gray)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption2)
        }
    }
}

// MARK: - LoadingView

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ErrorBanner

struct ErrorBanner: View {
    let message: String
    let onDismiss: (() -> Void)?

    init(_ message: String, onDismiss: (() -> Void)? = nil) {
        self.message = message
        self.onDismiss = onDismiss
    }

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.caption)
            Spacer()
            if let onDismiss {
                Button("Dismiss", action: onDismiss)
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - SearchBar (uses .searchable modifier)

// MARK: - Extensions

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
