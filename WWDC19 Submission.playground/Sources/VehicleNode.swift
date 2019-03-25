import SpriteKit
import PlaygroundSupport

public class VehicleNode: SKSpriteNode {
    public var direction: TrafficDirection!
    public var timeWaiting: TimeInterval = 0
    
    public func lightStatus() -> TrafficLightStatus {
        switch direction! {
        case .up:
            return (scene as! TrafficScene).upLight
        case .down:
            return (scene as! TrafficScene).downLight
        case .left:
            return (scene as! TrafficScene).leftLight
        case .right:
            return (scene as! TrafficScene).rightLight
        }
    }
    
    public func recycleNode() {
        removeAllActions()
        let lane = Int.random(in: 0...1)
        switch direction! {
        case .up:
            if lane == 0 {
                position = CGPoint(x: 342, y: -10)
            } else if lane == 1 {
                position = CGPoint(x: 382.625, y: -10)
            }
            break
        case .down:
            zRotation = 3.1415
            if lane == 0 {
                position = CGPoint(x: 258.25, y: scene!.frame.height+10)
            } else if lane == 1 {
                position = CGPoint(x: 297.625, y: scene!.frame.height+10)
            }
            break
        case .left:
            zRotation = 3.1415/2
            if lane == 0 {
                position = CGPoint(x: scene!.frame.width+10, y: 263.4375)
            } else if lane == 1 {
                position = CGPoint(x: scene!.frame.width+10, y: 300.9375)
            }
            break
        case .right:
            zRotation = 3.1415*1.5
            if lane == 0 {
                position = CGPoint(x: -10, y: 218.1875)
            } else if lane == 1 {
                position = CGPoint(x: -10, y: 178.1875)
            }
            break
        }
        switch Int.random(in: 0...6) {
        case 0:
            texture = (scene as! TrafficScene).textures.textureNamed("bluecar")
            size = CGSize(width: 35, height: 37.5)
            break
        case 1:
            texture = (scene as! TrafficScene).textures.textureNamed("redcar")
            size = CGSize(width: 35, height: 37.5)
            break
        case 2:
            texture = (scene as! TrafficScene).textures.textureNamed("yellowcar")
            size = CGSize(width: 35, height: 37.5)
            break
        case 3:
            texture = (scene as! TrafficScene).textures.textureNamed("bus")
            size = CGSize(width: 28.75, height: 63.125)
            break
        case 4:
            texture = (scene as! TrafficScene).textures.textureNamed("biker")
            size = CGSize(width: 35, height: 37.5)
            break
        case 5:
            texture = (scene as! TrafficScene).textures.textureNamed("greencar")
            size = CGSize(width: 35, height: 37.5)
            break
        case 6:
            texture = (scene as! TrafficScene).textures.textureNamed("whitecar")
            size = CGSize(width: 35, height: 37.5)
            break
        default:
            texture = (scene as! TrafficScene).textures.textureNamed("bluecar")
            size = CGSize(width: 35, height: 37.5)
            break
        }
    }
    
    public func moveForward() {
        switch direction! {
        case .up:
            run(SKAction.moveTo(y: position.y+20, duration: 0.5), withKey: "moveForward")
            break
        case .down:
            run(SKAction.moveTo(y: position.y-20, duration: 0.5), withKey: "moveForward")
            break
        case .left:
            run(SKAction.moveTo(x: position.x-20, duration: 0.5), withKey: "moveForward")
            break
        case .right:
            run(SKAction.moveTo(x: position.x+20, duration: 0.5), withKey: "moveForward")
            break
        }
    }
    
    public func isPastRed() -> Bool {
        switch direction! {
        case .up:
            return position.y > 145
        case .down:
            return position.y < 335
        case .left:
            return position.x < 415.3125
        case .right:
            return position.x > 220
        }
    }
    
    public func isAtStopLine() -> Bool {
        switch direction! {
        case .up:
            return position.y > 145-5
        case .down:
            return position.y < 335+5
        case .left:
            return position.x < 415.3125+5
        case .right:
            return position.x > 220-5
        }
    }
    
    public func isBehindCar() -> Bool {
        switch direction! {
        case .up:
            return (scene?.atPoint(CGPoint(x: position.x, y: position.y+10))) != nil && (scene?.atPoint(CGPoint(x: position.x, y: position.y+10)).isKind(of: VehicleNode.self))!
        case .down:
            return (scene?.atPoint(CGPoint(x: position.x, y: position.y-10))) != nil && (scene?.atPoint(CGPoint(x: position.x, y: position.y-10)).isKind(of: VehicleNode.self))!
        case .left:
            return (scene?.atPoint(CGPoint(x: position.x-10, y: position.y))) != nil && (scene?.atPoint(CGPoint(x: position.x-10, y: position.y)).isKind(of: VehicleNode.self))!
        case .right:
            return (scene?.atPoint(CGPoint(x: position.x+10, y: position.y))) != nil && (scene?.atPoint(CGPoint(x: position.x+10, y: position.y)).isKind(of: VehicleNode.self))!
        }
    }
    
    public func isOnTopOfAnotherCar() -> Bool {
        return (scene?.atPoint(CGPoint(x: position.x, y: position.y))) != nil && (scene?.atPoint(CGPoint(x: position.x, y: position.y)).isKind(of: VehicleNode.self))!
    }
    
    public func exitScreen() {
        timeWaiting = 0
        switch direction! {
        case .up:
            run(SKAction.moveTo(y: position.y+600, duration: 3), withKey: "exitScreen")
        case .down:
            run(SKAction.moveTo(y: position.y-600, duration: 3), withKey: "exitScreen")
        case .left:
            run(SKAction.moveTo(x: position.y-800, duration: 3), withKey: "exitScreen")
        case .right:
            run(SKAction.moveTo(x: position.y+800, duration: 3), withKey: "exitScreen")
        }
    }
    
    public func shake(duration:Float) {
        let amplitudeX:Float = 8;
        let amplitudeY:Float = 4;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            // build a new random shake and add it to the list
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        
        let actionSeq = SKAction.sequence(actionsArray);
        run(actionSeq);
    }
}
