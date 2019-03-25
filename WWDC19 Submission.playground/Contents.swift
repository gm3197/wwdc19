import PlaygroundSupport
import SpriteKit

let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
let scene = InstructionScene(size: CGSize(width: 640, height: 480))

scene.scaleMode = .aspectFill
sceneView.presentScene(scene)
//sceneView.showsFPS = true
//sceneView.showsNodeCount = true

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

