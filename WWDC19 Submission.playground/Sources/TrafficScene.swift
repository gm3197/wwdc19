import SpriteKit
import PlaygroundSupport

public class TrafficScene: SKScene, SKPhysicsContactDelegate {
    var upLight = TrafficLightStatus.green
    var downLight = TrafficLightStatus.red
    var leftLight = TrafficLightStatus.red
    var rightLight = TrafficLightStatus.red
    
    private var upTrafficLight: SKSpriteNode!
    private var downTrafficLight: SKSpriteNode!
    private var leftTrafficLight: SKSpriteNode!
    private var rightTrafficLight: SKSpriteNode!
    
    private var gameRunning = true
    var textures: SKTextureAtlas!
    
    var clockLabel: SKLabelNode!
    var gameClock: Int = 0 {
        didSet {
            clockLabel.text = "\(Int(gameClock / 60)):\(String(format: "%02d", gameClock % 60))"
        }
    }
    
    var vehicles = [VehicleNode]()
    
    public override func didMove(to view: SKView) {
        textures = SKTextureAtlas(dictionary: [
            "redcar" : UIImage(named: "redcar.png")!,
            "greencar" : UIImage(named: "greencar.png")!,
            "whitecar" : UIImage(named: "whitecar.png")!,
            "biker" : UIImage(named: "biker.png")!,
            "bluecar": UIImage(named:"bluecar.png")!,
            "yellowcar": UIImage(named:"yellowcar.png")!,
            "bus": UIImage(named:"bus.png")!,
            "background": UIImage(named:"background.png")!,
            "gameover": UIImage(named:"gameover.png")!,
            "redlight": UIImage(named:"redlight.png")!,
            "yellowlight": UIImage(named:"yellowlight.png")!,
            "greenlight": UIImage(named:"greenlight.png")!
            ])
        textures.preload {
            print("Textures preloaded.")
        }
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        addBackground()
        
        addClockLabel()
        
        upTrafficLight = SKSpriteNode()
        addChild(upTrafficLight)
        upTrafficLight.size = CGSize(width: 50.4375, height: 24.1875)
        upTrafficLight.position = CGPoint(x: 361.78125, y: 333.53125)
        upTrafficLight.zPosition = Layers.lights
        
        downTrafficLight = SKSpriteNode()
        addChild(downTrafficLight)
        downTrafficLight.size = CGSize(width: 50.4375, height: 24.1875)
        downTrafficLight.position = CGPoint(x: 278.34375, y: 154.84375)
        downTrafficLight.zPosition = Layers.lights
        downTrafficLight.zRotation = 3.1415
        
        leftTrafficLight = SKSpriteNode()
        addChild(leftTrafficLight)
        leftTrafficLight.size = CGSize(width: 50.4375, height: 24.1875)
        leftTrafficLight.position = CGPoint(x: 233.65625, y: 283.71875)
        leftTrafficLight.zPosition = Layers.lights
        leftTrafficLight.zRotation = 3.1415/2
        
        rightTrafficLight = SKSpriteNode()
        addChild(rightTrafficLight)
        rightTrafficLight.size = CGSize(width: 50.4375, height: 24.1875)
        rightTrafficLight.position = CGPoint(x: 404.40625, y: 198.59375)
        rightTrafficLight.zPosition = Layers.lights
        rightTrafficLight.zRotation = 3.1415*1.5
        
        updateTrafficLightButtons()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateClock), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.addCars), userInfo: nil, repeats: true)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        for vehicle in vehicles {
            if vehicle.direction == .up && vehicle.position.y > size.height + vehicle.size.height {
                vehicle.recycleNode()
            } else if vehicle.direction == .down && vehicle.position.y < -1*vehicle.size.height {
                vehicle.recycleNode()
            } else if vehicle.direction == .left && vehicle.position.x < -1 * vehicle.size.height {
                vehicle.recycleNode()
            } else if vehicle.direction == .right && vehicle.position.x > size.width + vehicle.size.height {
                vehicle.recycleNode()
            }
        }
        
        if gameRunning {
            for vehicle in vehicles {
                if vehicle.lightStatus() == .red && !vehicle.isPastRed() {
                    if vehicle.isAtStopLine() {
                        if vehicle.action(forKey: "moveForward") != nil {
                            vehicle.removeAllActions()
                        }
                    } else {
                        if !vehicle.isBehindCar() {
                            if !(vehicle.action(forKey: "moveForward") != nil) {
                                vehicle.moveForward()
                            }
                        } else {
                            if vehicle.action(forKey: "moveForward") != nil {
                                vehicle.removeAllActions()
                            }
                        }
                    }
                } else {
                    if !(vehicle.action(forKey: "exitScreen") != nil) {
                        vehicle.exitScreen()
                    }
                }
            }
        } else {
            for vehicle in vehicles {
                vehicle.removeAllActions()
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let node = atPoint((touches.first?.location(in: self))!)
        if node == upTrafficLight {
            toggle(light: .up)
        } else if node == downTrafficLight {
            toggle(light: .down)
        } else if node == leftTrafficLight {
            toggle(light: .left)
        } else if node == rightTrafficLight {
            toggle(light: .right)
        } else {
            //            if (touches.first?.location(in: self).y)! > size.height/2 {
            //                createRandomVehicle(direction: .down)
            //            } else {
            //                createRandomVehicle(direction: .up)
            //            }
            //            if (touches.first?.location(in: self).x)! > size.width/2 {
            //                createRandomVehicle(direction: .left)
            //            } else {
            //                createRandomVehicle(direction: .right)
            //            }
        }
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        let firstNode = contact.bodyA.node as! VehicleNode
        let secondNode = contact.bodyB.node as! VehicleNode
        if firstNode.action(forKey: "exitScreen") != nil && secondNode.action(forKey: "exitScreen") != nil {
            let explosion = SKEmitterNode(fileNamed: "explosion.sks")!
            explosion.position = firstNode.position
            explosion.zPosition = Layers.explosion
            addChild(explosion)
            run(.wait(forDuration: 1.5)) {
                explosion.removeFromParent()
            }
            endGameWith(reason: "Car crashed!")
        }
    }
    
    func addBackground() {
        let background = SKSpriteNode(texture: textures.textureNamed("background"))
        addChild(background)
        background.size = CGSize(width: 640, height: 480)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = Layers.background
    }
    
    func addClockLabel() {
        clockLabel = SKLabelNode(fontNamed: "GillSans-Regular")
        addChild(clockLabel)
        clockLabel.position = CGPoint(x: 600, y: 450)
        clockLabel.zPosition = Layers.lights
        clockLabel.color = .white
    }
    
    @objc func updateClock() {
        if gameRunning {
            gameClock += 1
        }
    }
    
    func endGameWith(reason: String) {
        gameRunning = false
        let gameOverText = SKSpriteNode(texture: textures.textureNamed("gameover"))
        gameOverText.alpha = 0
        addChild(gameOverText)
        gameOverText.size = CGSize(width: 296.875, height: 206.25)
        gameOverText.position = CGPoint(x: size.width/2, y: (size.height/2) + 70)
        gameOverText.zPosition = Layers.endGameText
        
        let gameOverReason = SKLabelNode(text: reason)
        gameOverReason.alpha = 0
        addChild(gameOverReason)
        gameOverReason.fontName = "GillSans-Bold"
        gameOverReason.fontColor = .black
        gameOverReason.position = CGPoint(x: size.width/2, y: (size.height/2) - 80)
        gameOverReason.zPosition = Layers.endGameText
        
        clockLabel.alpha = 0
        clockLabel.fontColor = .black
        clockLabel.position = CGPoint(x: size.width/2, y: (size.height/2) - 110)
        clockLabel.zPosition = Layers.endGameText
        
        gameOverText.run(SKAction.sequence([.wait(forDuration: 0.75), .fadeAlpha(by: 1, duration: 1)]))
        gameOverReason.run(SKAction.sequence([.wait(forDuration: 0.75), .fadeAlpha(by: 1, duration: 1)]))
        clockLabel.run(SKAction.sequence([.wait(forDuration: 0.75), .fadeAlpha(by: 1, duration: 1)]))
    }
    
    @objc func addCars() {
        if gameRunning {
            var numberOfUpVehicles = 0
            for vehicle in vehicles {
                if vehicle.direction == .up {
                    numberOfUpVehicles = numberOfUpVehicles + 1
                }
            }
            if numberOfUpVehicles <= 2 {
                createRandomVehicle(direction: .up)
            }
            
            var numberOfDownVehicles = 0
            for vehicle in vehicles {
                if vehicle.direction == .down {
                    numberOfDownVehicles = numberOfDownVehicles + 1
                }
            }
            if numberOfDownVehicles <= 2 {
                createRandomVehicle(direction: .down)
            }
            
            var numberOfLeftVehicles = 0
            for vehicle in vehicles {
                if vehicle.direction == .left {
                    numberOfLeftVehicles = numberOfLeftVehicles + 1
                }
            }
            if numberOfLeftVehicles <= 2 {
                createRandomVehicle(direction: .left)
            }
            
            var numberOfRightVehicles = 0
            for vehicle in vehicles {
                if vehicle.direction == .right {
                    numberOfRightVehicles = numberOfRightVehicles + 1
                }
            }
            if numberOfRightVehicles <= 2 {
                createRandomVehicle(direction: .right)
            }
            
            for vehicle in vehicles {
                if vehicle.lightStatus() == .red && !vehicle.isPastRed() {
                    if vehicle.isAtStopLine() {
                        vehicle.timeWaiting += 1.5
                    }
                }
                if vehicle.timeWaiting == 9 {
                    vehicle.shake(duration: 1.5)
                }
                if vehicle.timeWaiting >= 11 {
                    vehicle.exitScreen()
                }
            }
        }
    }
    
    func updateTrafficLightButtons() {
        if upLight == .red && downLight == .red && leftLight == .red && rightLight == .red {
            endGameWith(reason: "All the lights turned red.")
        }
        upTrafficLight.texture = imageForLightStatus(upLight)
        downTrafficLight.texture = imageForLightStatus(downLight)
        leftTrafficLight.texture = imageForLightStatus(leftLight)
        rightTrafficLight.texture = imageForLightStatus(rightLight)
    }
    
    func toggle(light: TrafficDirection) {
        if gameRunning {
            switch light {
            case .up:
                if upLight == .red {
                    upLight = .green
                } else {
                    upLight = .yellow
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        self.upLight = .red
                        self.updateTrafficLightButtons()
                    }
                }
                break
            case .down:
                if downLight == .red {
                    downLight = .green
                } else {
                    downLight = .yellow
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        self.downLight = .red
                        self.updateTrafficLightButtons()
                    }
                }
                break
            case .left:
                if leftLight == .red {
                    leftLight = .green
                } else {
                    leftLight = .yellow
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        self.leftLight = .red
                        self.updateTrafficLightButtons()
                    }
                }
                break
            case .right:
                if rightLight == .red {
                    rightLight = .green
                } else {
                    rightLight = .yellow
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        self.rightLight = .red
                        self.updateTrafficLightButtons()
                    }
                }
                break
            }
            updateTrafficLightButtons()
        }
    }
    
    func imageForLightStatus(_ lightStatus: TrafficLightStatus) -> SKTexture {
        switch lightStatus {
        case .green:
            return textures.textureNamed("greenlight")
        case .yellow:
            return textures.textureNamed("yellowlight")
        case .red:
            return textures.textureNamed("redlight")
        }
    }
    
    func createRandomVehicle(direction: TrafficDirection) {
        var vehicle: VehicleNode!
        
        switch Int.random(in: 0...6) {
        case 0:
            vehicle = VehicleNode(texture: textures.textureNamed("bluecar"))
            vehicle.size = CGSize(width: 35, height: 37.5)
            break
        case 1:
            vehicle = VehicleNode(texture: textures.textureNamed("redcar"))
            vehicle.size = CGSize(width: 35, height: 37.5)
            break
        case 2:
            vehicle = VehicleNode(texture: textures.textureNamed("yellowcar"))
            vehicle.size = CGSize(width: 35, height: 37.5)
            break
        case 3:
            vehicle = VehicleNode(texture: textures.textureNamed("bus"))
            vehicle.size = CGSize(width: 28.75, height: 63.125)
            break
        case 4:
            vehicle = VehicleNode(texture: textures.textureNamed("biker"))
            vehicle.size = CGSize(width: 35, height: 37.5)
            break
        case 5:
            vehicle = VehicleNode(texture: textures.textureNamed("greencar"))
            vehicle.size = CGSize(width: 35, height: 37.5)
            break
        case 6:
            vehicle = VehicleNode(texture: textures.textureNamed("whitecar"))
            vehicle.size = CGSize(width: 35, height: 37.5)
            break
        default:
            vehicle = VehicleNode(texture: textures.textureNamed("bluecar"))
            vehicle.size = CGSize(width: 35, height: 37.5)
            break
        }
        
        addChild(vehicle)
        vehicle.zPosition = Layers.cars
        vehicle.anchorPoint = CGPoint(x: 0.5, y: 1)
        vehicle.physicsBody = SKPhysicsBody(texture: vehicle.texture!, size: vehicle.texture!.size())
        //        vehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: vehicle.size.width*0.8, height: vehicle.size.height))
        vehicle.physicsBody?.isDynamic = true
        vehicle.physicsBody?.usesPreciseCollisionDetection = true
        switch direction {
        case .up:
            vehicle.physicsBody?.categoryBitMask = PhysicsCategory.updown
            vehicle.physicsBody?.contactTestBitMask = PhysicsCategory.leftright
            vehicle.physicsBody?.collisionBitMask = PhysicsCategory.none
        case .down:
            vehicle.physicsBody?.categoryBitMask = PhysicsCategory.updown
            vehicle.physicsBody?.contactTestBitMask = PhysicsCategory.leftright
            vehicle.physicsBody?.collisionBitMask = PhysicsCategory.none
        case .left:
            vehicle.physicsBody?.categoryBitMask = PhysicsCategory.leftright
            vehicle.physicsBody?.contactTestBitMask = PhysicsCategory.updown
            vehicle.physicsBody?.collisionBitMask = PhysicsCategory.none
        case .right:
            vehicle.physicsBody?.categoryBitMask = PhysicsCategory.leftright
            vehicle.physicsBody?.contactTestBitMask = PhysicsCategory.updown
            vehicle.physicsBody?.collisionBitMask = PhysicsCategory.none
        }
        
        vehicle.direction = direction
        
        let lane = Int.random(in: 0...1)
        switch direction {
        case .up:
            if lane == 0 {
                vehicle.position = CGPoint(x: 342, y: -10)
            } else if lane == 1 {
                vehicle.position = CGPoint(x: 382.625, y: -10)
            }
            break
        case .down:
            vehicle.zRotation = 3.1415
            if lane == 0 {
                vehicle.position = CGPoint(x: 258.25, y: scene!.frame.height+10)
            } else if lane == 1 {
                vehicle.position = CGPoint(x: 297.625, y: scene!.frame.height+10)
            }
            break
        case .left:
            vehicle.zRotation = 3.1415/2
            if lane == 0 {
                vehicle.position = CGPoint(x: scene!.frame.width+10, y: 263.4375)
            } else if lane == 1 {
                vehicle.position = CGPoint(x: scene!.frame.width+10, y: 300.9375)
            }
            break
        case .right:
            vehicle.zRotation = 3.1415*1.5
            if lane == 0 {
                vehicle.position = CGPoint(x: -10, y: 218.1875)
            } else if lane == 1 {
                vehicle.position = CGPoint(x: -10, y: 178.1875)
            }
            break
        }
        
        self.vehicles.append(vehicle)
    }
}
