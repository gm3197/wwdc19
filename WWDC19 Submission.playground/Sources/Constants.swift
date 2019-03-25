import SpriteKit
import PlaygroundSupport

public enum TrafficLightStatus {
    case green
    case yellow
    case red
}

public enum TrafficDirection {
    case up
    case down
    case left
    case right
}

public enum TrafficLane {
    case left
    case right
}

public struct Layers {
    public static let loading: CGFloat = 0
    public static let background: CGFloat = 2
    public static let cars: CGFloat = 3
    public static let explosion: CGFloat = 4
    public static let lights: CGFloat = 5
    public static let endGameText: CGFloat = 6
}

public struct PhysicsCategory {
    public static let none: UInt32 = 0
    public static let updown: UInt32 = 0b1
    public static let leftright: UInt32 = 0b10
}
