import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack {
                Text("Welcome to Fly Arrow!")
                    .font(.custom("FascinateInline-Regular", size: 40))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        imageName: "line_preview", // Показываем, как рисовать линию
                        title: "Draw to Shoot",
                        description: "Simply draw a path on the screen with your finger to aim your arrow."
                    ).tag(0)
                    
                    OnboardingPageView(
                        imageName: "ring", // Показываем главную цель - кольцо
                        title: "Pass Through Rings",
                        description: "Your arrow MUST pass through all the green rings to complete the level."
                    ).tag(1)
                    
                    OnboardingPageView(
                        imageName: "apple_filled", // Показываем награду - яблоко
                        title: "Grab Apples",
                        description: "Collect apples along the way to spend them in the shop for new bows and lines."
                    ).tag(2)
                    
                    OnboardingPageView(
                        imageName: "wall_left", // Показываем одно из препятствий
                        title: "Watch Out!",
                        description: "Avoid hitting walls and be careful of the wind, it can blow your arrow off course!"
                    ).tag(3)
                    
                    OnboardingPageView(
                        imageName: "playButton", // Используем иконку кнопки Play, так как она круглая и большая
                        title: "Let's Play!",
                        description: "You are all set. Good luck and have fun solving the puzzles!"
                    ).tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                if currentPage == 4 {
                    Button(action: {
                        AudioManager.shared.playSoundEffect(named: "ui_click", extension: "mp3")
                        coordinator.completeOnboarding()
                    }) {
                        Text("Start Game")
                            .font(.custom("MuseoModerno", size: 24))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(25)
                            .shadow(radius: 10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                } else {
                    // Пустое пространство, чтобы таб-индикатор был на одном уровне
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 120) // Высота кнопки + отступы
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
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
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 30) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 150) // Уменьшил высоту, чтобы лучше помещалось
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
            
            VStack(spacing: 15) {
                Text(title)
                    .font(.custom("FascinateInline-Regular", size: 32))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.custom("MuseoModerno", size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(NavigationCoordinator())
    }
}
