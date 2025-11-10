


import SpriteKit
import GameplayKit
import SwiftUI

//MARK: - Protocols

protocol GameLogicDelegate: AnyObject {
    func appleCollected()
    func levelCompleted()
    func levelFailed(reason: String)
    func pathLengthUpdated(progress: CGFloat)
}

//MARK: - Physics Categories

struct PhysicsMask {
    static let none: UInt32     = 0
    static let arrow: UInt32    = 1 << 0
    static let apple: UInt32    = 1 << 1
    static let target: UInt32   = 1 << 2
    static let ringGate: UInt32 = 1 << 3
    static let wall: UInt32     = 1 << 4
    static let wind: UInt32     = 1 << 5
}

//MARK: - Custom Node for Wind

class WindNode: SKSpriteNode {
    var isWindActive = false
    var direction: WindDirection = .left
    
    enum WindDirection {
        case left, right
    }
}

//MARK: - GameScene

class GameScene: SKScene, SKPhysicsContactDelegate {

    weak var gameLogicDelegate: GameLogicDelegate?
    
    private let designWidth: CGFloat = 390
    private var U: CGFloat { size.width / designWidth }
    
    private var levelData: LevelData
    
    private var bow: SKSpriteNode?
    private var arrow: SKSpriteNode?
    private var target: SKSpriteNode?
    private var apples: [SKSpriteNode] = []
    
    private var ringGates: [SKNode] = []
    private var ringsPassed = Set<SKNode>()
    
    private var currentPath: SKShapeNode?
    private var pathPoints: [CGPoint] = []
    private var totalPathLength: CGFloat = 0.0
    private var maxPathLength: CGFloat { 1200 * U }
    private var dashTexture: SKTexture?

    private var isDrawing = false
    private var isArrowFlying = false
    private var didTouchTarget = false
    
    private var bowAssetName: String
    private var arrowAssetName: String
    private var lineColor: UIColor

    //MARK: - Initializers

    init(size: CGSize, levelData: LevelData, bow: String, arrow: String, line: Color) {
        self.levelData = levelData
        self.bowAssetName = bow
        self.arrowAssetName = arrow
        self.lineColor = UIColor(line)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        setupPhysics()
        setupBackground()
        createDashTexture()
        setupLevel()
    }
    
    //MARK: - Setup Methods
    
    private func setupPhysics() {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }
    
    private func setupBackground() {
        let backgroundNode = SKSpriteNode(imageNamed: "bg")
        backgroundNode.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundNode.zPosition = -10

        // Рассчитываем соотношения сторон экрана и изображения
        let screenAspectRatio = size.width / size.height
        let imageAspectRatio = backgroundNode.size.width / backgroundNode.size.height

        // Логика scaledToFill: если экран "уже" картинки, масштабируем по ширине.
        // Если экран "шире" картинки, масштабируем по высоте.
        if screenAspectRatio > imageAspectRatio {
            let newHeight = size.width / imageAspectRatio
            backgroundNode.size = CGSize(width: size.width, height: newHeight)
        } else {
            let newWidth = size.height * imageAspectRatio
            backgroundNode.size = CGSize(width: newWidth, height: size.height)
        }
        
        addChild(backgroundNode)
    }

    private func setupLevel() {
        for objectData in levelData.objects {
            let position = CGPoint(x: objectData.position.x * size.width, y: objectData.position.y * size.height)
            
            switch objectData.type {
            case .bow:
                let newBow = createSprite(name: bowAssetName, width: 150)
                newBow.position = position
                newBow.zPosition = 1
                addChild(newBow)
                self.bow = newBow
            case .target:
                let newTarget = createSprite(name: "target_flag", width: 60)
                newTarget.position = position
                newTarget.zPosition = 0
                newTarget.physicsBody = SKPhysicsBody(rectangleOf: newTarget.size)
                newTarget.physicsBody?.isDynamic = false
                newTarget.physicsBody?.categoryBitMask = PhysicsMask.target
                newTarget.physicsBody?.contactTestBitMask = PhysicsMask.arrow
                addChild(newTarget)
                self.target = newTarget
            case .ring:
                addRing(at: position, width: 180)
            case .apple:
                addApple(at: position, width: 45)
            case .wallLeft:
                addWall(at: position, imageName: "wall_left")
            case .wallRight:
                addWall(at: position, imageName: "wall_right")
            case .windLeft:
                setupWind(at: position, direction: .left)
            case .windRight:
                setupWind(at: position, direction: .right)
            }
        }
        spawnArrow()
    }
    
