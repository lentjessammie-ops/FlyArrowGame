import SwiftUI
import StoreKit // <-- Импортируем для оценки приложения

struct SettingsView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @Environment(\.openURL) var openURL // <-- Для открытия ссылок
    
    @State private var isSoundOn = AudioManager.shared.isSoundEnabled
    @State private var isVibrationOn = AudioManager.shared.isVibrationEnabled
    @State private var isShowingShareSheet = false
    
    // --- ЗАМЕНИТЕ ЭТИ ДАННЫЕ НА СВОИ ---
    private let privacyPolicyURL = URL(string: "https://sites.google.com/view/fly-arrow-precision-archer/privacy-policy")!
    private let supportEmailURL = URL(string: "mailto:lentjessammie@gmail.com?subject=Fly%20Arrow%20Support")!
    private let appShareURL = URL(string: "https://apps.apple.com/app/id6755112777")! // Замените на ID вашего приложения
    private let shareText = "Check out this awesome game, Fly Arrow!"
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 20) {
                topHeader
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Секция основных настроек
                        VStack(spacing: 15) {
                            toggleRow(title: "Sound", isOn: $isSoundOn)
                                .onChange(of: isSoundOn) { newValue in
                                    AudioManager.shared.isSoundEnabled = newValue
                                    AudioManager.shared.saveSettings()
                                }
                            
                            toggleRow(title: "Vibration", isOn: $isVibrationOn)
                                .onChange(of: isVibrationOn) { newValue in
                                    AudioManager.shared.isVibrationEnabled = newValue
                                    AudioManager.shared.saveSettings()
                                }
                        }
                        
                        // Секция обратной связи и поддержки
                        VStack(spacing: 15) {
                            actionButton(title: "Rate App", action: rateApp)
                            actionButton(title: "Share App", action: shareApp)
                            actionButton(title: "How to Play", action: showOnboarding)
                        }
                        
                        // Секция информации
                        VStack(spacing: 15) {
                            actionButton(title: "Privacy Policy", action: openPrivacyPolicy)
                            actionButton(title: "Contact Support", action: openSupportEmail)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $isShowingShareSheet) {
            ActivityView(activityItems: [shareText, appShareURL])
        }
    }
    
    // MARK: - Actions
    
    private func openPrivacyPolicy() {
        openURL(privacyPolicyURL)
    }
    
    private func openSupportEmail() {
        openURL(supportEmailURL)
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func shareApp() {
        isShowingShareSheet = true
    }
    
    private func showOnboarding() {
        coordinator.showOnboarding()
    }
    
    //MARK: - UI Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 168/255, green: 217/255, blue: 255/255),
                Color(red: 128/255, green: 197/255, blue: 255/255)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var topHeader: some View {
        HStack {
            Button(action: { coordinator.showMainScreen() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .clipShape(Circle())
            }
            Spacer()
            Text("Settings")
                .font(.custom("FascinateInline-Regular", size: 48))
                .foregroundColor(.white)
            Spacer()
            Circle().fill(Color.clear).frame(width: 50, height: 50)
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }
    
    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(title)
                .font(.custom("MuseoModerno", size: 20))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0/255, green: 122/255, blue: 255/255))
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(.green)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.35))
        )
    }
    
    private func actionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            AudioManager.shared.playSoundEffect(named: "ui_click", extension: "mp3")
            action()
        }) {
            HStack {
                Text(title)
                    .font(.custom("MuseoModerno", size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0/255, green: 122/255, blue: 255/255))
                Spacer()
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.35))
            )
        }
    }
}

//MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(NavigationCoordinator())
    }
}


struct ActivityView: UIViewControllerRepresentable {
    
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
