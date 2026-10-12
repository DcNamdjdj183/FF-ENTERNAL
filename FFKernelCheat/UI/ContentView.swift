import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @EnvironmentObject var kernel: KernelManager

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation { showSplash = false }
                        }
                    }
            } else {
                TabView {
                    HomeView()
                        .tabItem { Label("Home", systemImage: "house.fill") }
                    FeaturesView()
                        .tabItem { Label("Features", systemImage: "slider.horizontal.3") }
                    LogsView()
                        .tabItem { Label("Logs", systemImage: "terminal.fill") }
                    SettingsView()
                        .tabItem { Label("Settings", systemImage: "gear") }
                    AboutView()
                        .tabItem { Label("About", systemImage: "info.circle") }
                }
                .accentColor(.cyan)
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .purple.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "cpu")
                    .font(.system(size: 80))
                    .foregroundStyle(.cyan)
                Text("FFKernelCheat")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("Developer: Dinh Duc Nam")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text("0395109314 - 0332011756")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
}

extension View {
    @ViewBuilder
    func hideScrollContentBackground() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self
        }
    }
}
