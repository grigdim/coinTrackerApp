import SwiftUI

struct ExpandableTextView: View {
    @State private var isExpanded = false

    let title: String
    let description: String?

    private var hasDescription: Bool {
        if let description {
            return !description.trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
        }
        return false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About \(title)")
                .font(.headline)

            if hasDescription {
                Text(description ?? "")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(isExpanded ? nil : 3)
                    .fixedSize(horizontal: false, vertical: true)
                    .animation(.easeInOut, value: isExpanded)

                Button {
                    withAnimation(.easeInOut) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(isExpanded ? "Read less" : "Read more")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Image(systemName: "chevron.down")
                            .font(.subheadline.weight(.semibold))
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                            .animation(.easeInOut, value: isExpanded)
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
                .accessibilityLabel(
                    isExpanded ? "Collapse description" : "Expand description"
                )

            } else {
                Text("No description available.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ExpandableTextView(
        title: "Bitcoin",
        description: """
            Bitcoin is a decentralized digital currency that operates without a central authority or intermediary.
            It enables peer-to-peer transactions secured by cryptography and recorded on a public, immutable ledger
            known as the blockchain.

            Created in 2009, Bitcoin introduced the concept of scarce digital money and remains the largest and most
            widely adopted cryptocurrency by market capitalization.
            """
    )
    .padding()
}
