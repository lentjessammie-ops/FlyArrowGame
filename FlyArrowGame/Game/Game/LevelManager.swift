import Foundation
import CoreGraphics

//MARK: - Level Data Structures

struct LevelObject {
    let type: ObjectType
    let position: CGPoint
}

enum ObjectType {
    case bow
    case target
    case ring
    case apple
    case wallLeft
    case wallRight
    case windLeft
    case windRight
}

struct LevelData {
    let levelNumber: Int
    let objects: [LevelObject]
}

//MARK: - Level Manager

class LevelManager {
        
    static let level1 = LevelData(
        levelNumber: 1,
        objects: [
            LevelObject(type: .bow, position: CGPoint(x: 0.5, y: 0.05)),
            LevelObject(type: .target, position: CGPoint(x: 0.5, y: 0.85)),
            LevelObject(type: .ring, position: CGPoint(x: 0.5, y: 0.65)),
            LevelObject(type: .apple, position: CGPoint(x: 0.5, y: 0.35)),
            LevelObject(type: .apple, position: CGPoint(x: 0.5, y: 0.55)),
            LevelObject(type: .apple, position: CGPoint(x: 0.5, y: 0.65)),
        ]
    )
    
    static let level2 = LevelData(
        levelNumber: 2,
        objects: [
            LevelObject(type: .bow, position: CGPoint(x: 0.5, y: 0.05)),
            LevelObject(type: .target, position: CGPoint(x: 0.5, y: 0.85)),
            LevelObject(type: .ring, position: CGPoint(x: 0.705, y: 0.35)),
            LevelObject(type: .ring, position: CGPoint(x: 0.295, y: 0.55)),
            LevelObject(type: .apple, position: CGPoint(x: 0.295, y: 0.2)),
            LevelObject(type: .apple, position: CGPoint(x: 0.705, y: 0.3)),
            LevelObject(type: .apple, position: CGPoint(x: 0.346, y: 0.45)),
        ]
    )
    
    static let level3 = LevelData(
        levelNumber: 3,
        objects: [
            LevelObject(type: .bow, position: CGPoint(x: 0.5, y: 0.05)),
            LevelObject(type: .target, position: CGPoint(x: 0.5, y: 0.85)),
            LevelObject(type: .ring, position: CGPoint(x: 0.255, y: 0.35)),
            LevelObject(type: .ring, position: CGPoint(x: 0.495, y: 0.55)),
            LevelObject(type: .ring, position: CGPoint(x: 0.705, y: 0.70)),
            LevelObject(type: .apple, position: CGPoint(x: 0.295, y: 0.2)),
            LevelObject(type: .apple, position: CGPoint(x: 0.705, y: 0.3)),
            LevelObject(type: .apple, position: CGPoint(x: 0.346, y: 0.45)),
        ]
    )
    
    static let level4 = LevelData(
        levelNumber: 4,
        objects: [
            LevelObject(type: .bow, position: CGPoint(x: 0.5, y: 0.05)),
            LevelObject(type: .target, position: CGPoint(x: 0.5, y: 0.85)),
            LevelObject(type: .ring, position: CGPoint(x: 0.705, y: 0.35)),
            LevelObject(type: .ring, position: CGPoint(x: 0.295, y: 0.55)),
            LevelObject(type: .ring, position: CGPoint(x: 0.705, y: 0.65)),
            LevelObject(type: .apple, position: CGPoint(x: 0.295, y: 0.2)),
            LevelObject(type: .apple, position: CGPoint(x: 0.705, y: 0.3)),
            LevelObject(type: .apple, position: CGPoint(x: 0.346, y: 0.45)),
        ]
    )
    
    static let level5 = LevelData(
        levelNumber: 5,
        objects: [
            LevelObject(type: .bow, position: CGPoint(x: 0.5, y: 0.05)),
            LevelObject(type: .target, position: CGPoint(x: 0.5, y: 0.85)),
            LevelObject(type: .ring, position: CGPoint(x: 0.295, y: 0.2)),
            LevelObject(type: .ring, position: CGPoint(x: 0.495, y: 0.55)),
            LevelObject(type: .wallLeft, position: CGPoint(x: 0.35, y: 0.4)),
            LevelObject(type: .apple, position: CGPoint(x: 0.795, y: 0.4)),
            LevelObject(type: .apple, position: CGPoint(x: 0.295, y: 0.65)),
            LevelObject(type: .apple, position: CGPoint(x: 0.695, y: 0.75)),
        ]
    )
    
    static let level6 = LevelData(
        levelNumber: 6,
        objects: [
            LevelObject(type: .bow, position: CGPoint(x: 0.5, y: 0.05)),
            LevelObject(type: .target, position: CGPoint(x: 0.5, y: 0.85)),
            LevelObject(type: .wallRight, position: CGPoint(x: 0.5, y: 0.25)),
            LevelObject(type: .ring, position: CGPoint(x: 0.45, y: 0.45)),
            LevelObject(type: .ring, position: CGPoint(x: 0.75, y: 0.65)),
            LevelObject(type: .apple, position: CGPoint(x: 0.25, y: 0.25)),
            LevelObject(type: .apple, position: CGPoint(x: 0.65, y: 0.35)),
            LevelObject(type: .apple, position: CGPoint(x: 0.25, y: 0.6)),
        ]
    )
    
