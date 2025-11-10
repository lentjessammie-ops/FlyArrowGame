import SwiftUI

struct MainView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var gameDataManager: GameDataManager

    //MARK: - Body

    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                Spacer()
                gameTitle
                Spacer()
                
                Button(action: {
                    coordinator.showLevelSelect()
                }) {
                    playButtonContent
                }
                .simultaneousGesture(TapGesture().onEnded {
                    AudioManager.shared.playSoundEffect(named: "ui_click")
                })
                
                levelProgressText
                Spacer()
                Spacer()
                bottomToolbar
            }
            .padding(.horizontal, 20)
        }
        .edgesIgnoringSafeArea(.all)
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

    private var gameTitle: some View {
        VStack {
            Text("FLY")
            Text("ARROW")
        }
        .font(.custom("FascinateInline-Regular", size: 80))
        .foregroundColor(.white)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
    }

    private var playButtonContent: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 255/255, green: 201/255, blue: 71/255),
                            Color(red: 255/255, green: 170/255, blue: 51/255)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 220, height: 220)
                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 8)

            Text("Play")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
    
    private var levelProgressText: some View {
        Text("Levels \(gameDataManager.highestUnlockedLevel) of 100")
            .font(.custom("MuseoModerno", size: 18))
            .fontWeight(.medium)
            .foregroundColor(.white.opacity(0.9))
            .padding(.top, 20)
    }
    
    private var bottomToolbar: some View {
            HStack {
                Button(action: { coordinator.showInventory() }) {
                    Image("icon_bow_selection")
                        .resizable().scaledToFit().frame(width: 35, height: 35)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    AudioManager.shared.playSoundEffect(named: "ui_click")
                })
                Spacer()
                Button(action: { coordinator.showShop() }) {
                    Image("icon_shop")
                        .resizable().scaledToFit().frame(width: 35, height: 35)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    AudioManager.shared.playSoundEffect(named: "ui_click")
                })
                Spacer()
                Button(action: { coordinator.showSettings() }) {
                    Image("icon_settings")
                        .resizable().scaledToFit().frame(width: 35, height: 35)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    AudioManager.shared.playSoundEffect(named: "ui_click")
                })
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 50) // Увеличил отступы для лучшего распределения
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
            )
            .padding(.bottom, 20)
            .foregroundColor(Color(red: 104/255, green: 180/255, blue: 248/255))
        }
    
    private var appleCounter: some View {
        HStack(spacing: 5) {
            Image("apple_filled")
                .resizable().scaledToFit().frame(width: 22, height: 22)
            Text("\(gameDataManager.totalApples)")
                .font(.custom("MuseoModerno", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

//MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(NavigationCoordinator())
            .environmentObject(GameDataManager())
    }
}
