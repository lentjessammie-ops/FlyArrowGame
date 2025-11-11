import SwiftUI

enum ShopMode {
    case shop, inventory
}

struct ShopView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var gameDataManager: GameDataManager
    
    let mode: ShopMode
    @State private var selectedTab: ItemType = .bow
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 15) {
                topHeader
                tabPicker
                    .simultaneousGesture(TapGesture().onEnded {
                        AudioManager.shared.playSoundEffect(named: "ui_click")
                    })
                
                ScrollView {
                    VStack(spacing: 15) {
                        let items = selectedTab == .bow ? ShopManager.bows : ShopManager.lines
                        let filteredItems = mode == .inventory ? items.filter { gameDataManager.isPurchased($0) } : items
                        
                        ForEach(filteredItems) { item in
                            ItemRowView(item: item, onButtonTap: handleButtonTap)
                              
                        }
                    }
                    .padding(.bottom, 150)
                }
                .scrollIndicators(.hidden)
                .padding(.top)
            }
            .padding(.horizontal)
            
            if showAlert {
                PurchaseAlertView(title: alertTitle, message: alertMessage, isPresented: $showAlert)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func handleButtonTap(for item: ShopItem) {
        if gameDataManager.isPurchased(item) {
            gameDataManager.selectItem(item)
        } else {
            if gameDataManager.canAfford(item) {
                gameDataManager.buyItem(item)
                alertTitle = "Purchase Successful!"
                alertMessage = "You have equipped the \(item.name)."
                AudioManager.shared.playSoundEffect(named: "purchase_success")
                showAlert = true
            } else {
                alertTitle = "Not Enough Apples!"
                alertMessage = "You need \(item.price - gameDataManager.totalApples) more apples to buy this."
                AudioManager.shared.playSoundEffect(named: "purchase_fail")
                showAlert = true
            }
        }
    }
    
    // MARK: - UI Components
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 200/255, green: 230/255, blue: 255/255),
                Color(red: 180/255, green: 215/255, blue: 255/255)
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
                    .foregroundColor(Color(red: 0/255, green: 122/255, blue: 255/255))
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .clipShape(Circle())
            }
            .simultaneousGesture(TapGesture().onEnded {
                AudioManager.shared.playSoundEffect(named: "ui_click")
            })
            Spacer()
            Text(mode == .shop ? "Shop" : "Inventory")
                .font(.custom("FascinateInline-Regular", size: 34))
                .foregroundColor(.white)
            Spacer()
            appleCounter
        }
        .padding(.top, 40)
    }
    
    private var tabPicker: some View {
        HStack(spacing: 10) {
            TabButton(title: "Bows", isSelected: selectedTab == .bow) {
                selectedTab = .bow
            }
         
            TabButton(title: "Lines", isSelected: selectedTab == .line) {
                selectedTab = .line
            }
         
        }
        .padding(5)
        .background(Color.black.opacity(0.1))
        .cornerRadius(25)
    
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

// MARK: - Subviews

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("MuseoModerno", size: 16))
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .blue : .white)
                .frame(width: 150)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        if isSelected {
                            Color.white
                                .cornerRadius(20)
                        }
                    }
                )
        }
        .simultaneousGesture(TapGesture().onEnded {
            AudioManager.shared.playSoundEffect(named: "ui_click")
        })
    }
}

struct ItemRowView: View {
    @EnvironmentObject var gameDataManager: GameDataManager
    let item: ShopItem
    let onButtonTap: (ShopItem) -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            itemPreview
                .frame(width: 80, height: 80)
                .background(Color.white.opacity(0.3))
                .cornerRadius(20)

            VStack(alignment: .leading) {
                Text(item.name.components(separatedBy: " ").first ?? "")
                    .font(.custom("MuseoModerno", size: 16)).fontWeight(.bold)
                Text(item.name.components(separatedBy: " ").last ?? "")
                    .font(.custom("MuseoModerno", size: 16)).fontWeight(.bold)
            }
            .foregroundColor(.black.opacity(0.7))

            Spacer()
            
            buttonView
                .simultaneousGesture(TapGesture().onEnded {
                    AudioManager.shared.playSoundEffect(named: "ui_click")
                })
                .frame(width: 120)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(25)
    }
    
    @ViewBuilder
    private var itemPreview: some View {
        if item.type == .bow {
            Image(item.imageName)
                .resizable().scaledToFit().padding(10)
        } else {
            Image(item.imageName)
                .resizable().scaledToFit().padding(15)
        }
    }
    
    @ViewBuilder
    private var buttonView: some View {
        if gameDataManager.isSelected(item) {
            HStack(spacing: 5) {
                Image(systemName: "checkmark.circle.fill")
                Text("Selected")
            }
            .font(.custom("MuseoModerno", size: 16)).fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 15).padding(.vertical, 10)
            .background(Color.green).cornerRadius(20)
        } else if gameDataManager.isPurchased(item) {
            Button(action: { onButtonTap(item) }) {
                Text("Select")
                    .font(.custom("MuseoModerno", size: 18)).fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30).padding(.vertical, 12)
                    .background(Color.blue).cornerRadius(20)
            }
        } else {
            VStack(spacing: 8) {
                HStack(spacing: 5) {
                    Image("apple_filled").resizable().scaledToFit().frame(height: 14)
                    Text("\(item.price)")
                }
                .font(.custom("MuseoModerno", size: 14)).fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.red.opacity(0.8)).cornerRadius(12)
                
                Button(action: { onButtonTap(item) }) {
                    Text("Buy")
                        .font(.custom("MuseoModerno", size: 18)).fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 35).padding(.vertical, 10)
                        .background(Color.orange).cornerRadius(20)
                }
            }
        }
    }
}

struct PurchaseAlertView: View {
    let title: String
    let message: String
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 15) {
                Text(title)
                    .font(.custom("FascinateInline-Regular", size: 36))
                    .foregroundColor(title.contains("Success") ? .green : .red)
                
                Text(message)
                    .font(.custom("MuseoModerno", size: 18))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: { isPresented = false }) {
                    Text("OK")
                        .font(.custom("MuseoModerno", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            }
            .padding(30)
            .background(Color(red: 220/255, green: 240/255, blue: 255/255))
            .cornerRadius(30)
            .shadow(radius: 20)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Preview

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        let dataManager = GameDataManager()
        dataManager.totalApples = 500
        dataManager.purchasedItemIDs.insert("bow_blue")
        dataManager.selectItem(ShopManager.bows[1])
        
        return ShopView(mode: .shop)
            .environmentObject(NavigationCoordinator())
            .environmentObject(dataManager)
    }
}
