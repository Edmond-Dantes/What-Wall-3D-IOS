//
//  GameScene.swift
//  Roly Moly
//
//  Created by Future on 10/27/14.
//  Copyright (c) 2014 Future. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit


//Dictionary to hold the corner block objects
var myCorners:[CornerBlock.cornerPosition: CornerBlock] = [:]
var myPresentationCorners:[CornerBlock.cornerPosition: CornerBlock] = [:]
    
var mySmashBlocks:[SmashBlock.blockPosition : SmashBlock] = [:]
var myPresentationSmashBlocks:[SmashBlock.blockPosition : SmashBlock] = [:]


var myPlayer:Player? = nil
var myPlayerTail:[Player] = []
var myPresentationPlayer:Player? = nil
var myPresentationTail:[Player] = []
var tailJoint:[SKPhysicsJointLimit] = []


enum CollisionType:UInt32{
    case activeWall = 0b1, staticWall = 0b10, player = 0b100, tail = 0b1000
}


enum keys{
    case left,right,up,down
}

var isKeyPressed:[keys:Bool] = [keys.left: false, .right: false, .up: false, .down: false]


var myEmitterNode:SKEmitterNode? = nil

var myGravityFieldNode = SKFieldNode()


var LEVEL:Int = 1
var STAGE:Int = 0
//var levelExitArray:[SmashBlock.blockPosition] = []



//#if os(iOS)

var myRestartLabel:SKLabelNode = SKLabelNode()
var myLevelNumberLabel:SKLabelNode = SKLabelNode()


extension SKSpriteNode{
    var center:CGPoint{
        get{
            return CGPoint(x: self.position.x - self.frame.width/2, y: self.position.y + self.frame.height/2)
        }
        set{
            self.position = CGPoint(x: newValue.x + self.frame.width/2, y: newValue.y - self.frame.height/2)
        }
    }
    
}


private let MATH_PI:CGFloat = CGFloat(M_PI)

var SPEED_PERCENTAGE:CGFloat = 1//0.5//1//0.25

let EASY_SETTING:CGFloat = 0.5
let HARD_SETTING:CGFloat = 1
let ULTRA_HARD_SETTING:CGFloat = 1

enum difficultySetting{
    case easy, hard, ultraHard
}
var gameDifficultySetting:difficultySetting = .hard


