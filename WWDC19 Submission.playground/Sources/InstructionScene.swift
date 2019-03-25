import SpriteKit
import PlaygroundSupport

public class InstructionScene: SKScene {
    var background: SKSpriteNode!
    var title: SKSpriteNode!
    var button: SKSpriteNode!
    
    public override func didMove(to view: SKView) {
        background = SKSpriteNode(imageNamed: "background.png")
        addChild(background)
        background.size = CGSize(width: 640, height: 480)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        
        title = SKSpriteNode(imageNamed: "title.png")
        addChild(title)
        title.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        title.position = CGPoint(x: 220, y: 380)
        title.size = CGSize(width: title.texture!.size().width/1.6, height: title.texture!.size().height/1.6)
        title.run(SKAction.repeatForever(SKAction.sequence([.scale(by: 1.5, duration: 1),.scale(by: CGFloat(1/1.5), duration: 1)])))
        title.zRotation = CGFloat((3.1415*10)/180)
        
        button = SKSpriteNode(imageNamed: "button.png")
        addChild(button)
        button.size = CGSize(width: button.texture!.size().width/1.5, height: button.texture!.size().height/1.5)
        button.anchorPoint = CGPoint(x: 0.5, y: 0)
        button.position = CGPoint(x: size.width/2, y: 40)
        
        addRules(["1) Try to prevent cars from crashing by controlling the traffic lights.", "2) At all times, at least one light must be green.", "3) But be careful, if a car has been waiting at a red light for too long, it might get impatient and try to run the red light."])
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let node = atPoint(touches.first!.location(in: self))
        if node == button {
            view?.presentScene(TrafficScene(size: size))
        }
    }
    
    func addRules(_ rules: [String]) {
        for i in 0..<rules.count {
            addMultiLineLabel(rules[i])
        }
    }
    
    var numberOfMultiLineLabels = 0
    
    func addMultiLineLabel(_ rules: String) {
        let separators = CharacterSet.whitespacesAndNewlines
        var words = rules.components(separatedBy: separators)

        let len: Int = rules.count
        let width: Int = 50

        let totLines: Int = len / width + 1
        var cnt: Int = 0

        for _ in 0..<totLines {
            var lenPerLine: Int = 0
            var lineStr = ""

            while lenPerLine < width {
                if cnt > words.count - 1 {
                    break
                }
                lineStr = "\(lineStr) \(words[cnt])"
                lenPerLine = lineStr.count
                cnt += 1
            }

            numberOfMultiLineLabels += 1
            
            let multiLineLabel = SKLabelNode(fontNamed: "GillSans-Regular")
            addChild(multiLineLabel)
            multiLineLabel.text = lineStr
            multiLineLabel.horizontalAlignmentMode = .center
            multiLineLabel.fontSize = 20
            multiLineLabel.fontColor = .black
            multiLineLabel.position = CGPoint(x: size.width / 2, y: CGFloat(size.height / 2 + 80 - CGFloat(22 * numberOfMultiLineLabels)))
        }
    }
}
