import SwiftUI
import SpriteKit

//MARK:- ViewModel / Coordinator
class GameViewModel: ObservableObject {
    @Published var applesCollectedInLevel: Int = 0
    @Published var showLevelCompleteView: Bool = false
    @Published var showLevelFailedView: Bool = false
    @Published var pathProgress: CGFloat = 0.0
    @Published var failureReason: String = ""
    
    let scene: GameScene
    let levelNumber: Int

    init(levelNumber: Int, dataManager: GameDataManager) {
        self.levelNumber = levelNumber
        guard let levelData = LevelManager.getLevel(by: levelNumber) else {
            fatalError("Level data not found for level: \(levelNumber)")
        }
        
        self.scene = GameScene(
            size: UIScreen.main.bounds.size,
            levelData: levelData,
            bow: dataManager.selectedBowAssetName,
            arrow: dataManager.selectedArrowAssetName,
            line: dataManager.selectedLineColor
        )
        
        scene.scaleMode = .resizeFill
        scene.gameLogicDelegate = self
    }
    
    func resetGame() {
        applesCollectedInLevel = 0
        showLevelCompleteView = false
        showLevelFailedView = false
        pathProgress = 0.0
        failureReason = ""
        scene.resetLevel()
    }
}

extension GameViewModel: GameLogicDelegate {
    func pathLengthUpdated(progress: CGFloat) {
        DispatchQueue.main.async { self.pathProgress = progress }
    }
    func appleCollected() {
        DispatchQueue.main.async { self.applesCollectedInLevel += 1 }
    }
    func levelCompleted() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.showLevelCompleteView = true }
    }
    func levelFailed(reason: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.failureReason = reason
            self.showLevelFailedView = true
        }
    }
}


//MARK: - GameView
struct GameView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    @StateObject private var viewModel: GameViewModel

    init(levelNumber: Int, gameDataManager: GameDataManager) {
        _viewModel = StateObject(wrappedValue: GameViewModel(levelNumber: levelNumber, dataManager: gameDataManager))
    }

    var body: some View {
        ZStack {
            SpriteView(scene: viewModel.scene)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                GameHeaderView(
                    levelNumber: viewModel.levelNumber,
                    applesCollected: $viewModel.applesCollectedInLevel,
                    pathProgress: $viewModel.pathProgress,
                    onBack: { coordinator.showLevelSelect() }
                )
                Spacer()
            }
            
            if viewModel.showLevelCompleteView {
                LevelCompleteView(
                    applesCollected: viewModel.applesCollectedInLevel,
                    onHome: { coordinator.showMainScreen() },
                    onNextLevel: { handleNextLevel() },
                    onRetry: { viewModel.resetGame() }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                .zIndex(1)
            }
            
            if viewModel.showLevelFailedView {
                LevelFailedView(
                    reason: viewModel.failureReason,
                    onTryAgain: { viewModel.resetGame() }
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.resetGame()
        }
    }
    
    private func handleNextLevel() {
        gameDataManager.completeLevel(viewModel.levelNumber, applesCollected: viewModel.applesCollectedInLevel)
        coordinator.goToNextLevel()
    }
}


//MARK: - UI Components
struct GameHeaderView: View {
    let levelNumber: Int
    @Binding var applesCollected: Int
    @Binding var pathProgress: CGFloat
    var onBack: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .bold))
                    .padding(10)
                    .background(Color.white.opacity(0.35))
                    .clipShape(Circle())
            }
            .simultaneousGesture(TapGesture().onEnded {
                AudioManager.shared.playSoundEffect(named: "ui_click")
            })
            
            levelLabel

            pathProgressBar
            
            appleCounter
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .padding(.top, 0)
    }
    
    private var levelLabel: some View {
        Text("L\(levelNumber)")
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .padding(.horizontal, 15).padding(.vertical, 6)
            .background(Color.white.opacity(0.35))
            .clipShape(Capsule())
    }
    
    private var pathProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 10)
                
                Capsule()
                    .fill(Color.green)
                    .frame(height: 10)
                    .frame(width: geometry.size.width * pathProgress)
            }
        }
        .frame(height: 10)
    }
    
    private var appleCounter: some View {
        HStack(spacing: 5) {
            Text("\(applesCollected)/3")
                .font(.system(size: 16, weight: .bold, design: .rounded))
            Image("apple_filled")
                .resizable().scaledToFit().frame(width: 22, height: 22)
        }
        .padding(.horizontal, 15).padding(.vertical, 6)
        .background(Color.white.opacity(0.35))
        .clipShape(Capsule())
    }
}

struct LevelCompleteView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    
    let applesCollected: Int
    var onHome: () -> Void
    var onNextLevel: () -> Void
    var onRetry: () -> Void
    
    var totalReward: Int {
        gameDataManager.baseLevelReward + (gameDataManager.appleBonus * applesCollected)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Level Completed!")
                    .font(.custom("FascinateInline-Regular", size: 40))
                    .foregroundColor(Color(red: 80/255, green: 227/255, blue: 194/255))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                HStack(spacing: 15) {
                    ForEach(0..<3) { index in
                        appleRewardCard(isCollected: index < applesCollected)
                    }
                }
                
                HStack {
                    Text("Total:")
                        .font(.custom("MuseoModerno", size: 24))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("+\(totalReward) apples")
                        .font(.custom("MuseoModerno", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .padding(.horizontal)
                
                HStack(spacing: 10) {
                    Button(action: onHome) {
                        Text("Home")
                            .font(.custom("MuseoModerno", size: 16))
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.4))
                            .cornerRadius(20)
                    }
                    
                    Button(action: onRetry) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20, weight: .bold))
                            .padding()
                            .background(Color.blue.opacity(0.7))
                            .clipShape(Circle())
                    }
                    
                    Button(action: onNextLevel) {
                        Text("Next Level")
                            .font(.custom("MuseoModerno", size: 16))
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(20)
                    }
                }
                .foregroundColor(.white)
            }
            .padding(30)
            .background(Color(red: 220/255, green: 240/255, blue: 255/255))
            .cornerRadius(30)
            .shadow(radius: 20)
            .padding(.horizontal, 20)
        }
    }
    
    private func appleRewardCard(isCollected: Bool) -> some View {
        VStack {
            Image("apple_filled")
                .resizable().scaledToFit().frame(width: 40, height: 40)
            Text("+\(gameDataManager.appleBonus)")
                .font(.custom("MuseoModerno", size: 18))
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .opacity(isCollected ? 1.0 : 0.4)
    }
}

struct LevelFailedView: View {
    let reason: String
    var onTryAgain: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            VStack(spacing: 15) {
                Text("Level Failed")
                    .font(.custom("FascinateInline-Regular", size: 50))
                    .foregroundColor(.white)
                
                Text(reason)
                    .font(.custom("MuseoModerno", size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                
                Button(action: onTryAgain) {
                    Text("Try Again")
                        .font(.custom("MuseoModerno", size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(25)
                }
            }
            .padding(40)
            .background(Color.red.opacity(0.8))
            .cornerRadius(30)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
    }
}

//MARK: - Preview Provider

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        let gameDataManager = GameDataManager()
        return GameView(levelNumber: 1, gameDataManager: gameDataManager)
            .environmentObject(gameDataManager)
            .environmentObject(NavigationCoordinator())
    }
}
