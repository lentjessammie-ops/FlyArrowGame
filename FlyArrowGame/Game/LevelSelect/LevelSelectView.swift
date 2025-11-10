

import SwiftUI

//MARK: - LevelSelectView

struct LevelSelectView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let totalLevelsToShow = 100
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    //MARK: - Body
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 20) {
                topHeader
                progressBar
                levelsGrid
            }
            .padding(.horizontal)
            
            if showAlert {
                LockedLevelView(message: alertMessage, isPresented: $showAlert)
                    .transition(.opacity.animation(.easeInOut))
                    .zIndex(2)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
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
            Button(action: {
                coordinator.showMainScreen()
            }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .clipShape(Circle())
            }
            .simultaneousGesture(TapGesture().onEnded {
                AudioManager.shared.playSoundEffect(named: "ui_click")
            })
            Spacer()
            Text("Levels")
                .font(.custom("FascinateInline-Regular", size: 48))
                .foregroundColor(.white)
            Spacer()
            Circle().fill(Color.clear).frame(width: 50, height: 50)
        }
        .padding(.top, 40)
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.3)).frame(height: 30)
                Capsule().fill(Color.blue)
                    .frame(height: 30)
                    .frame(width: geometry.size.width * (CGFloat(gameDataManager.highestUnlockedLevel - 1) / CGFloat(totalLevelsToShow)))
                Text("progress: \(gameDataManager.highestUnlockedLevel - 1)/\(totalLevelsToShow)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.leading, 15)
            }
        }
        .frame(height: 30)
    }
    
    private var levelsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(1...totalLevelsToShow, id: \.self) { levelNumber in
                    levelButton(for: levelNumber)
                }
            }
            .padding(.top)
        }
        .scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    private func levelButton(for levelNumber: Int) -> some View {
        let isUnlocked = gameDataManager.isLevelUnlocked(levelNumber)
        let isAvailable = LevelManager.getLevel(by: levelNumber) != nil
        
        Button(action: {
            if isUnlocked && isAvailable {
                coordinator.startGame(level: levelNumber)
            } else {
                handleLockedLevelTap(levelNumber: levelNumber)
            }
        }) {
            levelCell(for: levelNumber, isUnlocked: isUnlocked, isPassed: levelNumber < gameDataManager.highestUnlockedLevel)
        }
    }
    
    private func levelCell(for levelNumber: Int, isUnlocked: Bool, isPassed: Bool) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(gradientForState(isUnlocked: isUnlocked, isPassed: isPassed))
                    .overlay(
                        // Имитация внутреннего свечения (inner shadow)
                        Circle()
                            .fill(Color.white.opacity(0.44))
                            .blur(radius: 4)
                            .offset(x: 0, y: 4)
                            .clipShape(Circle()) // Обрезаем свечение по форме круга
                    )
                    .clipShape(Circle()) // Обрезаем основной круг, чтобы оверлей не вылезал
                
                Text("\(levelNumber)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(textColorForState(isUnlocked: isUnlocked))
            }
            .aspectRatio(1, contentMode: .fit)
            .shadow(color: .black.opacity(0.2), radius: 5, y: 5) // Внешняя тень
            
            appleIndicatorView(for: levelNumber, isUnlocked: isUnlocked)
        }
    }

    private func appleIndicatorView(for levelNumber: Int, isUnlocked: Bool) -> some View {
        HStack(spacing: 5) {
            ForEach(1...3, id: \.self) { index in
                Image(systemName: "apple.logo")
                    .foregroundColor(index <= gameDataManager.getApplesForLevel(levelNumber) ? .red : .gray.opacity(0.6))
                    .font(.system(size: 18))
                    .opacity(isUnlocked ? 1.0 : 0.5)
            }
        }
    }
    
    private func handleLockedLevelTap(levelNumber: Int) {
        if levelNumber > 10 && gameDataManager.highestUnlockedLevel > 10 {
            if gameDataManager.didCollectAllApples() {
                alertMessage = "New levels are coming soon! Great job collecting all the apples!"
            } else {
                alertMessage = "To unlock new worlds, please collect all 3 apples on every previous level."
            }
        } else {
            alertMessage = "You must complete the previous levels to unlock this one."
        }
        showAlert = true
    }

    //MARK: - Helper Methods

    private func gradientForState(isUnlocked: Bool, isPassed: Bool) -> LinearGradient {
        let gradient: Gradient
        if isPassed {
            gradient = Gradient(colors: [Color(hex: "#66D98C"), Color(hex: "#36C39E")])
        } else if isUnlocked {
            gradient = Gradient(colors: [Color(hex: "#FFCE7F"), Color(hex: "#FFB031")])
        } else {
            gradient = Gradient(colors: [Color(hex: "#A0A0A0").opacity(0.4), Color(hex: "#808080").opacity(0.4)])
        }
        return LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
    }
    
    private func textColorForState(isUnlocked: Bool) -> Color {
        isUnlocked ? .white : Color.white.opacity(0.5)
    }
}


//MARK: - Color Extension for HEX
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
