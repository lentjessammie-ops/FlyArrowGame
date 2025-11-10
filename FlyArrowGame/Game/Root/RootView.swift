//
//  RootView.swift
//  FlyArrowGame
//
//  Created by D K on 07.11.2025.
//

import SwiftUI

struct RootView: View {
    
    @StateObject private var gameDataManager = GameDataManager()
    @StateObject private var coordinator = NavigationCoordinator()
    
    init() {
            AudioManager.shared.playBackgroundMusic()
        }
    
    var body: some View {
        CoordinatorView()
   
            .environmentObject(gameDataManager)
            .environmentObject(coordinator)
    }
}

#Preview {
    RootView()
}
