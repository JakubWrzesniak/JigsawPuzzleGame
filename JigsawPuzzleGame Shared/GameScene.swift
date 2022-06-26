//
//  GameScene.swift
//  JigsawPuzzleGame Shared
//
//  Created by Jakub Wrześniak on 12/04/2022.
//

import SpriteKit
import AVFoundation

class Puzzel: SKSpriteNode {
    var number: Int?
    var onPosition = false
    var startLocation: CGPoint?
    static var smallSize: CGSize?
    static var mediumSize: CGSize?
}

class PuzzelSpace: SKSpriteNode {
    var number: Int?
}

class GameScene: SKScene {
    var puzzels = [ [1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12], [13, 14, 15, 16]]
    var backgroundMusic: SKAudioNode!
    var timeLabel: SKLabelNode?
    var areSoundsMuted = false
    private var currentNode: Puzzel?
    private var startLocation: CGPoint?
    private let correctSoundAction = SKAction.playSoundFileNamed("correctSound.m4a", waitForCompletion: false)
    private let wrongSoundAction = SKAction.playSoundFileNamed("wrongSound.m4a", waitForCompletion: false)
    private let successSoundAction = SKAction.playSoundFileNamed("SuccessSound.wav", waitForCompletion: false)
    var timer: Timer?
    var minutes = 0
    var seconds = 0
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    @objc func fireTimer() {
        print("Timer fired!")
    }
    
    func setUpScene(){
        setUpBackground()
        setUpPuzzelsPlaces()
        setUpPuzzels()
        if let musicURL = Bundle.main.url(forResource: "BackgroundSound", withExtension: "m4a") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
        setTimer()
        setButtons()
    }
    
    func setUpBackground(){
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        addChild(background)
    }
    
    func setUpPuzzelsPlaces(){
        let puzzelPlaceWidth = view!.bounds.width / CGFloat(puzzels.capacity)
        let puzzelPlaceHeigh = view!.bounds.height / CGFloat(puzzels[0].capacity)
        let puzzelPlaceSize = min(puzzelPlaceWidth, puzzelPlaceHeigh)
        var currentHeigh = view!.bounds.maxY - puzzelPlaceSize * (CGFloat(puzzels.capacity) / 2) + puzzelPlaceSize * 0.5
        
        var imageNumber = 1
        for i in 0..<puzzels.capacity {
            var currentWidth = view!.bounds.minX - puzzelPlaceSize * (CGFloat(puzzels[i].capacity) / 2) + puzzelPlaceSize * 0.5
            for _ in 0..<puzzels[i].capacity{
                let puzzelPlace = PuzzelSpace(color: .gray, size: CGSize(width: puzzelPlaceSize, height: puzzelPlaceSize))
                puzzelPlace.size = CGSize(width: puzzelPlaceSize, height: puzzelPlaceSize)
                puzzelPlace.position = CGPoint(x: currentWidth, y: currentHeigh)
                puzzelPlace.number = imageNumber
                addChild(puzzelPlace)
                currentWidth += puzzelPlaceSize + 10
                imageNumber += 1
            }
            currentHeigh -= puzzelPlaceSize + 10
        }
    }
    
    func setUpPuzzels(){
        let flatPuzzels = puzzels.flatMap{$0}.shuffled()
        let numberOfPuzzels = flatPuzzels.count
        let halfNumberOfPuzzels = Int(numberOfPuzzels / 2)
        let puzzelWidth = view!.bounds.width / (CGFloat(numberOfPuzzels) * 0.5)
        let puzzelHeight = view!.bounds.height * 0.2
        let puzzelSize = min(puzzelWidth, puzzelHeight)
        Puzzel.smallSize = CGSize(width: puzzelSize, height: puzzelSize)
        Puzzel.mediumSize = CGSize(width: puzzelSize * 1.5, height: puzzelSize * 1.5)
        
        var currentWidth = frame.midX - (CGFloat((Double(halfNumberOfPuzzels) - 0.5) / 2) * (puzzelSize) )
        var currentHeight = frame.minY / 2;
        
        
        for i in 0 ..< halfNumberOfPuzzels {
            let puzzel = Puzzel(imageNamed: flatPuzzels[i] > 9 ? "NY_0\(flatPuzzels[i])" : "NY_00\(flatPuzzels[i])" )
            puzzel.size = CGSize(width: puzzelSize, height: puzzelSize)
            puzzel.position = CGPoint(x: currentWidth, y: currentHeight)
            puzzel.number = flatPuzzels[i]
            puzzel.startLocation = puzzel.position
            puzzel.zPosition = 2
            addChild(puzzel)
            currentWidth += (puzzelSize + 10)
        }
        
        currentHeight -= (puzzelSize + 10);
        currentWidth = frame.midX - (CGFloat((Double(halfNumberOfPuzzels) - 0.5) / 2) * (puzzelSize) )
        
        for i in (numberOfPuzzels - halfNumberOfPuzzels) ..< numberOfPuzzels {
            let puzzel = Puzzel(imageNamed: flatPuzzels[i] > 9 ? "NY_0\(flatPuzzels[i])" : "NY_00\(flatPuzzels[i])" )
            puzzel.size = CGSize(width: puzzelSize, height: puzzelSize)
            puzzel.position = CGPoint(x: currentWidth, y: currentHeight)
            puzzel.number = flatPuzzels[i]
            puzzel.startLocation = puzzel.position
            puzzel.zPosition = 2
            addChild(puzzel)
            currentWidth += (puzzelSize + 10)
        }
    }
    