    private func spawnArrow() {
        guard let bow = self.bow else { return }
        
        arrow?.removeFromParent()
        let newArrow = createSprite(name: arrowAssetName, width: 15)
        newArrow.position = CGPoint(x: bow.position.x, y: bow.position.y + 25 * U)
        newArrow.zPosition = 5
        newArrow.physicsBody = SKPhysicsBody(rectangleOf: newArrow.size)
        newArrow.physicsBody?.categoryBitMask = PhysicsMask.arrow
        newArrow.physicsBody?.contactTestBitMask = PhysicsMask.ringGate | PhysicsMask.apple | PhysicsMask.target | PhysicsMask.wall | PhysicsMask.wind
        newArrow.physicsBody?.collisionBitMask = PhysicsMask.none
        newArrow.physicsBody?.affectedByGravity = false
        newArrow.physicsBody?.isDynamic = false
        addChild(newArrow)
        self.arrow = newArrow
    }
    
    //MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isArrowFlying, let touch = touches.first else { return }
        isDrawing = true
        resetPath()
        let location = touch.location(in: self)
        pathPoints.append(location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawing, let touch = touches.first else { return }
        let location = touch.location(in: self)
        let lastPoint = pathPoints.last!
        let distance = hypot(location.x - lastPoint.x, location.y - lastPoint.y)
        
        if distance > 10 * U && totalPathLength < maxPathLength {
            totalPathLength += distance
            pathPoints.append(location)
            drawPath()
            gameLogicDelegate?.pathLengthUpdated(progress: totalPathLength / maxPathLength)
        }
        if totalPathLength >= maxPathLength {
            isDrawing = false
            flyArrow()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDrawing else { return }
        isDrawing = false
        flyArrow()
    }
    
    //MARK: - Game Logic
    
    private func flyArrow() {
        guard pathPoints.count > 1, let arrow = self.arrow else {
            resetPath()
            return
        }
        isArrowFlying = true
        AudioManager.shared.playSoundEffect(named: "arrow_shoot")
        AudioManager.shared.impactVibrate(style: .light)
        arrow.physicsBody?.isDynamic = true
        
        let path = CGMutablePath()
        path.move(to: pathPoints[0])
        for i in 1..<pathPoints.count { path.addLine(to: pathPoints[i]) }

        let followPath = SKAction.follow(path, asOffset: false, orientToPath: true, speed: 700 * U)
        arrow.run(followPath) { [weak self] in
            if self?.didTouchTarget == false {
                self?.levelFailed(reason: "Arrow missed the target")
            }
        }
    }
    
    private func blowArrowAway(direction: WindNode.WindDirection) {
        guard isArrowFlying, let arrow = self.arrow else { return }
        
        arrow.removeAllActions()
        
        let moveX = direction == .left ? -size.width : size.width
        let blowAction = SKAction.moveBy(x: moveX, y: 50 * U, duration: 0.5)
        blowAction.timingMode = .easeIn
        
        arrow.run(SKAction.sequence([blowAction, SKAction.removeFromParent()])) { [weak self] in
            self?.levelFailed(reason: "Blown away by the wind!")
        }
    }
    
    private func checkWinCondition() {
        let passedAllGates = ringsPassed.count == ringGates.count
        if didTouchTarget && passedAllGates {
            levelWon()
        } else if didTouchTarget && !passedAllGates {
            levelFailed(reason: "You missed one or more rings!")
        }
    }
    
    private func levelWon() {
        isArrowFlying = false
        arrow?.removeAllActions()
        arrow?.physicsBody?.isDynamic = false
        gameLogicDelegate?.levelCompleted()
        AudioManager.shared.playSoundEffect(named: "level_win")
        AudioManager.shared.vibrate(type: .success)
    }
    
    private func levelFailed(reason: String) {
        guard isArrowFlying else { return }
        AudioManager.shared.playSoundEffect(named: "level_lose")
        AudioManager.shared.vibrate(type: .error)
        isArrowFlying = false
        arrow?.removeAllActions()
        arrow?.physicsBody?.isDynamic = false
        gameLogicDelegate?.levelFailed(reason: reason)
        
    }

    func resetLevel() {
        isArrowFlying = false
        isDrawing = false
        didTouchTarget = false
        resetPath()
        ringsPassed.removeAll()
        
        children.filter { $0.name == "apple" }.forEach { $0.removeFromParent() }
        apples.forEach { apple in addChild(apple) }
        
        ringGates.forEach { $0.physicsBody?.categoryBitMask = PhysicsMask.ringGate }
        
        spawnArrow()
    }
    
    //MARK: - Path Drawing

    private func resetPath() {
        currentPath?.removeFromParent()
        pathPoints.removeAll()
        totalPathLength = 0.0
        gameLogicDelegate?.pathLengthUpdated(progress: 0.0)
    }
    
    private func drawPath() {
        currentPath?.removeFromParent()
        let path = CGMutablePath()
        guard !pathPoints.isEmpty else { return }
        path.move(to: pathPoints[0])
        for i in 1..<pathPoints.count { path.addLine(to: pathPoints[i]) }
        
        currentPath = SKShapeNode(path: path)
        currentPath?.strokeColor = .white
        currentPath?.lineWidth = 4 * U
        currentPath?.strokeTexture = dashTexture
        currentPath?.zPosition = -1
        addChild(currentPath!)
    }
    
    //MARK: - Physics Delegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask
        
        let arrowBody = (maskA == PhysicsMask.arrow) ? contact.bodyA : (maskB == PhysicsMask.arrow) ? contact.bodyB : nil
        let otherBody = (arrowBody === contact.bodyA) ? contact.bodyB : contact.bodyA
        
        guard isArrowFlying, arrowBody != nil, let otherNode = otherBody.node else { return }

        switch otherBody.categoryBitMask {
        case PhysicsMask.apple:
            if otherNode.parent != nil {
                otherNode.removeFromParent()
                gameLogicDelegate?.appleCollected()
                AudioManager.shared.playSoundEffect(named: "apple_collect")
                AudioManager.shared.impactVibrate(style: .soft)
            }
            
        case PhysicsMask.ringGate:
            AudioManager.shared.playSoundEffect(named: "ring_pass")
            AudioManager.shared.impactVibrate(style: .rigid)
            ringsPassed.insert(otherNode)
        case PhysicsMask.target:
            didTouchTarget = true
            checkWinCondition()
        case PhysicsMask.wall:
            AudioManager.shared.playSoundEffect(named: "wall_hit")
            AudioManager.shared.impactVibrate(style: .heavy)
            levelFailed(reason: "You hit a wall!")
        case PhysicsMask.wind:
            if let windNode = otherNode as? WindNode, windNode.isWindActive {
                blowArrowAway(direction: windNode.direction)
            }
        default:
            break
        }
    }
    
