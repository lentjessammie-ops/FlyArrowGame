import SwiftUI

class GameDataManager: ObservableObject {
    @Published var highestUnlockedLevel: Int
    @Published var applesPerLevel: [String: Int]
    @Published var totalApples: Int
    @Published var purchasedItemIDs: Set<String>
    @Published var selectedBowID: String
    @Published var selectedLineID: String

    private let totalAvailableLevels = 10
    
    let baseLevelReward: Int = 20
    let appleBonus: Int = 10
        

    init() {
        // --- ЭТАП 1: Присваиваем начальные значения ВСЕМ свойствам ---
        
        let loadedLevel = UserDefaults.standard.integer(forKey: "highestUnlockedLevel")
        let savedItems = UserDefaults.standard.stringArray(forKey: "purchasedItemIDs") ?? []
        let savedBow = UserDefaults.standard.string(forKey: "selectedBowID")
        let savedLine = UserDefaults.standard.string(forKey: "selectedLineID")

        self.highestUnlockedLevel = loadedLevel
        self.applesPerLevel = UserDefaults.standard.dictionary(forKey: "applesPerLevel") as? [String: Int] ?? [:]
        self.totalApples = UserDefaults.standard.integer(forKey: "totalApples")
        self.purchasedItemIDs = Set(savedItems)
        self.selectedBowID = savedBow ?? "bow_default"
        self.selectedLineID = savedLine ?? "line_default"
        
        // --- ЭТАП 2: Теперь 'self' полностью готов. Выполняем логику. ---
        
        // Если игра запускается впервые (уровень 0), устанавливаем 1-й.
        if self.highestUnlockedLevel == 0 {
            self.highestUnlockedLevel = 1
        }
        
        // Если купленных предметов нет, добавляем дефолтные.
        if self.purchasedItemIDs.isEmpty {
            self.purchasedItemIDs.insert("bow_default")
            self.purchasedItemIDs.insert("line_default")
        }
    }
    
    private func save() {
        UserDefaults.standard.set(highestUnlockedLevel, forKey: "highestUnlockedLevel")
        UserDefaults.standard.set(applesPerLevel, forKey: "applesPerLevel")
        UserDefaults.standard.set(totalApples, forKey: "totalApples")
        UserDefaults.standard.set(Array(purchasedItemIDs), forKey: "purchasedItemIDs")
        UserDefaults.standard.set(selectedBowID, forKey: "selectedBowID")
        UserDefaults.standard.set(selectedLineID, forKey: "selectedLineID")
    }

    func completeLevel(_ levelNumber: Int, applesCollected: Int) {
            let levelKey = String(levelNumber)
            let currentBest = applesPerLevel[levelKey] ?? 0
            
            if applesCollected > currentBest {
                applesPerLevel[levelKey] = applesCollected
            }

            let totalReward = baseLevelReward + (appleBonus * applesCollected)
            totalApples += totalReward

            if levelNumber == highestUnlockedLevel && levelNumber < totalAvailableLevels {
                highestUnlockedLevel += 1
            }
            
            save()
        }
    
    func canAfford(_ item: ShopItem) -> Bool {
        return totalApples >= item.price
    }
    
    func buyItem(_ item: ShopItem) {
        guard canAfford(item) else { return }
        totalApples -= item.price
        purchasedItemIDs.insert(item.id)
        selectItem(item)
        save()
    }
    
    func selectItem(_ item: ShopItem) {
        guard purchasedItemIDs.contains(item.id) else { return }
        if item.type == .bow {
            selectedBowID = item.id
        } else {
            selectedLineID = item.id
        }
        save()
    }
    
    func isPurchased(_ item: ShopItem) -> Bool {
        return purchasedItemIDs.contains(item.id)
    }

    func isSelected(_ item: ShopItem) -> Bool {
        return item.type == .bow ? selectedBowID == item.id : selectedLineID == item.id
    }
    
    var selectedBowAssetName: String {
        return selectedBowID
    }
    
    var selectedArrowAssetName: String {
        return selectedBowID.replacingOccurrences(of: "bow", with: "arrow")
    }
    
    var selectedLineColor: Color {
        return ShopManager.lines.first { $0.id == selectedLineID }?.color ?? .white
    }
    
    func isLevelUnlocked(_ levelNumber: Int) -> Bool {
        return levelNumber <= highestUnlockedLevel
    }

    func getApplesForLevel(_ levelNumber: Int) -> Int {
        let levelKey = String(levelNumber)
        return applesPerLevel[levelKey] ?? 0
    }
    
    func didCollectAllApples() -> Bool {
        for i in 1...totalAvailableLevels {
            if getApplesForLevel(i) < 3 {
                return false
            }
        }
        return true
    }
}