    static let level7 = LevelData(
        levelNumber: 7,
        objects: [
            LevelObject(type: .bow, position: CGPoint(x: 0.5, y: 0.05)),
            LevelObject(type: .target, position: CGPoint(x: 0.5, y: 0.85)),
            LevelObject(type: .ring, position: CGPoint(x: 0.25, y: 0.25)),
            LevelObject(type: .wallLeft, position: CGPoint(x: 0.25, y: 0.4)),
            LevelObject(type: .ring, position: CGPoint(x: 0.65, y: 0.4)),
            LevelObject(type: .wallRight, position: CGPoint(x: 0.65, y: 0.6)),
            LevelObject(type: .apple, position: CGPoint(x: 0.65, y: 0.3)),
            LevelObject(type: .apple, position: CGPoint(x: 0.5, y: 0.5)),
            LevelObject(type: .apple, position: CGPoint(x: 0.2, y: 0.6)),
        ]
    )
    
    static let level8 = LevelData(
        levelNumber: 8,
        objects: [
            LevelObject(type: .bow, position: CGPoint(x: 0.5, y: 0.05)),
            LevelObject(type: .target, position: CGPoint(x: 0.5, y: 0.85)),
            LevelObject(type: .windLeft, position: CGPoint(x: 0.5, y: 0.45)),
            LevelObject(type: .ring, position: CGPoint(x: 0.7, y: 0.25)),
            LevelObject(type: .ring, position: CGPoint(x: 0.3, y: 0.65)),
            LevelObject(type: .apple, position: CGPoint(x: 0.7, y: 0.25)),
            LevelObject(type: .apple, position: CGPoint(x: 0.3, y: 0.65)),
            LevelObject(type: .apple, position: CGPoint(x: 0.5, y: 0.45)),
        ]
    )
    
    static let level9 = LevelData(
        levelNumber: 9,
        objects: [
            LevelObject(type: .bow, position: CGPoint(x: 0.5, y: 0.05)),
            LevelObject(type: .target, position: CGPoint(x: 0.5, y: 0.85)),
            LevelObject(type: .windRight, position: CGPoint(x: 0.2, y: 0.25)),
            LevelObject(type: .windLeft, position: CGPoint(x: 0.6, y: 0.6)),
            LevelObject(type: .ring, position: CGPoint(x: 0.705, y: 0.35)),
            LevelObject(type: .ring, position: CGPoint(x: 0.255, y: 0.55)),
            LevelObject(type: .apple, position: CGPoint(x: 0.295, y: 0.2)),
            LevelObject(type: .apple, position: CGPoint(x: 0.695, y: 0.45)),
            LevelObject(type: .apple, position: CGPoint(x: 0.295, y: 0.65)),
        ]
    )
    
    static let level10 = LevelData(
        levelNumber: 10,
        objects: [
            LevelObject(type: .bow, position: CGPoint(x: 0.5, y: 0.05)),
            LevelObject(type: .target, position: CGPoint(x: 0.75, y: 0.85)),
            LevelObject(type: .windRight, position: CGPoint(x: 0.2, y: 0.2)),
            LevelObject(type: .wallLeft, position: CGPoint(x: 0.2, y: 0.38)),
            LevelObject(type: .ring, position: CGPoint(x: 0.25, y: 0.25)),
            LevelObject(type: .windLeft, position: CGPoint(x: 0.2, y: 0.38)),
            LevelObject(type: .ring, position: CGPoint(x: 0.75, y: 0.4)),
            LevelObject(type: .wallRight, position: CGPoint(x: 0.75, y: 0.55)),
            LevelObject(type: .ring, position: CGPoint(x: 0.3, y: 0.6)),
            LevelObject(type: .wallLeft, position: CGPoint(x: 0.3, y: 0.73)),
            LevelObject(type: .windRight, position: CGPoint(x: 0.2, y: 0.6)),
            LevelObject(type: .windLeft, position: CGPoint(x: 0.2, y: 0.75)),
            LevelObject(type: .apple, position: CGPoint(x: 0.7, y: 0.25)),
            LevelObject(type: .apple, position: CGPoint(x: 0.45, y: 0.45)),
            LevelObject(type: .apple, position: CGPoint(x: 0.1, y: 0.8)),
            
        ]
    )
    
    static let allLevels = [level1, level2, level3, level4, level5, level6, level7, level8, level9, level10]
    
    static func getLevel(by number: Int) -> LevelData? {
            return allLevels.first { $0.levelNumber == number }
        }
}
