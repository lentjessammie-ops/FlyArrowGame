import SwiftUI

enum Screen {
    case main, levelSelect, game, settings, shop, inventory, onboarding
    
}

class NavigationCoordinator: ObservableObject {
    @Published var currentScreen: Screen
    @Published var currentLevel: Int = 1
    
    private let onboardingKey = "hasCompletedOnboarding"
    
    init() {
        if UserDefaults.standard.bool(forKey: onboardingKey) {
            self.currentScreen = .main
        } else {
            self.currentScreen = .onboarding
        }
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: onboardingKey)
        showMainScreen()
    }
    
    
    func showShop() {
        currentScreen = .shop
    }
    
    func showInventory() {
        currentScreen = .inventory
    }
    
    func showMainScreen() {
        currentScreen = .main
    }
    
    func showLevelSelect() {
        currentScreen = .levelSelect
    }
    
    func showSettings() {
        currentScreen = .settings
    }
    
    func startGame(level: Int) {
        currentLevel = level
        currentScreen = .game
    }
    
    func goToNextLevel() {
        if let _ = LevelManager.getLevel(by: currentLevel + 1) {
            currentLevel += 1
        } else {
            showLevelSelect()
        }
    }
    
    func showOnboarding() {
           currentScreen = .onboarding
       }
}

