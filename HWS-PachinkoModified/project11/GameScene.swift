//
//  GameScene.swift
//  project11
//
//  Created by Stanislav Makhmoudov on 17.06.2020.
//  Copyright © 2020 GennadyMakhmudov. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    var ballsLabel: SKLabelNode!
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editingMode = false {
        didSet{
            if editingMode{
                editLabel.text = "Done"
            }else{
                editLabel.text = "Edit"
            }
        }
    }
    var ballsNumber = 5 {
        didSet{
            ballsLabel.text = "Balls: \(ballsNumber)"
        }
    }
    
    var ballColor = ["ballRed", "ballBlue", "ballYellow", "ballCyan", "ballGrey", "ballGreen", "ballPurple"]
   
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLabel.text = "Balls: 5"
        ballsLabel.horizontalAlignmentMode = .right
        ballsLabel.position = CGPoint(x: 980, y: 670)
        addChild(ballsLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        


        }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(editLabel){
            editingMode.toggle()
        }else{
            if editingMode {
                //create a box
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.name = "box"
                addChild(box)
            }else{
                let ball = SKSpriteNode(imageNamed: ballColor.randomElement()!)
                   ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                   ball.physicsBody?.restitution = 0.4
                   ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = CGPoint(x: location.x, y: 750)
                   ball.name = "ball"
                   addChild(ball)
                if ballsNumber > 0 {
                    ballsNumber -= 1
                }
            }
            }
    }
    
    func makeBouncer(at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    func makeSlot(at position: CGPoint, isGood: Bool){
        let slotBase: SKSpriteNode
        let slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        }else{
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotGlow.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle:  .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode){
        if object.name == "good"{
            destroy(ball: ball)
            score += 1
            ballsNumber += 1
        }
        if object.name == "bad"{
            destroy(ball: ball)
            score -= 1
        }
        if object.name == "box"{
            object.removeFromParent()
        }
    }
    func destroy(ball: SKNode){
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles"){
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    func didBegin(_ contact: SKPhysicsContact) {
        guard let bodyA = contact.bodyA.node else {return}
        guard let bodyB = contact.bodyB.node else {return}
        if bodyA.name == "ball" {
            collision(between: bodyA, object: bodyB)
        }
        if bodyB.name == "ball"
        {
            collision(between: bodyB, object: bodyA)
        }
    }
}
