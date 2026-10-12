import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.black, .indigo.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.cyan)
                    Text("Dinh Duc Nam")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text("0395109314 - 0332011756")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("FFKernelCheat — Personal Build")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("About")
        }
    }
}