    //MARK: - Helpers
    
    private func setupWind(at position: CGPoint, direction: WindNode.WindDirection) {
        let imageName = (direction == .left) ? "wind_left" : "wind_right"
        let wind = WindNode(imageNamed: imageName)
        wind.direction = direction
        wind.setScale(0.3)
        wind.zPosition = 8
        wind.alpha = 0
        
        let startX = (direction == .left) ? frame.width + wind.size.width : -wind.size.width
        let startPosition = CGPoint(x: startX, y: position.y)
        wind.position = startPosition
        
        wind.physicsBody = SKPhysicsBody(rectangleOf: wind.size)
        wind.physicsBody?.isDynamic = false
        wind.physicsBody?.categoryBitMask = PhysicsMask.wind
        
        addChild(wind)
        
        let moveX = (direction == .left) ? -frame.width - wind.size.width * 2 : frame.width + wind.size.width * 2
        
        let waitAction = SKAction.wait(forDuration: 0.0)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.0)
        let moveAction = SKAction.moveBy(x: moveX, y: 0, duration: 2.0)
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.0)
        let resetPositionAction = SKAction.move(to: startPosition, duration: 0)
        
        let activateWind = SKAction.run {
            wind.isWindActive = true
           // AudioManager.shared.playSoundEffect(named: "wind_whoosh")
        }
        let deactivateWind = SKAction.run { wind.isWindActive = false }

        let sequence = SKAction.sequence([ waitAction, fadeInAction, activateWind, moveAction, deactivateWind, fadeOutAction, resetPositionAction ])
        wind.run(SKAction.repeatForever(sequence))
    }
    
    private func addWall(at position: CGPoint, imageName: String) {
        let wall = createSprite(name: imageName, width: 120)
        wall.position = position
        wall.zPosition = 2
        wall.physicsBody = SKPhysicsBody(texture: wall.texture!, size: wall.size)
        wall.physicsBody?.isDynamic = false
        wall.physicsBody?.categoryBitMask = PhysicsMask.wall
        addChild(wall)
    }
    
    private func addRing(at position: CGPoint, width: CGFloat) {
        let ringBottom = createSprite(name: "ring_bottom", width: width)
        let ringTop = createSprite(name: "ring_top", width: width)
        
        ringBottom.position = CGPoint(x: position.x, y: position.y - ringBottom.size.height / 2)
        ringTop.position = CGPoint(x: position.x, y: position.y + ringTop.size.height / 2)
        
        ringBottom.zPosition = 4
        ringTop.zPosition = 6
        
        addChild(ringBottom)
        addChild(ringTop)
        
        let gate = SKNode()
        gate.position = position
        let gateSize = CGSize(width: ringTop.size.width * 0.9, height: 10 * U)
        gate.physicsBody = SKPhysicsBody(rectangleOf: gateSize)
        gate.physicsBody?.isDynamic = false
        gate.physicsBody?.categoryBitMask = PhysicsMask.ringGate
        gate.physicsBody?.contactTestBitMask = PhysicsMask.arrow
        addChild(gate)
        ringGates.append(gate)
    }

    private func addApple(at position: CGPoint, width: CGFloat) {
        let apple = createSprite(name: "apple_filled", width: width)
        apple.position = position
        apple.name = "apple"
        apple.zPosition = 5
        apple.physicsBody = SKPhysicsBody(circleOfRadius: apple.size.width * 0.45)
        apple.physicsBody?.isDynamic = false
        apple.physicsBody?.categoryBitMask = PhysicsMask.apple
        apple.physicsBody?.contactTestBitMask = PhysicsMask.arrow
        apples.append(apple)
        addChild(apple)
    }

    private func createSprite(name: String, width: CGFloat) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: name)
        let ratio = node.size.height / node.size.width
        node.size = CGSize(width: width * U, height: width * ratio * U)
        return node
    }
    
    private func createDashTexture() {
        let size = CGSize(width: 20 * U, height: 4 * U) // Сделал текстуру толще, чтобы цвет был заметнее
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            lineColor.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 10 * U, height: 4 * U))
        }
        self.dashTexture = SKTexture(image: image)
    }
}