    func setTimer(){
        timeLabel = SKLabelNode(fontNamed: "timer")
        timeLabel!.text = "00:00"
        timeLabel!.horizontalAlignmentMode = .right
        timeLabel!.position = CGPoint(x: frame.maxX - 150, y: frame.maxY - 100)
        timeLabel!.zPosition = 10
        addChild(timeLabel!)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { time in
            if self.seconds < 59{
                self.seconds += 1
            } else {
                self.minutes += 1
                self.seconds = 0
            }
            let timeText = String(format: "%02d", self.minutes) + ":" + String(format: "%02d", self.seconds)
            self.timeLabel?.text = timeText
        }
    }
    
    func setButtons(){
        let muteBusicButton = SKLabelNode(text: "Mute music")
        muteBusicButton.name = "MuteMusic"
        muteBusicButton.zPosition = 10
        muteBusicButton.fontColor = .green
        muteBusicButton.position = CGPoint(x: frame.minX + 150, y: frame.maxY - 100)
        addChild(muteBusicButton)
        
        let muteSounds = SKLabelNode(text: "Mute Sounds")
        muteSounds.name = "MuteSounds"
        muteSounds.zPosition = 10
        muteSounds.fontColor = .green
        muteSounds.position = CGPoint(x: frame.minX + 150, y: frame.maxY - 150)
        addChild(muteSounds)
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        setUpScene()
    }
    #endif

    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let puzzelNodes = self.nodes(at: location).filter{ node in
            return node is Puzzel
        }
        for node in puzzelNodes {
            if let puzzel = node as? Puzzel {
                if(!puzzel.onPosition){
                    self.currentNode = puzzel
                    puzzel.zPosition = 3
                    if self.startLocation == nil {
                        self.startLocation = puzzel.position
                    }
                        self.currentNode?.setMediumSize()
                }
            }
        }
        let nodes = self.nodes(at: location)
        for node in nodes {
            if node.name == "MuteMusic" {
                if self.children.contains(backgroundMusic){
                    if let node = node as? SKLabelNode{
                        node.text = "Unmute music"
                        node.fontColor = .red
                    }
                    backgroundMusic.removeFromParent()
                } else {
                    if let node = node as? SKLabelNode{
                        node.text = "Mute music"
                        node.fontColor = .green
                    }
                    addChild(backgroundMusic)
                }
            } else if node.name == "MuteSounds" {
                areSoundsMuted.toggle()
                if let node = node as? SKLabelNode{
                    node.text = areSoundsMuted ? "Unmute sound" : "Mute sound"
                    node.fontColor = areSoundsMuted ? .red : .green
                }
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        if let node = self.currentNode {
            let touchLocation = event.location(in: self)
            node.position = touchLocation
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        let puzzelSpace = self.nodes(at: location).filter{ node in
            return node is PuzzelSpace
        }
        if let puzzel = currentNode{
            if let space = puzzelSpace.first as? PuzzelSpace
                {
                   if puzzel.number == space.number{
                       if !areSoundsMuted {
                         puzzel.run(correctSoundAction)
                       }
                        puzzel.onPosition = true
                        puzzel.position = space.position
                        puzzel.size = space.size
                        puzzel.zPosition = 1
                        currentNode = nil
                        self.startLocation = nil
                        if isEndOfGame(){
                           endGame()
                        }
                        return
                   } else if !areSoundsMuted {
                       puzzel.run(wrongSoundAction)
                   }
            }
            let currentPuzzel = self.currentNode
            moveBackAnimation(currentPuzzel)
            currentNode = nil
            self.startLocation = nil
        }
    }
    
    func moveBackAnimation(_ puzzel: Puzzel?){
        if let puzzel = puzzel,
           let to = puzzel.startLocation{
            puzzel.run(SKAction.move(to: to, duration: TimeInterval.init(0.5))){
                puzzel.zPosition = 1
                puzzel.setSmallSize()
            }
        }
    }
    
    func isEndOfGame() -> Bool{
        let puzzels = self.children.filter{ node in
            if let puzzel = node as? Puzzel{
                return !puzzel.onPosition
            }
            return false
        }
        
        return puzzels.isEmpty
    }
    
    func endGame(){
        timer?.invalidate()
        backgroundMusic.run(SKAction.changeVolume(to: 0, duration: 1)){
            SKAction.removeFromParent()
            self.scene?.run(self.successSoundAction)
            let host = self.fireWorskAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                host.removeFromSuperview()
            }
        }
    }
    
    func fireWorskAnimation() -> NSView{

        let size = CGSize(width: frame.width, height: frame.height)
        let host = NSView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        self.view?.addSubview(host)

        let particlesLayer = CAEmitterLayer()
        particlesLayer.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)

        host.wantsLayer = true
        host.layer?.addSublayer(particlesLayer)
        host.layer?.masksToBounds = false

        particlesLayer.emitterShape = .point
        particlesLayer.emitterPosition = CGPoint(x: self.frame.maxX / 2, y: self.frame.midY)
        particlesLayer.emitterSize = CGSize(width: 1.0, height: self.frame.height)
        particlesLayer.emitterMode = .outline
        particlesLayer.renderMode = .additive


        let cell1 = CAEmitterCell()

        cell1.name = "Parent"
        cell1.birthRate = 5.0
        cell1.lifetime = 2.5
        cell1.velocity = 300.0
        cell1.velocityRange = 100.0
        cell1.yAcceleration = 100.0
        cell1.emissionLongitude = 90.0 * (.pi / 180.0)
        cell1.emissionRange = 45.0 * (.pi / 180.0)
        cell1.scale = 0.0
        cell1.color = NSColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        cell1.redRange = 0.9
        cell1.greenRange = 0.9
        cell1.blueRange = 0.9



        let image1_1: CGImage? = NSImage(named:"Spark").flatMap {
            var rect = CGRect(x: 0, y: 0, width: $0.size.width, height: $0.size.height)
            return $0.cgImage(forProposedRect: &rect, context: nil, hints: nil)
        }

        let subcell1_1 = CAEmitterCell()
        subcell1_1.contents = image1_1
        subcell1_1.name = "Trail"
        subcell1_1.birthRate = 45.0
        subcell1_1.lifetime = 0.5
        subcell1_1.beginTime = 0.01
        subcell1_1.duration = 1.7
        subcell1_1.velocity = 80.0
        subcell1_1.velocityRange = 100.0
        subcell1_1.xAcceleration = 100.0
        subcell1_1.yAcceleration = -350.0
        subcell1_1.emissionLongitude = 360.0 * (.pi / 180.0)
        subcell1_1.emissionRange = 22.5 * (.pi / 180.0)
        subcell1_1.scale = 0.5
        subcell1_1.scaleSpeed = 0.13
        subcell1_1.alphaSpeed = -0.7
        subcell1_1.color = NSColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor



        let image1_2: CGImage? = NSImage(named:"Spark").flatMap {
            var rect = CGRect(x: 0, y: 0, width: $0.size.width, height: $0.size.height)
            return $0.cgImage(forProposedRect: &rect, context: nil, hints: nil)
        }

        let subcell1_2 = CAEmitterCell()
        subcell1_2.contents = image1_2
        subcell1_2.name = "Firework"
        subcell1_2.birthRate = 20000.0
        subcell1_2.lifetime = 15.0
        subcell1_2.beginTime = 1.6
        subcell1_2.duration = 0.1
        subcell1_2.velocity = 190.0
        subcell1_2.yAcceleration = -80.0
        subcell1_2.emissionRange = 360.0 * (.pi / 180.0)
        subcell1_2.spin = -114.6 * (.pi / 180.0)
        subcell1_2.scale = 0.1
        subcell1_2.scaleSpeed = 0.09
        subcell1_2.alphaSpeed = -0.7
        subcell1_2.color = NSColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor

        cell1.emitterCells = [subcell1_1, subcell1_2]

        particlesLayer.emitterCells = [cell1]
        return host;
    }

}
#endif

extension Puzzel {
    func setSmallSize(){
        if let size = Puzzel.smallSize{
            self.size = size
        }
    }
    
    func setMediumSize(){
        if let size = Puzzel.mediumSize{
            self.size = size
        }
    }
}