/*private let*/ var CONSTANT_WALLSPEED:CGFloat = 1000 * SPEED_PERCENTAGE //must be changed with SPEED_PERCENTAGE


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var myPlayerNodeCopy:SCNNode! = SCNNode()
    
    let centerNode = SKNode()
    
    let gameFrameCenter = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
    var myTailGravityFieldNode = SKFieldNode()
    var myGravityFieldNode = SKFieldNode()
    var myEmitterNode:SKEmitterNode? = nil
    
    private var maxJointLimit:CGFloat{
        get{
            return (gameFrame.width/2 - cornerBlockFrame.width - myPlayer!.radius) / 2
        }
        set{
            //
        }
    }
    
    //private let CONSTANT_WALLSPEED = 1000
    var currentStage:Int = 0 //updated in stageUpLevelUp function
    private var level:Int = 1//60
    /*private*/ var playerLives:Int = 9
    /*private*/ let playerLivesMAX:Int = 9
    private var stageCount:Int = 0
    private let entranceTime: NSTimeInterval = 0.5 / NSTimeInterval(SPEED_PERCENTAGE)
    
    private var exitBlock: SmashBlock.blockPosition = SmashBlock.blockPosition.bottomLeft
    private let exitBlockColor: SKColor = SKColor.blueColor()
    private let wallColor: SKColor = SKColor.yellowColor()
    private let smashingColor: SKColor = SKColor.redColor()
    private let cornerColor: SKColor = SKColor.blueColor()
    
    private var hasCenterJointLogic:Bool = false//true
    /*private*/ var hasWorldMovement:Bool = false//true
    /*private*/ var isFirstRound: Bool = true //*****don't change value
    private var isFirstRoundStarted: Bool = false //*****don't change value
    /*private*/ var isEdgeHitDeathOn: Bool = false //true //false // *** used for the Ultra_Hard_Setting
    private var playerScore:Int = 0
    private var isPlayerTouched: Bool = false //*****don't change value
    private var isTrapWallPaused: Bool = false//true //change to true to pause the wall movement
    
    /*private*/ var isMovingToNextArea: Bool = false
    private var islevelChange:Bool = false
    var isSlowedDown:Bool = false
    
    let controller:JoyStick = JoyStick()
    
    private var WALLSPEED:CGFloat = CONSTANT_WALLSPEED
    private let DEATHVELOCITY:CGFloat = 900
    private var smashBlockStatus: SmashBlock.activity = .waiting
    private var smashStatusChanged: Bool = false
    private var activeSmashBlock: SmashBlock.blockPosition? = nil
    private var oldSmashBlock: SmashBlock.blockPosition? = nil
    private var arrayOfBlocks: [SmashBlock.blockPosition] = SmashBlock.random8array()
    private var restingSmashBlockPosition: CGPoint? = nil
    private var pauseSmashBlockLogic:Bool = false
    
    /*private*/ var deltaTime: CFTimeInterval = 0.0
    /*private*/ var lastUpdatedTime: CFTimeInterval = 0.0
    private var wallTimer: CFTimeInterval = 0.0
    
    /*private*/ var deathTimer: CFTimeInterval = 0.0
    
    var stunTime:CFTimeInterval = 0.1
    
    private var playerHitAndDirection = (hit: false, vertical: false)
    
    
    private var world = SKNode()
    
    

    
    override init(size: CGSize) {
        super.init(size: size)//override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
        self.backgroundColor = SKColor.clearColor()
        
        myLevelNumberLabel.text = "LEVEL \(LEVEL)";
        
        if myPlayer == nil{
            
        
        //Level # textbox
        let levelNumberView = SKLabelNode(fontNamed: "Chalkduster")
        
        levelNumberView.fontSize = 20//65
        levelNumberView.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - cornerBlockFrame.height)
        levelNumberView.fontColor = SKColor.whiteColor()
        levelNumberView.alpha = 0.5
        levelNumberView.hidden = false //true
        myLevelNumberLabel = levelNumberView
        myLevelNumberLabel.name = "world"
        myLevelNumberLabel.zPosition = -100
        world.addChild(myLevelNumberLabel)
            
        LEVEL = self.level
        myLevelNumberLabel.text = "LEVEL \(LEVEL)"
/************/
            myLevelNumberLabel.hidden = true
/************/
        //Single smash trap box area contained in a SKSpriteNode
        
        
        //Dictionary to hold the corner block objects
        myCorners = [
            CornerBlock.cornerPosition.leftTop: CornerBlock(cornerPos: .leftTop, color: self.cornerColor),
            .leftBottom: CornerBlock(cornerPos: .leftBottom, color: self.cornerColor),
            .rightTop: CornerBlock(cornerPos: .rightTop, color: self.cornerColor),
            .rightBottom: CornerBlock(cornerPos: .rightBottom, color: self.cornerColor)
        ]
        
        myPresentationCorners = [
            CornerBlock.cornerPosition.leftTop: myCorners[.leftTop]!.clone(),
            .leftBottom: myCorners[.leftBottom]!.clone(),
            .rightTop: myCorners[.rightTop]!.clone(),
            .rightBottom: myCorners[.rightBottom]!.clone()
        ]
        
        //for-in loop to add the corners to the scene
        for (position ,corner) in myCorners {
            self.addChild(corner)
            world.addChild( myPresentationCorners[position]! )
        }
        
        
        //---------------------
        //smashing block objects
      
        
        //Dictionary to hold the SMASH block objects
        let smashBlockArray = SmashBlock.array
        for bPosition in smashBlockArray{
            mySmashBlocks[bPosition] =  SmashBlock(blockPos: bPosition, color: self.wallColor)
        myPresentationSmashBlocks[bPosition] = mySmashBlocks[bPosition]!.clone()
        }
        
        for (position ,smashBlock) in mySmashBlocks {
            self.addChild(smashBlock)
            self.physicsWorld.addJoint(smashBlock.slidingJoint)
            world.addChild(myPresentationSmashBlocks[position]!)
        }
        self.activeSmashBlock = arrayOfBlocks[blockArrayCounter]
        print( "\(self.activeSmashBlock!.rawValue)")
        
        
        
        
        //-------------------
        // Load Player
        myPlayer = Player()
        if let player = myPlayer{
            let radius = player.radius
            //self.addChild(player)
            myPresentationPlayer = player.clone()
            //world.addChild(myPresentationPlayer!)
            myPlayerTail = []
            myPresentationTail = []
            if playerLivesMAX > 1{
                for life in 0...(playerLivesMAX - 2){
                    myPlayerTail.append(Player(r: radius))
                    myPresentationTail.append(myPlayerTail[life].clone(radius))
                }
            }
            
           
            
            centerNode.position = self.gameFrameCenter
            centerNode.physicsBody = SKPhysicsBody(circleOfRadius: 5)
            centerNode.physicsBody!.categoryBitMask = 0x0
            centerNode.physicsBody!.collisionBitMask = 0x0
            centerNode.physicsBody!.contactTestBitMask = 0x0
            centerNode.physicsBody!.dynamic = false
            if hasCenterJointLogic{
                self.addChild(centerNode)
            }
            else if !hasCenterJointLogic{
                myPlayer!.addChild(centerNode)
                centerNode.position = CGPoint(x: 0, y: 0)
            }
            
            
            
            
            
            }
            myPlayer!.hidden = true
            for element in myPlayerTail{
                element.hidden = true
            }
        
        
        //Contact and Collison Delegate setting
        physicsWorld.contactDelegate = self
        
        //Load view Text for restart
        
        let restartView = SKLabelNode(fontNamed: "Chalkduster")
        
        //restartView.fontName = "Chalkduster"
        restartView.fontSize = 20//65
        restartView.text = "START";
        //restartView.s frame = self.view!.frame//CGRect(x: 25, y: 100, width: 500, height: 500)
        //myLabel.fontSize = 65;
        restartView.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        //restartView.backgroundColor = Color.clearColor()
        restartView.fontColor = SKColor.whiteColor()
        // myRestartView.center = self.view.convertPoint(CGPoint(x: gameFrame.width/2, y: gameFrame.height/2), toView: myRestartView)
        //skView.addSubview(myRestartView)
        //restartView.zPosition = 1000
            
/************/
        restartView.hidden = true
/************/
        
        myRestartLabel = restartView
        myRestartLabel.name = "world"
        self.addChild(restartView)
        
            
            //-------------------
            // Load Gravity
            self.physicsWorld.gravity = CGVector(dx: 0*9.8, dy: 0*9.8)
            
            let gravityField = SKFieldNode.radialGravityField()
            gravityField.position = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
            gravityField.strength = 9.8 * Float(SPEED_PERCENTAGE)
            gravityField.falloff = 0
            gravityField.categoryBitMask = CollisionType.player.rawValue
            myGravityFieldNode = gravityField
            self.addChild(gravityField)
            
            let tailGravity = SKFieldNode.radialGravityField()
            if hasCenterJointLogic{
                tailGravity.position = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
            }else if !hasCenterJointLogic{
                tailGravity.position = CGPoint(x: 0, y: 0)
            }
            
            tailGravity.strength = 9.8 * Float(SPEED_PERCENTAGE)
            tailGravity.falloff = 0
            tailGravity.categoryBitMask = CollisionType.tail.rawValue
            myTailGravityFieldNode = tailGravity
            
            myPlayer!.addChild(myTailGravityFieldNode)
            
        
        //Load Particle Emmitter
        let burstPath = NSBundle.mainBundle().pathForResource("MyParticle",
            ofType: "sks")
        
        let burstNode = NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath!)
            as! SKEmitterNode
        
        myEmitterNode = burstNode
        
        if let burst = myEmitterNode{
            
            burst.position = CGPoint(x: 0, y: 0)
            burst.fieldBitMask = CollisionType.player.rawValue
            
        }
        
        //my Maze *************
                myMaze = nil
                myMaze = Maze(level: CGFloat(self.level))
                self.currentStage = myMaze!.startPoint
            
        
        //LOAD WORLD
        
        world.name = "world"
        self.addChild(world)
        for node in self.children {
            let child = node 
            if child.name != "world"{
                child.hidden = true
            }
        }
        world.hidden = false
        myEmitterNode!.hidden = false
        
            
        
        }
        self.reloadSceneTime()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func slowDownSceneTime(){
        WALLSPEED /= 100
        myGravityFieldNode.strength = 0
        world.runAction(SKAction.fadeAlphaTo(0.5, duration: 1))
        self.isSlowedDown = true
        
        myTailGravityFieldNode.strength /= 5
        for tailPiece in myPlayerTail{
            let tailVelocity = tailPiece.physicsBody!.velocity
            tailPiece.physicsBody!.velocity = CGVector(dx: tailVelocity.dx / 10, dy: tailVelocity.dy / 10)
        }
    }
    
    private func reloadSceneTime() {
        WALLSPEED = CONSTANT_WALLSPEED
        myGravityFieldNode.strength = 9.8 * Float(SPEED_PERCENTAGE)
        mySmashBlocks[self.exitBlock]!.color = self.wallColor
        // ********************
        // sets exitBlock as the correct exit if in the correct path, otherwise ~random
        self.exitBlock = myMaze!.stageExitsArray[currentStage]![0] //Exits include the inbetween paths

        // ???need to test if the above is necessary???
        // ********************
        
        arrayOfBlocks.shuffle()
        
        world.runAction(SKAction.fadeInWithDuration(0))
        wallTimer = 0
        smashBlockStatus = .waiting
        smashStatusChanged = true
        
        
        reloadOriginalTrapPositions(0) // 0 is the SKAction time duration
        
        
    }
    
    func updateLevelMaze(level:Int){
        myMaze = nil
        myMaze = Maze(level: CGFloat(level))
        self.currentStage = myMaze!.startPoint
    }
    
    private func addJoint(a:SKPhysicsBody, b:SKPhysicsBody, limitLength:CGFloat)-> SKPhysicsJointLimit{
        var temp:SKPhysicsJointLimit = SKPhysicsJointLimit()
        if hasCenterJointLogic{
            let tempJoint = SKPhysicsJointLimit.jointWithBodyA(a, bodyB: b, anchorA: a.node!.position, anchorB: b.node!.position)
            tempJoint.maxLength = limitLength
            
            temp = tempJoint
        }else if !hasCenterJointLogic{
            let tempJoint = SKPhysicsJointLimit.jointWithBodyA(a, bodyB: b, anchorA: self.convertPoint(a.node!.position, fromNode: myPlayer!), anchorB: self.convertPoint(b.node!.position, fromNode: myPlayer!))
            tempJoint.maxLength = limitLength
            
            temp = tempJoint
        }
        return temp
    }
    
    
    
    private func reloadOriginalTrapPositions(duration:NSTimeInterval){
        //---------------------
        //corner blocks
        for (_ ,corner) in myCorners {
            
            corner.runAction(SKAction.moveTo(corner.originalPosition, duration: duration))
        }
        
        
        //---------------------
        //smashing block objects
        
        for (blockLocation ,smashBlock) in mySmashBlocks {
            
            smashBlock.runAction(SKAction.moveTo(smashBlock.orginalPosition, duration: duration))
            myPresentationSmashBlocks[blockLocation]!.runAction(SKAction.moveTo(myPresentationSmashBlocks[blockLocation]!.orginalPosition, duration: duration))
            
            smashBlock.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            smashBlock.color = self.wallColor
        }
        
    }
    
    
    var isNeutralCamera:Bool = false
    var hasEnteredNeutral:Bool = false
    
    private func JoyStickTouchLogic()->CGVector{
        
        let pixelBuffer:CGFloat = 0
        let speed:CGFloat = 5 * SPEED_PERCENTAGE * myPlayer!.timesTheWeight//fix this
        
        //--------------------------
        //------JoyStick Logic------
        //--------------------------
        
        
        var targetPosition = CGPoint()
        let player = myPlayer!
        
        
        if controller.isChangedDirection == true{
            myPlayer!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            controller.isChangedDirection = false
            myGravityFieldNode.strength = 0
            
        }
        
        if controller.joyStickDirection == .neutral {//neutral
            targetPosition = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
            
            
        }
        else if controller.joyStickDirection == .right{//right
            //add jointStick position
            targetPosition = CGPoint(x: gameFrame.width - cornerBlockFrame.width - pixelBuffer - player.radius, y: gameFrame.height/2)
            
        }
        else if controller.joyStickDirection == .left{//left
            
            targetPosition = CGPoint(x: cornerBlockFrame.width + pixelBuffer + player.radius, y: gameFrame.height/2)
            
            
            
        }
        else if controller.joyStickDirection == .up{//up
            //add jointStick position
            targetPosition = CGPoint(x: gameFrame.width/2, y: gameFrame.height - cornerBlockFrame.height - pixelBuffer - player.radius)
            
            
        }
        else if controller.joyStickDirection == .down{//down
            //add jointStick position
            targetPosition = CGPoint(x: gameFrame.width/2, y: cornerBlockFrame.height + pixelBuffer + player.radius)
            
        }
        
        let c:CGFloat = sqrt( pow(targetPosition.x - player.position.x , 2) + pow(targetPosition.y - player.position.y, 2) )
        let unitX:CGFloat = targetPosition.x - player.position.x
        let unitY:CGFloat = targetPosition.y - player.position.y
        
        
        if CGRect(x: targetPosition.x - cornerBlockFrame.width, y: targetPosition.y - cornerBlockFrame.height, width: cornerBlockFrame.width * 2, height: cornerBlockFrame.height * 2 ).contains(player.position) {
            if controller.joyStickDirection == .neutral{
                myGravityFieldNode.strength = 9.8 * Float(SPEED_PERCENTAGE)
                if CGRect(x: targetPosition.x - cornerBlockFrame.width/4, y: targetPosition.y - cornerBlockFrame.height/4, width: cornerBlockFrame.width/2, height: cornerBlockFrame.height/2 ).contains(player.position){
                    player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    
                    player.position = targetPosition
                    if !isNeutralCamera{
                        hasEnteredNeutral = true
                        isNeutralCamera = true
                    }
                    
                    myGravityFieldNode.strength = 0
                }
            }else{
                player.position = targetPosition
                player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                controller.joyStickDirection = .neutral
                myGravityFieldNode.strength = 9.8 * Float(SPEED_PERCENTAGE)
            }
            
        }
        else {
            isNeutralCamera = false
            
            if controller.joyStickDirection != .neutral{
                myGravityFieldNode.strength = 0
                player.physicsBody!.applyForce(CGVector(dx: speed * unitX / c, dy: speed * unitY / c))
                print(" force =  \(speed * unitX / c), \(speed * unitY / c)")
            }else if controller.joyStickDirection == .neutral{ //delete if necessary
                myGravityFieldNode.strength = 9.8 * Float(SPEED_PERCENTAGE)
            }
            
        }
        
        return CGVector(dx: unitX / c, dy: unitY / c)
        
    }
    
    #if os(iOS)
    func handleSwipe(gestureRecognize: UIGestureRecognizer){
        
            let swipeDirection:UISwipeGestureRecognizerDirection = (gestureRecognize as! UISwipeGestureRecognizer).direction
            
            if self.isMovingToNextArea || myPlayer!.isStunned && myPlayer!.isAlive{
                self.controller.joyStickDirection = .neutral
                self.controller.isChangedDirection = false
                isKeyPressed[.up] = false
                isKeyPressed[.right] = false
                isKeyPressed[.down] = false
                isKeyPressed[.left] = false
                return
            }
        
            switch swipeDirection{
            case UISwipeGestureRecognizerDirection.Up://up
                if self.controller.joyStickDirection != .up && !isKeyPressed[.up]!{
                    self.controller.joyStickDirection = .up
                    self.controller.isChangedDirection = true
                    isKeyPressed[.up] = true
                }
            case UISwipeGestureRecognizerDirection.Right://right
                if self.controller.joyStickDirection != .right && !isKeyPressed[.right]!{
                    self.controller.joyStickDirection = .right
                    self.controller.isChangedDirection = true
                    isKeyPressed[.right] = true
                }
            case UISwipeGestureRecognizerDirection.Down://down
                if self.controller.joyStickDirection != .down && !isKeyPressed[.down]!{
                    self.controller.joyStickDirection = .down
                    self.controller.isChangedDirection = true
                    isKeyPressed[.down] = true
                }
            case UISwipeGestureRecognizerDirection.Left://left
                if self.controller.joyStickDirection != .left && !isKeyPressed[.left]!{
                    self.controller.joyStickDirection = .left
                    self.controller.isChangedDirection = true
                    isKeyPressed[.left] = true
                }
            default:
                return
                
            }
        
    }

    
    
    #elseif os(OSX)
         override func keyDown(theEvent: NSEvent) {
            Swift.print("KeyDown - GameScene")
            let key = theEvent.keyCode
            if isMovingToNextArea || myPlayer!.isStunned && myPlayer!.isAlive{
                controller.joyStickDirection = .neutral
                controller.isChangedDirection = false
                isKeyPressed[.up] = false
                isKeyPressed[.right] = false
                isKeyPressed[.down] = false
                isKeyPressed[.left] = false
                return
            }
                switch key{
                case 126://up
                    if controller.joyStickDirection != .up && !isKeyPressed[.up]!{
                        controller.joyStickDirection = .up
                        print("\(key) up")
                        controller.isChangedDirection = true
                        isKeyPressed[.up] = true
                    }
                    if let player = myPlayer{
                        if !player.isDying && (!player.isAlive || isFirstRound){
                            
                        }
                    }
                case 124://right
                    if controller.joyStickDirection != .right && !isKeyPressed[.right]!{
                        controller.joyStickDirection = .right
                        print("\(key) right")
                        controller.isChangedDirection = true
                        isKeyPressed[.right] = true
                    }
                case 125://down
                    if controller.joyStickDirection != .down && !isKeyPressed[.down]!{
                        controller.joyStickDirection = .down
                        print("\(key) down")
                        controller.isChangedDirection = true
                        isKeyPressed[.down] = true
                    }
                case 123://left
                    if controller.joyStickDirection != .left && !isKeyPressed[.left]!{
                        controller.joyStickDirection = .left
                        print("\(key) left")
                        controller.isChangedDirection = true
                        isKeyPressed[.left] = true
                    }
                case 46://M
                    //do nothing
                    print("This should show the map")
                    return
                case 49://space bar
    
                    self.isFirstRound = false
    
                    
                    if let player = myPlayer{
                        if !player.isDying && !player.isAlive{
                            self.playerComeBackToLife(player)
                            
                        }
                    }
                    
                default:
                    print("\(key)")
                    return
                    
                }
    
            
            
            
            
        }
        
        override func keyUp(theEvent: NSEvent) {
    
            let key = theEvent.keyCode
    
            
            if isMovingToNextArea || myPlayer!.isStunned && myPlayer!.isAlive{
                
                controller.joyStickDirection = .neutral
                controller.isChangedDirection = false
                isKeyPressed[.up] = false
                isKeyPressed[.right] = false
                isKeyPressed[.down] = false
                isKeyPressed[.left] = false
                
                return
            }
            
            switch key{
            
            
            case 126://up
                isKeyPressed[.up] = false
                
            case 124://right
                isKeyPressed[.right] = false
                
            case 125://down
                isKeyPressed[.down] = false
                
            case 123://left
                isKeyPressed[.left] = false

            default:
                break
            }
            
            
        }
        
    #endif
        
        
    
    
    private func playerIsAlive() -> Bool{
        
        var playerIsAlive:Bool = false
        
        for kid in self.children{
            if let player = myPlayer{
                if player == kid as? Player {
                    playerIsAlive = true
                }
            }
            
        }
        return playerIsAlive
    }
    
    private func playerDies(message: String){
        
        //if
        
        
        print(message)
        
        if let player = myPlayer{
            
            player.isAlive = false
            player.isDying = true
            player.justDied = true
            player.contactActive = false
            
            for tailPiece in myPlayerTail{
                tailPiece.deathVelocity = tailPiece.physicsBody!.velocity
            }
            for tail in tailJoint{
                self.physicsWorld.removeJoint(tail)
            }
            tailJoint = []
            
            
            player.removeFromParent()
            myPresentationPlayer!.removeFromParent()
            
            
        }
        
    }
    
    func playerComeBackToLife(player: Player){
        
        if let player = myPlayer{
            
            player.isAlive = true
        }
        world.runAction(SKAction.fadeAlphaTo(1.0, duration: 0))
        
        
    }
    
    private func smashBlockEdgeHit(player: Player) -> Bool{
        
        
        var died = false
        var smashSpeed:CGFloat = 5 * SPEED_PERCENTAGE //WALLSPEED
        var sign:CGFloat = -1
        
        let pixelBuffer:CGFloat = 2
        
        if self.contactSmashStatus == .returning{
            sign = -sign
        }
        
        func speed(wallSpeed: CGVector){
            player.physicsBody!.applyImpulse(wallSpeed)
        }
        
        
        if let direction = player.hitDirection{
            
            print("\(player.cornerHitPosition!.x), \(player.cornerHitPosition!.y)")
            
            let unitY:CGFloat = 0.5
            let unitX:CGFloat = 0.5
            let r:CGFloat = 1
            
            switch direction{
                
            case .leftTop:
                if player.cornerHitPosition!.y <= gameFrame.height/2 + pixelBuffer{
                    sign = -sign
                    
                    speed(CGVector(dx: sign * smashSpeed * unitX / r, dy: -smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .leftBottom:
                if player.cornerHitPosition!.y >= gameFrame.height/2 - pixelBuffer{
                    sign = -sign
                    
                    speed(CGVector(dx: sign * smashSpeed * unitX / r, dy: smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .rightTop:
                if player.cornerHitPosition!.y <= gameFrame.height/2 + pixelBuffer{
                    
                    speed(CGVector(dx: sign * smashSpeed * unitX / r, dy: -smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .rightBottom:
                if player.cornerHitPosition!.y >= gameFrame.height/2 - pixelBuffer{
                    
                    speed(CGVector(dx: sign * smashSpeed * unitX / r, dy: smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .topLeft:
                if player.cornerHitPosition!.x >= gameFrame.width/2 - pixelBuffer{
                    
                    speed(CGVector(dx: smashSpeed * unitX / r, dy: sign * smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .topRight:
                if player.cornerHitPosition!.x <= gameFrame.width/2 + pixelBuffer{
                    
                    speed(CGVector(dx: -smashSpeed * unitX / r, dy: sign * smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .bottomLeft:
                if player.cornerHitPosition!.x >= gameFrame.width/2 - pixelBuffer{
                    sign = -sign
                    
                    speed(CGVector(dx: smashSpeed * unitX / r, dy: sign * smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
            case .bottomRight:
                if player.cornerHitPosition!.x <= gameFrame.width/2 + pixelBuffer{
                    
                    sign = -sign
                    
                    speed(CGVector(dx: -smashSpeed * unitX / r, dy: sign * smashSpeed * unitY / r))
                    print("corner impulse")
                    died = true
                }
                
            }
            if died && (smashBlockStatus == .smashing || smashBlockStatus == .returning)  {
                if isEdgeHitDeathOn || player.hitCount >= 2{
                    playerDies("DIEDEDED")
                    player.deathPosition = player.cornerHitPosition!
                }
                else{
                    died = false
                    player.isStunned = true
                    isNeutralCamera = false
                    controller.joyStickDirection = .neutral
                    controller.isChangedDirection = false
                    isKeyPressed[.up] = false
                    isKeyPressed[.right] = false
                    isKeyPressed[.down] = false
                    isKeyPressed[.left] = false
                    myPlayer!.runAction(SKAction.waitForDuration(self.stunTime * CFTimeInterval(SPEED_PERCENTAGE))){
                        player.isStunned = false
                    }
                }
            }
            player.hitDirection = nil
            player.cornerHitPosition = nil
            
            
            
        }
        
        return died
    }
    
    
    private func updatePlayerAfterPhysics(){
        
        var sign:CGFloat = -1
        
        if self.smashBlockStatus == .returning{
            sign = -sign
        }
        
        
        
        if let player = myPlayer{
            
            if player.position.x < cornerBlockFrame.width + player.radius {
                player.position.x = cornerBlockFrame.width + player.radius
            }
            else if player.position.x > gameFrame.width - cornerBlockFrame.width - player.radius{
                player.position.x = gameFrame.width - cornerBlockFrame.width - player.radius
            }
            
            if player.position.y < cornerBlockFrame.height + player.radius{
                player.position.y = cornerBlockFrame.height + player.radius
            }
            else if player.position.y > gameFrame.height - cornerBlockFrame.height - player.radius{
                player.position.y = gameFrame.height - cornerBlockFrame.height - player.radius
            }
            
            self.smashBlockEdgeHit(player)
            if player.isDying{
                
                if let burst = myEmitterNode{
                    if player.deathPosition.x < cornerBlockFrame.width + player.radius {
                        player.deathPosition.x = cornerBlockFrame.width + player.radius
                    }
                    else if player.deathPosition.x > gameFrame.width - cornerBlockFrame.width - player.radius{
                        player.deathPosition.x = gameFrame.width - cornerBlockFrame.width - player.radius
                    }
                    
                    if player.deathPosition.y < cornerBlockFrame.height + player.radius{
                        player.deathPosition.y = cornerBlockFrame.height + player.radius
                    }
                    else if player.deathPosition.y > gameFrame.height - cornerBlockFrame.height - player.radius{
                        player.deathPosition.y = gameFrame.height - cornerBlockFrame.height - player.radius
                    }
                    
                    self.updateWorldMovement()
                    if player.justDied{
                        burst.position = player.deathPosition
                        print("2 death: \(player.deathPosition)")
                        
                        myGravityFieldNode.position = self.convertPoint(myGravityFieldNode.position, fromNode: self.world)
                        
                        print("1 gravity: \(myGravityFieldNode.position), world: \(self.world.position)")
                        
                        myTailGravityFieldNode.removeFromParent()
                        self.addChild(myTailGravityFieldNode)
                        myTailGravityFieldNode.position = gameFrameCenter
                        
                        for tailPiece in myPlayerTail{
                            tailPiece.position = self.convertPoint(tailPiece.position, fromNode: myPlayer!)
                            tailPiece.removeFromParent()
                            self.addChild(tailPiece)
                            tailPiece.physicsBody!.velocity = tailPiece.deathVelocity
                        }
                        
                        for (index, tailPiece) in myPresentationTail.enumerate(){
                            if index <= playerLives - 2{
                                tailPiece.removeFromParent()
                                self.world.addChild(tailPiece)
                            }
                        }
                        
                        //fixes start of the scene explosion problem //search myEmitterNode
                        if myEmitterNode!.parent == nil{
                            self.world.addChild(burst)
                            burst.targetNode = self
                        }
                        burst.resetSimulation()
                        if playerLives > 1{
                            playerLives -= 1
                        }else { //player Game OVER!!!
                            //add GAME OVER logic
                            
                            isGameOver = true
                        
                        
                        
                        
                        }
                        player.justDied = false
                        
                        
                    }
                    
                }
                
            }
            
            
            
        }
        
        
    }
    
    private func updatePresentationLayer(){
    
        if myPlayer!.isDying{
         //   return
        }
        //for-in loop to add the corners to the scene
        for (position ,corner) in myCorners {
            myPresentationCorners[position]!.position = corner.position
        }
        
        
        //---------------------
        //smashing block objects
        
        
        //Dictionary to hold the SMASH block objects
        let smashBlockArray = SmashBlock.array
        for bPosition in smashBlockArray{
            myPresentationSmashBlocks[bPosition]!.position = mySmashBlocks[bPosition]!.position
            myPresentationSmashBlocks[bPosition]!.color = mySmashBlocks[bPosition]!.color
        }
        
        myPresentationPlayer!.position = myPlayer!.position
        for (index, element) in myPresentationTail.enumerate(){
            element.position = myPlayerTail[index].position
        }
    
    }
    
    private func updateWorldMovement(){
        if !hasWorldMovement{
            return
        }
        
        var playPos = myPresentationPlayer!.position
        if !myPlayer!.isAlive{
            playPos = myPlayer!.deathPosition
        }
        
        let centerPoint = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
        let differenceVector = CGPoint(x: centerPoint.x - playPos.x, y: centerPoint.y - playPos.y)
        
        
        
        self.world.position = CGPoint(x: differenceVector.x, y: differenceVector.y)
    }
    
    
    private func updatePlayer(){
        
        centerNode.position = CGPoint(x: 0, y: 0)
        
        var isChild = false
        
        for child in self.children{
            if let player = myPlayer{
                if player == child as? Player {
                    isChild = true
                }
            }
        }
        
        if isMovingToNextArea{
            isChild = true
        }
        
        if let player = myPlayer{
            
            
            if isChild{
                if !player.isAlive{
                    //----add code if necessary---
                    
                    
                    
                    if player.isDying{
                        //----add code if necessary---
                        
                        
                    }
                }
                else if player.isAlive{
                    //----add code if necessary---
                    
                    JoyStickTouchLogic()
                    
                    myRestartLabel.text = "\(playerScore)"
                    
                    //************
                    // disconnect from the tail if touched by the active wall
                    let limitLength = (gameFrame.width/2 - cornerBlockFrame.width - myPlayer!.radius) / CGFloat(self.playerLives)
                    if hasCenterJointLogic{
                        if player.contactActive{
                            let playerJoints = player.physicsBody!.joints
                            for joint in playerJoints{
                                self.physicsWorld.removeJoint(joint)
                                tailJoint.removeLast()
                            }
                        }else{
                            let playerJoints = player.physicsBody!.joints
                            if playerJoints.isEmpty{
                                let lastTailNodeIndex:Int = self.playerLives - 2
                                let playerNodeJoint = addJoint(myPlayerTail[lastTailNodeIndex].physicsBody! , b: myPlayer!.physicsBody!, limitLength: limitLength)
                                tailJoint.append(playerNodeJoint)
                            }
                        }
                    }else if !hasCenterJointLogic{
                        //break
                    }
                    //*************
                    
                   
                    
                }
                
            }
            else if !isChild{
                
                if player.isAlive{
                    
                    self.reloadSceneTime()
                    
                    //clear tail pieces first then add back based on the lives
                    for tailPiece in myPlayerTail{
                        if tailPiece.parent != nil{
                            tailPiece.removeFromParent()
                        }
                    }
                    for tailPiece in myPresentationTail{
                        if tailPiece.parent != nil{
                            tailPiece.removeFromParent()
                        }
                    }
                    //adding player and tail back
                    self.addChild(player)
                    world.addChild(myPresentationPlayer!)
                    myTailGravityFieldNode.removeFromParent()
                    player.addChild(myTailGravityFieldNode)
                    myTailGravityFieldNode.position = CGPoint(x: 0, y: 0)
                    
                    if playerLives > 1{
                        for tailIndex in 0...playerLives - 2{
                            
                            let tailPiece = myPlayerTail[tailIndex]
                            if tailPiece.parent == nil{
                                player.addChild(tailPiece)
                            }
                            
                            let presentationTailPiece = myPresentationTail[tailIndex]
                            if presentationTailPiece.parent == nil{
                                myPresentationPlayer!.addChild(presentationTailPiece)
                            }
                        }
                    }
                    
                    
                    player.position = player.originalPosition
                    player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    for (index, tailPiece) in myPlayerTail.enumerate(){
                        tailPiece.position = tailPiece.originalPosition
                        if !hasCenterJointLogic && playerLives > 1{
                            //add logic fix this
                            let MATH_PI:CGFloat = CGFloat(M_PI)
                            let unitCirleRadians:CGFloat = 2 * MATH_PI / CGFloat(self.playerLives - 1)
                            let angle:CGFloat = CGFloat(index) * unitCirleRadians
                            tailPiece.position = CGPoint(x: cos(angle) * maxJointLimit, y: sin(angle) * maxJointLimit )
                            
                        }
                        tailPiece.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    }
                    //************
                    self.connectPlayerJoints()
                    //************
                    
                    
                    player.hitCount = 0
                    player.contactActive = false
                    player.contactStatic = false
                    controller.joyStickDirection = .neutral
                    isPlayerTouched = false
                    myGravityFieldNode.position = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
                    
                    
                    
                }
                else if !player.isAlive{
                    
                    myTailGravityFieldNode.position = gameFrameCenter
                    
                    if player.isDying{
                        
                        //break
                    }
                    else{
                        
                        if isGameOver{
                            myRestartLabel.text = "START"
                        }else{
                            myRestartLabel.text = "RESTART"
                        }
                        playerScore = 0
                        myGravityFieldNode.strength = 9.8 * Float(SPEED_PERCENTAGE)
                        myTailGravityFieldNode.strength = 9.8 * Float(SPEED_PERCENTAGE)
                        
                    }
                    
                    
                }
                
                
                
                
            }
        }
        
        
        
        
        
    }
    
    private func connectPlayerJoints(){
        tailJoint = []
        let limitLength = (gameFrame.width/2 - cornerBlockFrame.width - myPlayer!.radius) / CGFloat(self.playerLives)
        
        if self.hasCenterJointLogic {
            
            if self.playerLives < 2{
                let joint = addJoint(centerNode.physicsBody!, b: myPlayer!.physicsBody!, limitLength: limitLength)
                tailJoint.append(joint)
            }else{
                let centerNodeJoint = addJoint(centerNode.physicsBody!, b: myPlayerTail[0].physicsBody!, limitLength: limitLength)
                tailJoint.append(centerNodeJoint)
                
                if self.playerLives > 2{
                    for index in 1...self.playerLives - 2{
                        let joint = addJoint(myPlayerTail[index - 1].physicsBody!, b: myPlayerTail[index].physicsBody!, limitLength: limitLength)
                        tailJoint.append(joint)
                    }
                }
                let lastTailNodeIndex:Int = self.playerLives - 2
                let playerNodeJoint = addJoint(myPlayerTail[lastTailNodeIndex].physicsBody! , b: myPlayer!.physicsBody!, limitLength: limitLength)
                tailJoint.append(playerNodeJoint)
            }
            
            for joint in tailJoint{
                self.physicsWorld.addJoint(joint)
            }
            
        }else if !self.hasCenterJointLogic{
            
            if self.playerLives < 2{
                //break
            }else{
                
                
                if self.playerLives >= 2{
                    for index in 0...self.playerLives - 2{
                        let joint = addJoint(myPlayerTail[index].physicsBody! , b: centerNode.physicsBody!, limitLength: maxJointLimit + ( CGFloat(index)*( myPlayer!.radius) ) )
                        tailJoint.append(joint)
                    }
                }
                
            }
            
            for joint in tailJoint{
                self.physicsWorld.addJoint(joint)
            }
            
        }
    }
    
    // MARK: SKPhysicsContactDelegate
    
    var contactSmashStatus:SmashBlock.activity = .waiting
    
    func didBeginContact(contact: SKPhysicsContact) {
        let pixelBuffer:CGFloat = 2//10.0 * 2
        
        func contactLogic(player:SKPhysicsBody, wall:SKPhysicsBody){
            
            
            if myPlayer!.isAlive{
                
                if let smashBlock = wall.node as? SmashBlock{
                    let smashPosition = smashBlock.smashBlockPosition
                    
                    if wall.dynamic == true{
                        
                        
                        
                        self.controller.joyStickDirection = .neutral
                        
                        if myPlayer!.contactActive == false{
                            myPlayer!.hitCount += 1
                            myPlayer!.contactActive = true
                        }
                        
                        
                        
                        print( "hitCount = \(myPlayer!.hitCount) from \(self.activeSmashBlock!.rawValue) active wall at \(myPlayer!.position.x), \(myPlayer!.position.y)")
                        
                        
                        player.velocity = mySmashBlocks[self.activeSmashBlock!]!.physicsBody!.velocity
                        
                        if myPlayer!.hitDirection == nil{
                            myPlayer!.hitDirection = smashPosition
                            myPlayer!.cornerHitPosition = myPlayer!.position
                            
                            self.contactSmashStatus = self.smashBlockStatus
                            
                            
                        }
                        
                        
                        
                        if myPlayer!.hitCount >= 2 && !myPlayer!.isDying{
                            
                            myPlayer!.deathPosition = contact.contactPoint
                            
                            
                            var moveAreaBy:CGPoint = CGPoint(x: 0, y: 0)
                            var playerMoveAreaPosition:CGPoint = contact.contactPoint
                            
                            switch smashPosition
                            {
                            case .leftBottom, .leftTop:
                                moveAreaBy.x = gameFrame.width
                                playerMoveAreaPosition.x = cornerBlockFrame.width + myPlayer!.radius
                                if smashPosition.opposite() != self.exitBlock{
                                    playerDies(" \(myPlayer!.hitCount) -player died from smashing into the right wall")
                                }
                                
                            case .rightBottom, .rightTop:
                                moveAreaBy.x = -gameFrame.width
                                playerMoveAreaPosition.x = gameFrame.width - cornerBlockFrame.width - myPlayer!.radius
                                if smashPosition.opposite() != self.exitBlock{
                                    playerDies(" \(myPlayer!.hitCount) -player died from smashing into the left wall")
                                }
                                
                            case .topLeft, .topRight:
                                moveAreaBy.y = -gameFrame.height
                                playerMoveAreaPosition.y = gameFrame.height - cornerBlockFrame.height - myPlayer!.radius
                                if smashPosition.opposite() != self.exitBlock{
                                    playerDies(" \(myPlayer!.hitCount) -player died from smashing into the bottom wall")
                                }
                                
                            case .bottomLeft, .bottomRight:
                                moveAreaBy.y = gameFrame.height
                                playerMoveAreaPosition.y = cornerBlockFrame.height + myPlayer!.radius
                                if smashPosition.opposite() != self.exitBlock{
                                    playerDies(" \(myPlayer!.hitCount) -player died from smashing into the top wall")
                                }
                            }
                            
                            if smashPosition.opposite() == self.exitBlock{
                                
                                self.movingToNextArea(moveAreaBy, playerPosition: playerMoveAreaPosition, playerVelocity: SmashBlock.entranceSpeed(self.activeSmashBlock!))
                                
                                return
                            }
                            
                            
                        }
                        
                        isPlayerTouched = true
                        
                    }
                    else if wall.dynamic == false { //static walls
                        
                        let playerVelocity = sqrt( pow(player.velocity.dx, 2) + pow(player.velocity.dy, 2) )
                        
                        var moveAreaBy:CGPoint = CGPoint(x: 0, y: 0)
                        var playerMoveAreaPosition:CGPoint = contact.contactPoint
                        if let activeBlock = self.activeSmashBlock {
                            
                            if myPlayer!.contactStatic == false {
                                switch activeBlock
                                {
                                case .leftBottom, .leftTop:
                                    if smashPosition == .rightBottom || smashPosition == .rightTop{
                                        myPlayer!.hitCount += 1
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.x = gameFrame.width
                                        playerMoveAreaPosition.x = cornerBlockFrame.width + myPlayer!.radius
                                    }
                                case .rightBottom, .rightTop:
                                    if smashPosition == .leftBottom || smashPosition == .leftTop{
                                        myPlayer!.hitCount += 1
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.x = -gameFrame.width
                                        playerMoveAreaPosition.x = gameFrame.width - cornerBlockFrame.width - myPlayer!.radius
                                    }
                                case .topLeft, .topRight:
                                    if smashPosition == .bottomLeft || smashPosition == .bottomRight{
                                        myPlayer!.hitCount += 1
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.y = -gameFrame.height
                                        playerMoveAreaPosition.y = gameFrame.height - cornerBlockFrame.height - myPlayer!.radius
                                    }
                                case .bottomLeft, .bottomRight:
                                    if smashPosition == .topLeft || smashPosition == .topRight{
                                        myPlayer!.hitCount += 1
                                        myPlayer!.contactStatic = true
                                        moveAreaBy.y = gameFrame.height
                                        playerMoveAreaPosition.y = cornerBlockFrame.height + myPlayer!.radius
                                    }
                                }

                            }
                            print( "hitCount = \(myPlayer!.hitCount) from \(smashPosition.rawValue) static wall")
                            
                            
                            
                            if myPlayer!.hitCount >= 2 && !myPlayer!.isDying{
                                
                                if smashPosition == self.exitBlock && self.activeSmashBlock!.opposite() == self.exitBlock{
                                    
                                    
                                    player.velocity = mySmashBlocks[self.activeSmashBlock!]!.physicsBody!.velocity
                                    
                                    self.movingToNextArea(moveAreaBy, playerPosition: playerMoveAreaPosition, playerVelocity: SmashBlock.entranceSpeed(self.activeSmashBlock!))
                                    
                                    return
                                }
                                
                                myPlayer!.deathPosition = contact.contactPoint
                                playerDies(" \(myPlayer!.hitCount) -player died from smashing into the \(smashPosition.rawValue) wall")
                            }else if playerVelocity >= DEATHVELOCITY/3 && !myPlayer!.isDying{
                                //break
                                
                            }
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        
                    }
                }
            }
            
            
        }
        
        
        
        if (contact.bodyA.node as? Player) != nil {
            contactLogic(contact.bodyA, wall: contact.bodyB)
        }else if (contact.bodyB.node as? Player) != nil {
            contactLogic(contact.bodyB, wall: contact.bodyA)
        }
        
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
        let pixelBuffer:CGFloat = 10.0
        
        func contactLogic(player:SKPhysicsBody, wall:SKPhysicsBody){
            
            
            if let smashBlock = wall.node as? SmashBlock{
                let smashPosition = smashBlock.smashBlockPosition
                
                
                if wall.dynamic == true{
                    if myPlayer!.contactActive{
                        myPlayer!.hitCount -= 1
                        myPlayer!.contactActive = false
                    }
                    print( "hitCount = \(myPlayer!.hitCount) release from \(self.activeSmashBlock!.rawValue) active wall")
                    
                    if let activeBlock = self.activeSmashBlock {
                        if myPlayer!.hitDirection == nil{
                            myPlayer!.hitDirection = activeBlock
                            myPlayer!.cornerHitPosition = myPlayer!.position
                            
                            
                        }
                    }
                }
                else{
                    
                    if let activeBlock = self.activeSmashBlock {
                        
                        if myPlayer!.contactStatic{
                            
                            
                            switch activeBlock
                            {
                            case .leftBottom, .leftTop:
                                if smashPosition == .rightBottom || smashPosition == .rightTop{
                                    myPlayer!.hitCount -= 1
                                    myPlayer!.contactStatic = false
                                }
                            case .rightBottom, .rightTop:
                                if smashPosition == .leftBottom || smashPosition == .leftTop{
                                    myPlayer!.hitCount -= 1
                                    myPlayer!.contactStatic = false
                                }
                            case .topLeft, .topRight:
                                if smashPosition == .bottomLeft || smashPosition == .bottomRight{
                                    myPlayer!.hitCount -= 1
                                    myPlayer!.contactStatic = false
                                }
                            case .bottomLeft, .bottomRight:
                                if smashPosition == .topLeft || smashPosition == .topRight{
                                    myPlayer!.hitCount -= 1
                                    myPlayer!.contactStatic = false
                                }
                            }
                            
                            
                            
                        }
                        
                        print( "hitCount = \(myPlayer!.hitCount) \(activeBlock.rawValue) active wall & release from \(smashPosition.rawValue) static wall")
                    }
                }
            }
        }
        
        
        
        if myPlayer!.isAlive{
            
            if (contact.bodyA.node as? Player) != nil {
                
                contactLogic(contact.bodyA, wall: contact.bodyB)
                
            }
            else if (contact.bodyB.node as? Player) != nil {
                
                contactLogic(contact.bodyB, wall: contact.bodyA)
            }
        }
        
    }
    
    
    var newStageEscapeWave:Bool = false //used to make the first trap block be the escape path block
    var leavingExitBlock: SmashBlock.blockPosition = .leftTop
    
    func stageUpLevelUp(){
        
        
        func hasContinuedPath(exitSidePartA:SmashBlock.blockPosition, exitSidePartB:SmashBlock.blockPosition, direction:MazeCell.wallLocations)->Bool{
            
            self.leavingTime += 0.5
            
            var continueOnPath:Bool = false
            
            for exit in myMaze!.stageExitsArray[self.currentStage]!{
                if exit == exitSidePartA || exit == exitSidePartB{
                    continueOnPath = true
                }
            }
            
            for otherExit in exitSidePartA.perpendicularArray(){
                for exit in myMaze!.stageExitsArray[self.currentStage]!{
                    if otherExit == exit{
                        continueOnPath = false
                    }
                    
                }
            }
            
            return continueOnPath
        }
        
        
        switch self.leavingExitBlock{
        case .topLeft, .topRight:
            repeat{
                self.currentStage = self.currentStage + myMaze!.MAZE_ROWS*2
            }while hasContinuedPath(.topLeft, exitSidePartB: .topRight, direction: .up)
        case .bottomLeft, .bottomRight:
            repeat{
                self.currentStage = self.currentStage - myMaze!.MAZE_ROWS*2
            }while hasContinuedPath(.bottomLeft, exitSidePartB: .bottomRight, direction: .down)
        case .rightBottom, .rightTop:
            repeat{
                self.currentStage = self.currentStage + 2
            }while hasContinuedPath(.rightBottom, exitSidePartB: .rightTop, direction: .right)
        case .leftBottom, .leftTop:
            repeat{
                self.currentStage = self.currentStage - 2
            }while hasContinuedPath(.leftBottom, exitSidePartB: .leftTop, direction: .left)
        }
        
        
        STAGE = self.currentStage
        
        //add functionality to have the first block in the Trap logic be the Escape Path block
        
        newStageEscapeWave = true
        
        
        
    }
    
    func arrivedInNewArea(playerPosition:CGPoint, playerVelocity: CGVector){
        
        
        myPlayer!.position = playerPosition
        myPlayer!.physicsBody!.velocity = playerVelocity
        
        self.addChild(myPlayer!)
        self.world.addChild(myPresentationPlayer!)
        
        self.connectPlayerJoints()

    }
    
    var isLeavingOldArea:Bool = false
    var leavingTime:CFTimeInterval = 0
    var leavingVelocity:CGVector = CGVector(dx: 0, dy: 0)
    var arrivingPosition:CGPoint = CGPoint(x: 0, y: 0)
   
    private func movingToNextArea(moveAreaBy:CGPoint, playerPosition:CGPoint, playerVelocity: CGVector){
        print("moving to new area")
        self.leavingVelocity = playerVelocity
        self.arrivingPosition = playerPosition
        
        print("player V \( myPlayer!.physicsBody!.velocity )")
        print("leaving V \( self.leavingVelocity )")
        myPlayer!.isStunned = false
        self.isMovingToNextArea = true
        if self.smashBlockEdgeHit(myPlayer!){
            self.isMovingToNextArea = false
            return
        }
        
        myPlayer!.hitCount = 0
        myPlayer!.contactActive = false
        myPlayer!.contactStatic = false
        self.controller.joyStickDirection = .neutral
        self.isPlayerTouched = false
        
        
        
        myPlayer!.removeFromParent()
        myPresentationPlayer!.removeFromParent()
        
        
        self.leavingExitBlock = self.exitBlock
        
        reloadSceneTime()
        
        self.isLeavingOldArea = true
        
        self.stageUpLevelUp()
        
        
        //add stage change animation here
        
        
        
    }

    
    func afterArrivingInNewAreaAction(playerPosition:CGPoint, playerVelocity: CGVector){
        self.runAction(SKAction.waitForDuration(0.01)){ // stupid fix for player Velocity problem
            myPlayer!.physicsBody!.velocity = playerVelocity
            
            self.runAction(SKAction.waitForDuration(0.5)){
                self.isMovingToNextArea = false
                self.leavingTime = 0
                
                
                print("arrived at new area")
                
                
                self.resetForLevelChange()
        
                self.reloadSceneTime()
                
            }
            
        }
    }
    
    func resetForGameOver(){
        
        
        self.level = 1
        LEVEL = self.level //1
        self.playerLives = playerLivesMAX
        
        
            
        self.isFirstRound = true
        self.isFirstRoundStarted = false
        
        
            if let player = myPlayer{
                
                player.position = player.originalPosition
                player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                
                
                for (index, tailPiece) in myPlayerTail.enumerate(){ //fix this
                    tailPiece.position = tailPiece.originalPosition
                    
                    if self.playerLives > 1{
                        let MATH_PI:CGFloat = CGFloat(M_PI)
                        let unitCirleRadians:CGFloat = 2 * MATH_PI / CGFloat(self.playerLives - 1)
                        let angle:CGFloat = CGFloat(index) * unitCirleRadians
                        tailPiece.position = CGPoint(x: cos(angle) * self.maxJointLimit + player.position.x , y: sin(angle) * self.maxJointLimit + player.position.y)
                    }
                    
                    
                    tailPiece.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                }
                
                
                player.isAlive = false
                player.contactActive = false
                for tail in tailJoint{
                    self.physicsWorld.removeJoint(tail)
                }
                tailJoint = []
                player.removeFromParent()
                myPresentationPlayer!.removeFromParent()
                for tailPiece in myPlayerTail{
                    if tailPiece.parent != nil{
                        tailPiece.removeFromParent()
                    }
                }
                for tailPiece in myPresentationTail{
                    if tailPiece.parent != nil{
                        tailPiece.removeFromParent()
                    }
                }
            }
        
        self.reloadSceneTime()
        
        self.updateLevelMaze(self.level)
        
        
        
    }
    
    func resetForLevelChange(){
        
        if self.currentStage == myMaze!.exitPoint{
            self.islevelChange = true
            self.level += 1
            LEVEL = self.level
        }
        
        if self.islevelChange{
            
            // ****** lives adjustment on level up ****
            if gameDifficultySetting == .easy{
                
                self.playerLives = self.playerLivesMAX
                
            }else if gameDifficultySetting == .hard{
                
                self.playerLives = self.playerLives + 4
                if self.playerLives > playerLivesMAX{
                    self.playerLives = playerLivesMAX
                }
                
            }else if gameDifficultySetting == .ultraHard{
                self.playerLives = self.playerLives + 2
                if self.playerLives > playerLivesMAX{
                    self.playerLives = playerLivesMAX
                }
            }
            // ****************************************
            
            
            self.isFirstRound = true
            self.isFirstRoundStarted = false
            if let player = myPlayer{
                
                player.position = player.originalPosition
                player.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                for (index, tailPiece) in myPlayerTail.enumerate(){ //fix this
                    tailPiece.position = tailPiece.originalPosition
                    
                    if self.playerLives > 1{
                        let MATH_PI:CGFloat = CGFloat(M_PI)
                        let unitCirleRadians:CGFloat = 2 * MATH_PI / CGFloat(self.playerLives - 1)
                        let angle:CGFloat = CGFloat(index) * unitCirleRadians
                        tailPiece.position = CGPoint(x: cos(angle) * self.maxJointLimit + player.position.x , y: sin(angle) * self.maxJointLimit + player.position.y)
                    }
                    
                    
                    tailPiece.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                }
                
                
                player.isAlive = false
                player.contactActive = false
                for tail in tailJoint{
                    self.physicsWorld.removeJoint(tail)
                }
                tailJoint = []
                player.removeFromParent()
                myPresentationPlayer!.removeFromParent()
                for tailPiece in myPlayerTail{
                    if tailPiece.parent != nil{
                        tailPiece.removeFromParent()
                    }
                }
                for tailPiece in myPresentationTail{
                    if tailPiece.parent != nil{
                        tailPiece.removeFromParent()
                    }
                }
            }
            
            self.updateLevelMaze(self.level)
            
            self.islevelChange = false
            
            
            
            
            
        }
    }
    
    
    
    
    

    private func deathScene(deltaTime: CFTimeInterval){
        
        let centerPoint = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
        var differenceVector = CGPoint(x: centerPoint.x - myPlayer!.deathPosition.x, y: centerPoint.y - myPlayer!.deathPosition.y)
        if !hasWorldMovement{
            differenceVector = CGPoint(x: 0, y: 0)
        }
            if self.deathTimer == 0{
                self.slowDownSceneTime()
                sizeEffectSwitch = true
            }
            
            self.deathTimer += deltaTime
            if self.deathTimer <= 1 || !sizeEffectSwitch{
                //return
                sizeEffectSwitchCounter += 1
                if sizeEffectSwitch && sizeEffectSwitchCounter >= 3 {
                    
                    
                    self.world.position = CGPoint(x: ( 1 - 1.01 ) * gameFrame.width/2 + differenceVector.x, y: ( 1 - 1.01 ) * gameFrame.height/2 + differenceVector.y)
                    
                    sizeEffectSwitch = !sizeEffectSwitch
                    sizeEffectSwitchCounter = 0
                }
                else if !sizeEffectSwitch && sizeEffectSwitchCounter >= 3{
                    
                    
                    self.world.position = differenceVector
                    sizeEffectSwitch = !sizeEffectSwitch
                    sizeEffectSwitchCounter = 0
                }
                
                
            }
            else{
                
                self.deathTimer = 0
                myPlayer!.isDying = false
                self.isSlowedDown = false

                
            }
        
    }
        
        
    
    
    
        
    
    private var sizeEffectSwitch:Bool = false
    private var sizeEffectSwitchCounter = 0
    
    var needsRecoveryTimeFromPause:Bool = false
   
    override func update(currentTime: CFTimeInterval) {
        // giving a frame delay for the 3D side to catch up 
        updatePresentationLayer()
        
        
        if isFirstRound{
            myRestartLabel.text = "START"
            lastUpdatedTime = currentTime
            return
        }
        else if !isFirstRoundStarted{
            isFirstRoundStarted = true
        }
        
        if isMovingToNextArea{
            lastUpdatedTime = currentTime
            return
        }
        
        
        
        deltaTime = currentTime - lastUpdatedTime
        lastUpdatedTime = currentTime
        
        if myPlayer!.isDying{
            if needsRecoveryTimeFromPause{
                deltaTime = 0
                needsRecoveryTimeFromPause = false
            }
            // ***************** //
            self.deathScene(deltaTime)
            // ***************** //
        }
        if needsRecoveryTimeFromPause{
            deltaTime = 0.25 // *TIME_UNTIL_TRAP / 2*
            needsRecoveryTimeFromPause = false
        }
        if !isTrapWallPaused{
            self.SmashBlockLogic(deltaTime)
        }
        self.updatePlayer()
        
        
        
    }
    
    override func didSimulatePhysics() {
        
        myLevelNumberLabel.text = "LEVEL \(LEVEL)"
        myLevelNumberLabel.position = CGPoint(x: world.position.x + gameFrame.width/2, y: world.position.y + gameFrame.height/2 - cornerBlockFrame.height)
        
        if isFirstRound{
            return
        }
        if isMovingToNextArea{
            return
        }
        if !isTrapWallPaused{
            SmashBlockLogicAfterPhysics()
        }
        updatePlayerAfterPhysics()
        if !myPlayer!.isDying{
            updateWorldMovement()
        }
        
        
        updateJoyStickAfterPhysics()
    }
    
    func updateJoyStickAfterPhysics(){
        
        if controller.joyStickDirection == .neutral{
            
            let targetPosition = myPlayer!.originalPosition
            
            if CGRect(x: targetPosition.x - cornerBlockFrame.width/4, y: targetPosition.y - cornerBlockFrame.height/4, width: cornerBlockFrame.width/2, height: cornerBlockFrame.height/2 ).contains(myPlayer!.position){
                
                
                myPlayer!.position = myPlayer!.originalPosition
                
            }
        }
    }
    
    
    override func didFinishUpdate() {
        
        
    }
    
    private var blockArrayCounter:Int = 0
    
    
    private func SmashBlockLogicAfterPhysics(){
        let pixelBuffer:CGFloat = 2//10.0
        
        
        
        for (position, block) in mySmashBlocks{
            
            if block.physicsBody!.dynamic != true{
                block.position = block.orginalPosition
            }
            else if block.physicsBody!.dynamic{
                switch position{
                case .leftBottom, .leftTop, .rightBottom, .rightTop:
                    block.position.y = block.orginalPosition.y
                default: //the vertical blocks
                    block.position.x = block.orginalPosition.x
                }
            }
            
        }
        
        
        if var trap = self.activeSmashBlock{
            
            let smashBlock = mySmashBlocks[trap]
            
            smashBlock!.zRotation = 0
            
            
            
            switch smashBlockStatus{
                
            case .waiting:
                
                if smashStatusChanged{
                    myPlayer!.hitCount = 0
                    myPlayer!.contactActive = false
                    myPlayer!.contactStatic = false
                    smashStatusChanged = false
                    smashBlock!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    smashBlock!.color = self.wallColor
                    if trap.opposite() == self.exitBlock{
                        mySmashBlocks[self.exitBlock]!.color = self.wallColor
                    }
                    smashBlock!.physicsBody!.dynamic = false
                    smashBlock!.physicsBody!.categoryBitMask = CollisionType.staticWall.rawValue
                    smashBlock!.physicsBody!.contactTestBitMask = CollisionType.player.rawValue
                    self.restingSmashBlockPosition = smashBlock!.orginalPosition
                    self.oldSmashBlock = self.activeSmashBlock
                    wallTimer = 0
                    
                    if let oldBlock = self.oldSmashBlock{
                        mySmashBlocks[oldBlock]!.position = self.restingSmashBlockPosition!
                    }
                    
                    
                    blockArrayCounter += 1
                    if blockArrayCounter > 7 {
                        blockArrayCounter = 0
                        arrayOfBlocks.shuffle()
                    }
                    trap = arrayOfBlocks[blockArrayCounter]
                    //next line makes the first trap be the correct exit when going to the next stage (only in the correct path)
                    if newStageEscapeWave{
                        trap = (myMaze!.stageExitsArray[currentStage]![0]).opposite()
                        newStageEscapeWave = false
                        //add logic
                    }
                    self.activeSmashBlock = trap
                    mySmashBlocks[trap]!.color = self.smashingColor
                    
                    
                    if myMaze!.stageExitsArray[currentStage] != nil{
                        for exit in myMaze!.stageExitsArray[currentStage]!{
                            if trap.opposite() == exit{
                                self.exitBlock = exit
                                //mySmashBlocks[self.exitBlock]!.color = self.exitBlockColor
                            }
                        }
                        
                    }
                    //regular logic change back // can move the below line into the above line
                    if trap.opposite() == self.exitBlock{
                        mySmashBlocks[self.exitBlock]!.color = self.exitBlockColor
                    }
                    //self.exitBlock = trap.opposite()
                    //mySmashBlocks[self.exitBlock]!.color = self.exitBlockColor
                    
                }
            case .smashing:
                
                if smashStatusChanged{
                    smashStatusChanged = false
                    smashBlock!.physicsBody!.dynamic = true
                    smashBlock!.physicsBody!.categoryBitMask = CollisionType.activeWall.rawValue
                    smashBlock!.physicsBody!.contactTestBitMask = CollisionType.player.rawValue
                }else{
                    
                    switch trap{
                        
                    case .leftTop, .leftBottom:
                        //
                        if smashBlock!.position.x >= gameFrame.width - cornerBlockFrame.width - smashBlock!.size.width/2 - pixelBuffer {
                            smashBlock!.position.x = gameFrame.width - cornerBlockFrame.width - smashBlock!.size.width/2 - pixelBuffer
                            smashBlock!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                            //smashBlockStatus = .returning
                        }
                        
                        smashBlock!.position.y = smashBlock!.orginalPosition.y
                        
                        
                    case .rightTop, .rightBottom:
                        //
                        if smashBlock!.position.x <= cornerBlockFrame.width + smashBlock!.size.width/2 + pixelBuffer {
                            smashBlock!.position.x = cornerBlockFrame.width + smashBlock!.size.width/2 + pixelBuffer
                            smashBlock!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                            //smashBlockStatus = .returning
                        }
                        
                        smashBlock!.position.y = smashBlock!.orginalPosition.y
                        
                    case .topLeft, .topRight:
                        //
                        if smashBlock!.position.y <= cornerBlockFrame.height + smashBlock!.size.height/2 + pixelBuffer {
                            smashBlock!.position.y = cornerBlockFrame.height + smashBlock!.size.height/2 + pixelBuffer
                            smashBlock!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                            //smashBlockStatus = .returning
                        }
                        
                        smashBlock!.position.x = smashBlock!.orginalPosition.x
                        
                    case .bottomLeft, .bottomRight:
                        //
                        if smashBlock!.position.y >=    gameFrame.height - cornerBlockFrame.height - smashBlock!.size.height/2 - pixelBuffer {
                            smashBlock!.position.y = gameFrame.height - cornerBlockFrame.height - smashBlock!.size.height/2 - pixelBuffer
                            smashBlock!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                            //smashBlockStatus = .returning
                        }
                        
                        smashBlock!.position.x = smashBlock!.orginalPosition.x
                        
                    }
                    
                    
                }
                
                
                
            case .returning:
                if smashStatusChanged{
                    smashStatusChanged = false
                    smashBlock!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    //playerScore++
                    
                }else{
                    
                    
                    switch trap{
                        
                    case .leftTop, .leftBottom:
                        //
                        if smashBlock!.position.x <= cornerBlockFrame.width - smashBlock!.size.width/2 {
                            smashBlock!.position.x = cornerBlockFrame.width - smashBlock!.size.width/2
                            smashBlock!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                        }
                        
                    case .rightTop, .rightBottom:
                        //
                        if smashBlock!.position.x >= gameFrame.width - cornerBlockFrame.width + smashBlock!.size.width/2 {
                            smashBlock!.position.x = gameFrame.width - cornerBlockFrame.width + smashBlock!.size.width/2
                            smashBlock!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                        }
                        
                    case .topLeft, .topRight:
                        //
                        if smashBlock!.position.y >= gameFrame.height - cornerBlockFrame.height + smashBlock!.size.height/2 {
                            smashBlock!.position.y = gameFrame.height - cornerBlockFrame.height + smashBlock!.size.height/2
                            smashBlock!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                        }
                        
                    case .bottomLeft, .bottomRight:
                        //
                        if smashBlock!.position.y <= cornerBlockFrame.height - smashBlock!.size.height/2 {
                            smashBlock!.position.y = cornerBlockFrame.height - smashBlock!.size.height/2
                            smashBlock!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                        }
                    }
                }
            }
            
        }

    }
    
    
    private func SmashBlockLogic(deltaTime: CFTimeInterval) {
        
        var TIME_UNTIL_TRAP = 0.5 /// CFTimeInterval(SPEED_PERCENTAGE)
        if SPEED_PERCENTAGE < 1{
            TIME_UNTIL_TRAP =  0.25/CFTimeInterval(SPEED_PERCENTAGE)
        }
        let WALL_SPEED = WALLSPEED
        let pixelBuffer:CGFloat = 2//10.0
        //smashBlockStatus - private property to keep track of the activty status of each SMASH BLOCK
        //wallTimer - private property to pace the time before a SMASH BLOCK is active
        
        func speed(wallSpeed: CGVector){
            if let trap = self.activeSmashBlock{
                let smashBlock = mySmashBlocks[trap]
                smashBlock!.physicsBody!.velocity = (wallSpeed)
                
            }
        }
        
        
        if pauseSmashBlockLogic{ // if true blocks pause
            speed(CGVector(dx: 0, dy: 0))
            
            return
        }
        
        if let trap = self.activeSmashBlock{
            
            switch smashBlockStatus{
            //--------------------------------WAITING
            case .waiting:
                
                wallTimer += deltaTime
                
                if wallTimer >= TIME_UNTIL_TRAP{
                    
                    smashStatusChanged = true
                    smashBlockStatus = .smashing
                    wallTimer = 0.0
                    
                    
                    
                }
            //--------------------------------SMASHING
            case .smashing:
                
                let smashBlock = mySmashBlocks[trap]
                
                switch trap{
                    
                case .leftTop, .leftBottom:
                    //
                    if smashBlock!.position.x < gameFrame.width - cornerBlockFrame.width - smashBlock!.size.width/2 - pixelBuffer {
                        speed(CGVector(dx: WALL_SPEED, dy: 0)) //smash right
                    }
                    else {
                        smashBlockStatus = .returning
                        
                        
                    }
                    
                case .rightTop, .rightBottom:
                    //
                    if smashBlock!.position.x > cornerBlockFrame.width + smashBlock!.size.width/2 + pixelBuffer {
                        speed(CGVector(dx: -WALL_SPEED, dy: 0)) //smash left
                    }
                    else {
                        smashBlockStatus = .returning
                        
                        
                    }
                    
                case .topLeft, .topRight:
                    //
                    if smashBlock!.position.y > cornerBlockFrame.height + smashBlock!.size.height/2 + pixelBuffer {
                        speed(CGVector(dx: 0, dy: -WALL_SPEED)) //smash down
                    }
                    else {
                        smashBlockStatus = .returning
                        
                        
                    }
                    
                case .bottomLeft, .bottomRight:
                    //
                    if smashBlock!.position.y < gameFrame.height - cornerBlockFrame.height - smashBlock!.size.height/2 - pixelBuffer {
                        speed(CGVector(dx: 0, dy: WALL_SPEED)) //smash up
                        
                    }
                    else {
                        smashBlockStatus = .returning
                        
                        
                    }
                }
                if smashBlockStatus == .returning {
                    smashStatusChanged = true
                    
                    
                }
                    
                
                
            //--------------------------------RETURNING
            case .returning:
                
                let smashBlock = mySmashBlocks[trap]
                
                switch trap{
                    
                case .leftTop, .leftBottom:
                    //
                    if smashBlock!.position.x > cornerBlockFrame.width - smashBlock!.size.width/2 {
                        speed(CGVector(dx: -WALL_SPEED, dy: 0)) //return left
                    }
                    else {
                        smashBlockStatus = .waiting
                        
                    }
                    
                case .rightTop, .rightBottom:
                    //
                    if smashBlock!.position.x <= gameFrame.width - cornerBlockFrame.width + smashBlock!.size.width/2 - pixelBuffer {
                        speed(CGVector(dx: WALL_SPEED, dy: 0)) //return right
                    }
                    else {
                        smashBlockStatus = .waiting
                        
                    }
                    
                case .topLeft, .topRight:
                    //
                    if smashBlock!.position.y <= gameFrame.height - cornerBlockFrame.height + smashBlock!.size.height/2 - pixelBuffer {
                        speed(CGVector(dx: 0, dy: WALL_SPEED)) //return up
                    }
                    else {
                        smashBlockStatus = .waiting
                        
                    }
                    
                case .bottomLeft, .bottomRight:
                    //
                    if smashBlock!.position.y >= cornerBlockFrame.height - smashBlock!.size.height/2 + pixelBuffer {
                        speed(CGVector(dx: 0, dy: -WALL_SPEED)) //return down
                    }
                    else {
                        smashBlockStatus = .waiting
                        
                    }
                    
                }
                
                if smashBlockStatus == .waiting {
                    smashStatusChanged = true
                    
                    if !isPlayerTouched{
                        playerScore += 1
                    }else{
                        self.playerScore = 0
                        myGravityFieldNode.strength = 9.8 * Float(SPEED_PERCENTAGE)
                    }
                    isPlayerTouched = false
                    
                }

                
                
            }
            
            
            
        }
        
        
        
        
        
    }
    
    
}
    




