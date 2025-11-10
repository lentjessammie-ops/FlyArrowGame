import SwiftUI

struct CoordinatorView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var gameDataManager: GameDataManager
    
    var body: some View {
        ZStack {
            switch coordinator.currentScreen {
            case .onboarding: 
                OnboardingView()
                    .transition(.opacity.animation(.easeInOut))
            case .main:
                MainView()
                    .transition(.opacity.animation(.easeInOut))
                
            case .levelSelect:
                LevelSelectView()
                    .transition(.opacity.animation(.easeInOut))
                
            case .game:
                GameView(levelNumber: coordinator.currentLevel, gameDataManager: gameDataManager)
                    .id(coordinator.currentLevel) 
                    .transition(.opacity.animation(.easeInOut))
                
            case .settings:
                SettingsView()
                    .transition(.opacity.animation(.easeInOut))
                
            case .shop:
                ShopView(mode: .shop)
                    .transition(.opacity.animation(.easeInOut))
                
            case .inventory:
                ShopView(mode: .inventory)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
    }
}

