import SwiftUI

struct LoadingErrorView: View {
    let error: Error
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)

            Text("Couldn’t load markets").font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry", action: onRetry)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .listRowSeparator(.hidden)
    }
}
#Preview {
    LoadingErrorView(
        error: NSError(domain: "Sample", code: -1, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])) {
        }
}

