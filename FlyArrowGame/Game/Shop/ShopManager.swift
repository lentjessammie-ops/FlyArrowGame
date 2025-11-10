import SwiftUI

enum ItemType: Codable {
    case bow, line
}

struct ShopItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let imageName: String
    let price: Int
    let type: ItemType
    var color: Color? {
        switch id {
        case "line_blue": return .blue
        case "line_green": return .green
        case "line_red": return .red
        case "line_yellow": return .yellow
        default: return nil
        }
    }
}

class ShopManager {
    static let bows: [ShopItem] = [
        ShopItem(id: "bow_default", name: "Default Bow", imageName: "bow_default", price: 0, type: .bow),
        ShopItem(id: "bow_blue", name: "Blue Bow", imageName: "bow_blue", price: 150, type: .bow),
        ShopItem(id: "bow_yellow", name: "Yellow Bow", imageName: "bow_yellow", price: 250, type: .bow),
        ShopItem(id: "bow_brown", name: "Brown Bow", imageName: "bow_brown", price: 350, type: .bow),
        ShopItem(id: "bow_green", name: "Green Bow", imageName: "bow_green", price: 500, type: .bow),
    ]

    static let lines: [ShopItem] = [
        ShopItem(id: "line_default", name: "Default Line", imageName: "line_preview", price: 0, type: .line),
        ShopItem(id: "line_blue", name: "Blue Line", imageName: "line_preview_blue", price: 150, type: .line),
        ShopItem(id: "line_green", name: "Green Line", imageName: "line_preview_green", price: 250, type: .line),
        ShopItem(id: "line_red", name: "Red Line", imageName: "line_preview_red", price: 350, type: .line),
        ShopItem(id: "line_yellow", name: "Yellow Line", imageName: "line_preview_yellow", price: 500, type: .line),
    ]
}
