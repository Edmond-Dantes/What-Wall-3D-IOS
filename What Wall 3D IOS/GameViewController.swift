//
//  GameViewController.swift
//  What Wall 3D IOS
//
//  Created by Edmond on 5/2/16.
//  Copyright (c) 2016 future. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit
//import GoogleMobileAds

extension SCNVector3 {
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = SCNFloat(x)
        self.y = SCNFloat(y)
        self.z = SCNFloat(z)
    }
    init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.x = SCNFloat(x)
        self.y = SCNFloat(y)
        self.z = SCNFloat(z)
    }
    init(_ x: Double, _ y: Double, _ z: Double) {
        self.init(SCNFloat(x), SCNFloat(y), SCNFloat(z))
    }
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.init(SCNFloat(x), SCNFloat(y), SCNFloat(z))
    }
    init(_ v: float3) {
        self.init(SCNFloat(v.x), SCNFloat(v.y), SCNFloat(v.z))
    }
    init(_ v: double3) {
        self.init(SCNFloat(v.x), SCNFloat(v.y), SCNFloat(v.z))
    }
}

extension CGFloat{
    
    func abs()->CGFloat{
        var tempSelf = self
        if self < 0.0 {
            tempSelf = -self
        }
        return tempSelf
    }
    
}

extension Float{
    
    func abs()->Float{
        var tempSelf = self
        if self < 0.0 {
            tempSelf = -self
        }
        return tempSelf
    }
    
}

var frameCounter2d:Int = 0
var frameCounter3d:Int = 0

var myPlayerNode:SCNNode!
var myPlayerTailNodeArray:[SCNNode] = []


var gameScene:GameScene!


var myHUDView:UIView!


class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate, UIGestureRecognizerDelegate {
    
    var optionsData:[String:AnyObject] = [:]
    //var imageData:[UIImage] = []
    
    // ************ for the stars in the background
    weak var emittorNode:SCNNode! //= SCNNode()
    weak var particleSystem:SCNParticleSystem! //= SCNParticleSystem(named: "MyParticleSystem2.scnp", inDirectory: nil)
    // ************
    let backgroundNode = SCNNode()
    
    
    var myMaze:Maze? = nil
    
    
    var isMapKeyPressed:[keys:Bool] = [keys.left: false, .right: false, .up: false, .down: false]
    
    var renderCount:Int = 0
    
    //@IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var gameView: GameView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var tutorialImages:[String:SKSpriteNode] = [:]
    
    
    //var gameView: GameView!
    weak var myView:SCNView!
    var myScene:SCNScene!
    
    var myLight:SCNNode!
    var myCamera:SCNCamera!
    var myCameraNode:SCNNode!
    
    //var myPlayerNode:SCNNode!
    var myStageNode:SCNNode!
    var myEmittorNode:SCNNode!
    var myParticleSystem:SCNParticleSystem!
    var myPhysicsFieldNode:SCNNode!
    var myPhysicsField:SCNPhysicsField!
    
    var myGameScene:GameScene!
    var myHudOverlay:HudOverlay!

    var panGesture:UIPanGestureRecognizer!
    
    
    func clearMemoryBeforeLoad(){
        //return ()
        myStageNode = nil
        self.myEmittorNode = nil
        myParticleSystem = nil
        myPhysicsFieldNode = nil
        myPhysicsField = nil
        
        myGameScene = nil
        myHudOverlay = nil
        
        panGesture = nil
        
        myPlayerNode = nil
        myPlayerTailNodeArray = []
        
        
        // **********************
        
        // Dictionary to hold the corner block objects
        myCorners = [:]
        myPresentationCorners = [:]
        
        mySmashBlocks = [:]
        myPresentationSmashBlocks = [:]
        
        
        myPlayer = nil
        myPlayerTail = []
        myPresentationPlayer = nil
        myPresentationTail = []
        tailJoint = []
        
        myEmitterNode = nil
    }
    
    func clearMemoryAfterGame(){
        //return ()
        
        //emittorNode = nil
        //particleSystem = nil
        
        //emittorNode.removeParticleSystem(particleSystem!)
        //emittorNode.removeFromParentNode()
        
        
        
        
        myHUDView = nil
        
        //optionsData = [:]
        
        //bannerView = nil
        
        //gameView = nil
        
        
        //var gameView: GameView!
        //myView = nil
        myScene = nil
        
        myLight = nil
        myCamera = nil
        //myCameraNode = nil
        
        //if let _ = myMaze{
        //myMaze = nil
        //}
        
        gameScene = nil
 
    }
    /*
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        //updateGlobalBackgroundImage()
    }
    */
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //imageView.image = UIImage(named: "tutorial images/up.png")
        //print(" got here \(imageView.image)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        clearMemoryAfterGame()
    }
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        
        //clearMemoryAfterGame()
        
        
 
    }
    
    func backToTitleScreen() {
        //imageData.shuffle()
        //updateGlobalBackgroundImage()
        self.performSegue(withIdentifier: "unwindFromGame", sender: self)//nil)
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //let vc = parentViewController as! TitlePageViewController
        //vc.backgroundNode.geometry!.firstMaterial!.diffuse.contents = self.imageData[0]
        
        print("shouldPerformSegueWithIdentifier called")
        
        return false//true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier! == "unwindFromGame"{
            
            self.particleSystem?.reset()//titleVC.particleSystem!.reset()
            
        }
        
        
    }
    func updateGlobalBackgroundImage(){
        //imageData.shuffle()
        //let myMaterial = imageData[0]
        
        //globalBackgroundNode.geometry!.firstMaterial!.diffuse.contents = nil
        //globalBackgroundNode.geometry!.firstMaterial!.diffuse.contents = myMaterial
    }
    
    func setupGameOptionsLives(){
    
        START_LIVES = optionsData["lives"] as! Int
    }
    
    func setupGameOptionsLevel(){
        
        LEVEL = optionsData["level"] as! Int
    }
    
    func setupGameOptionsDifficulty(){
    
            
            let difficulty = optionsData["difficulty"] as! Int
            
            if difficulty == 1{
                gameDifficultySetting = .easy
            }else if difficulty == 2{
                gameDifficultySetting = .hard
            }else if difficulty == 3{
                gameDifficultySetting = .ultraHard
       
        }
        
        //************************
        //MARK: setting difficulty from options menu - saved in plist and set from OptionDetailsController
        myHudOverlay.setDifficulty(gameDifficultySetting)
        //************************
    }
    
    func setupBackgroundStars(){
        //return
        //self.emittorNode.removeFromParentNode()
        self.myScene.rootNode.addChildNode(emittorNode)
        emittorNode.position = SCNVector3(x: 0, y: 0, z: -1)
        //emittorNode.addParticleSystem(particleSystem!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("GAME VIEW DID LOADDDDDDDDDDDDD")
        
        //self.parentViewController!.dism
        
        clearMemoryBeforeLoad()
        
        gameView.controller = self
        let folder = "tutorial images"
        
        tutorialImages = ["left":SKSpriteNode(imageNamed: "\(folder)/left.png"), "right":SKSpriteNode(imageNamed: "\(folder)/right.png"), "up":SKSpriteNode(imageNamed: "\(folder)/up.png"), "down":SKSpriteNode(imageNamed: "\(folder)/down.png"), "in":SKSpriteNode(imageNamed: "\(folder)/in.png"), "out":SKSpriteNode(imageNamed: "\(folder)/out.png"), "tap":SKSpriteNode(imageNamed: "\(folder)/tap.png")]
        
        //imageView.image = UIImage()//(named: "\(folder)/left.png")!//tutorialImages["right"]
        
        //************************
        //MARK: level/lives settings
        setupGameOptionsLevel()
        setupGameOptionsLives()
        //************************
        /*
        if !(optionsData["optionsUnlocked"] as! Bool){
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.isHidden = false//true
        }else{
            bannerView.isHidden = true
        }*/
      
        myView = self.gameView //global
        myScene = SCNScene()
        myView.scene = myScene
        
        
        
        myView.backgroundColor = Color.black
        self.setupLights()
        self.setupCamera()
        
        
        #if os(iOS)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameViewController.handleTap(_:)))
        myView.addGestureRecognizer(tapGesture)
        // add a pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(GameViewController.handlePinch(_:)))
        myView.addGestureRecognizer(pinchGesture)
        // add a pan gesture recognizer
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        myView.addGestureRecognizer(panGesture) //add when map is shown and removed otherwise
            
        // add a swipe gesture recognizer
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipe(_:)))
        leftSwipeGesture.direction = .left
        myView.addGestureRecognizer(leftSwipeGesture)
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipe(_:)))
        rightSwipeGesture.direction = .right
        myView.addGestureRecognizer(rightSwipeGesture)
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipe(_:)))
        upSwipeGesture.direction = .up
        myView.addGestureRecognizer(upSwipeGesture)
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(GameViewController.handleSwipe(_:)))
        downSwipeGesture.direction = .down
        myView.addGestureRecognizer(downSwipeGesture)
        
            
            
            
            
            #endif
        
        // DEBUG
        self.setupDebugDisplay()
        
        // configure the view
        // self.gameView!.backgroundColor = NSColor.blackColor()
        
        
        //*********************************
        //override func nextResponder() -> UIResponder? (for iOS in GameView Class)
        //self.gameView.delegate = self
        //self.gameView.nextResponder = self
        //*********************************
        


        
        self.setupEnvironment()
        self.setupBackground()
        self.updateBackgroundImage(LEVEL)
        //Heads Up Display (SpriteKit Overlay)
        self.setupHUD()
        #if os(iOS)
        #endif
        self.addPlayerNode()
        self.addPhysicsField()
        self.addEmittorNode()
        
        self.setupBackgroundStars()
        
        myScene.physicsWorld.contactDelegate = self
        myScene.physicsWorld.gravity = SCNVector3(x: 0, y: 0, z: 0)
        
        self.gameView.delegate = self
        

        
        self.setupGameOptionsDifficulty()
        
        
    }
    
    #if os(iOS)
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    /*
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .Portrait// AllButUpsideDown
        } else {
            return .All
        }
    }
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    //var currentSwipeDirection:UISwipeGestureRecognizerDirection? = nil
    
    func handleSwipe(_ gestureRecognize: UIGestureRecognizer){
        
        if !isShowingMap{
            
            print("handleSwipe")
            let swipeDirection:UISwipeGestureRecognizerDirection = (gestureRecognize as! UISwipeGestureRecognizer).direction
            //currentSwipeDirection = swipeDirection
            
            print(" \(swipeDirection)")
            
                myGameScene.controller.joyStickDirection = .neutral
                myGameScene.controller.isChangedDirection = false
                isKeyPressed[.up] = false
                isKeyPressed[.right] = false
                isKeyPressed[.down] = false
                isKeyPressed[.left] = false
            
            switch swipeDirection{
            case UISwipeGestureRecognizerDirection.up://up
                print("handleSwipe - up")
                if myGameScene.controller.joyStickDirection != .up && !isKeyPressed[.up]!{
                    myGameScene.controller.joyStickDirection = .up
                    myGameScene.controller.isChangedDirection = true
                    isKeyPressed[.up] = true
                }
            case UISwipeGestureRecognizerDirection.right://right
                print("handleSwipe - right")
                if myGameScene.controller.joyStickDirection != .right && !isKeyPressed[.right]!{
                    myGameScene.controller.joyStickDirection = .right
                    myGameScene.controller.isChangedDirection = true
                    isKeyPressed[.right] = true
                }
            case UISwipeGestureRecognizerDirection.down://down
                print("handleSwipe - down")
                if myGameScene.controller.joyStickDirection != .down && !isKeyPressed[.down]!{
                    myGameScene.controller.joyStickDirection = .down
                    myGameScene.controller.isChangedDirection = true
                    isKeyPressed[.down] = true
                }
            case UISwipeGestureRecognizerDirection.left://left
                print("handleSwipe - left")
                if myGameScene.controller.joyStickDirection != .left && !isKeyPressed[.left]!{
                    myGameScene.controller.joyStickDirection = .left
                    myGameScene.controller.isChangedDirection = true
                    isKeyPressed[.left] = true
                }
            default:
                return
            
            }
        }
    }
    
        
    var panVelocity:CGPoint = CGPoint()
    var isPanGestureChanging:Bool = false
    var hasPanGestureEnded:Bool = false
    
    func handlePan(_ gestureRecognize: UIGestureRecognizer){
        print("handlePan")
        if isShowingMap{
            if gestureRecognize.state == .changed{
                hasPanGestureEnded = false
                isPanGestureChanging = true
                self.panVelocity = (gestureRecognize as! UIPanGestureRecognizer).velocity(in: self.view)
                
            }else if gestureRecognize.state == .ended{
                //self.panVelocity = CGPoint(x: 0, y: 0)
                
                hasPanGestureEnded = true//false
            }
            
            if gestureRecognize.state == UIGestureRecognizerState.possible{
                    panVelocity.y = 0
                    panVelocity.x = 0
            }
            
            
            
        }else if !isShowingMap {
            
            
            if myGameScene.isMovingToNextArea || myPlayer!.isStunned && myPlayer!.isAlive{
                
                myGameScene.controller.joyStickDirection = .neutral
                myGameScene.controller.isChangedDirection = false
                isKeyPressed[.up] = false
                isKeyPressed[.right] = false
                isKeyPressed[.down] = false
                isKeyPressed[.left] = false
                
                return
            }
            
            
            
            
            print("handlePan not in map")
            if gestureRecognize.state == .changed{
                isPanGestureChanging = true
                self.panVelocity = (gestureRecognize as! UIPanGestureRecognizer).velocity(in: self.view)
                
                let timer:CFTimeInterval = myGameScene.wallTimer
                let totalWaitingTime:CFTimeInterval = myGameScene.TIME_UNTIL_TRAP
                let status:SmashBlock.activity = myGameScene.smashBlockStatus
                
                if status == .waiting{
                    var pauseOnSec:CFTimeInterval = totalWaitingTime/1.5
                    //if optionsData["difficulty"]
                    if gameDifficultySetting == .easy{
                        pauseOnSec = totalWaitingTime/3
                    }
                    
                    if timer < pauseOnSec {
                        pauseControls = true
                    }else{
                        pauseControls = false
                    }
                    
                }else{
                    pauseControls = true
                }
                
                //if pauseControls{return}
                //add here
                if panVelocity.y.abs() > panVelocity.x.abs(){
                    if panVelocity.y < 0 {//up
                        print("pan - up")
                        if didCorrectSwipe(.up){
                            if !isKeyPressed[.up]!{
                                isKeyPressed[.up] = true
                                isKeyPressed[.right] = false
                                isKeyPressed[.down] = false
                                isKeyPressed[.left] = false
                                myGameScene.controller.isChangedDirection = true
                                myGameScene.controller.joyStickDirection = .up
                            }else if isKeyPressed[.up]!{
                                
                                myGameScene.controller.isChangedDirection = false
                            }
                        }
                    }else if panVelocity.y > 0{//down
                        print("pan - down")
                        if didCorrectSwipe(.down){
                        
                            if !isKeyPressed[.down]!{
                                isKeyPressed[.up] = false
                                isKeyPressed[.right] = false
                                isKeyPressed[.down] = true
                                isKeyPressed[.left] = false
                                myGameScene.controller.isChangedDirection = true
                                myGameScene.controller.joyStickDirection = .down
                            }else if isKeyPressed[.down]!{
                                
                                myGameScene.controller.isChangedDirection = false
                            }
                        }
                    }
                }else if panVelocity.y.abs() < panVelocity.x.abs(){
                    //print("pan - right")
                    if panVelocity.x > 0{//right
                        print("pan - right")
                        if didCorrectSwipe(.right){
                        
                            if !isKeyPressed[.right]!{
                                isKeyPressed[.up] = false
                                isKeyPressed[.right] = true
                                isKeyPressed[.down] = false
                                isKeyPressed[.left] = false
                                myGameScene.controller.isChangedDirection = true
                                myGameScene.controller.joyStickDirection = .right
                            }else if isKeyPressed[.right]!{
                                
                                myGameScene.controller.isChangedDirection = false
                            }
                        }
                    }else if panVelocity.x < 0{//left
                        print("pan - left")
                        if didCorrectSwipe(.left){
                        
                            if !isKeyPressed[.left]!{
                                isKeyPressed[.up] = false
                                isKeyPressed[.right] = false
                                isKeyPressed[.down] = false
                                isKeyPressed[.left] = true
                                myGameScene.controller.isChangedDirection = true
                                myGameScene.controller.joyStickDirection = .left
                            }else if isKeyPressed[.left]!{
                                
                                myGameScene.controller.isChangedDirection = false
                            }
                        }
                    }
                }else if panVelocity.y.abs() == panVelocity.x.abs(){
                    
                    myGameScene.controller.isChangedDirection = false
                    isKeyPressed[.up] = false
                    isKeyPressed[.right] = false
                    isKeyPressed[.down] = false
                    isKeyPressed[.left] = false
                }
                
                
                
                
            }else if gestureRecognize.state == .ended{
                self.panVelocity = CGPoint(x: 0, y: 0)
                
                myGameScene.controller.isChangedDirection = false
                isKeyPressed[.up] = false
                isKeyPressed[.right] = false
                isKeyPressed[.down] = false
                isKeyPressed[.left] = false
            }
            
            
            
        }
        
        
    }
    /*
    func addOrRemovePanGesture(){
        
        return
        
        if isShowingMap{
            self.myView.addGestureRecognizer(self.panGesture)
        }else if !isShowingMap{
            self.myView.removeGestureRecognizer(self.panGesture)
        }
    }
    */
    
    var isPinching:Bool = false
    var pinchScale:CGFloat = 0
    var isOutwardPinch:Bool = false
    
    func handlePinch(_ gestureRecognize: UIGestureRecognizer){
        
        if isChoosingDifficulty{
            return
        }
        
        if gestureRecognize.state == .ended{
            isPinching = false
            pinchScale = 0
            return
        }
        
        if gestureRecognize.state == .began{
            pinchScale = (gestureRecognize as! UIPinchGestureRecognizer).scale
            return
        }
        
        if gestureRecognize.state == .changed {//&& !isPinching{
            let nextPinchScale:CGFloat = (gestureRecognize as! UIPinchGestureRecognizer).scale
            if pinchScale - nextPinchScale < 0{
                if !isOutwardPinch{isPinching = false}
                isOutwardPinch = true
            }else if pinchScale - nextPinchScale > 0{
                if isOutwardPinch{isPinching = false}
                isOutwardPinch = false
            }else if pinchScale - nextPinchScale == 0{
                isPinching = true //false
            }
            pinchScale = nextPinchScale//(gestureRecognize as! UIPinchGestureRecognizer).scale
           // return
        }
        
        if isPinching{
            return
        }
        isPinching = true
        
        
        if /*!myPlayer!.isAlive || myGameScene.isFirstRound || */ !myGameScene.isMovingToNextArea{
           
            //map off
            if !isShowingMap && didReturnFromMap && !isOutwardPinch{
                
                particleSystem.reset()
                emittorNode.removeFromParentNode()
                
                print("View Controller starting to show map")
                print("playerNode x y = \(myPlayerNode.position.x), \(myPlayerNode.position.y)")
                print("cameraNode x y = \(self.myCameraNode.position.x), \(self.myCameraNode.position.y)")
                print("currentCameraNode x y = \(self.currentCameraPosition.x), \(self.currentCameraPosition.y)")
                //myCameraNode.constraints = nil
                //myCameraNode.position = cameraStartPosition
                myGameScene.isPaused = true
                // --------------------------------
                // need to pause 3D particle system here
                // --------------------------------
                
                didReturnFromMap = false
                self.showMap()
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = self.showingMapTime
                
                myCameraNode.position.x = myPlayerNode.position.x//cameraStartPosition.x
                myCameraNode.position.y = myPlayerNode.position.y//cameraStartPosition.y
                myCameraNode.position.z = 100  //test this
                
                
                SCNTransaction.completionBlock = {
                        self.isShowingMap = true
                        self.isMapKeyPressed[.up] = false
                        self.isMapKeyPressed[.right] = false
                        self.isMapKeyPressed[.down] = false
                        self.isMapKeyPressed[.left] = false
                        self.mapLastUpdateTime = self.mapCurrentTime
                        
                        
                        //self.hasMapView = true
                        self.myCameraNode.constraints = nil
                        self.myCameraNode.position.x = myPlayerNode.position.x//cameraStartPosition.x
                        self.myCameraNode.position.y = myPlayerNode.position.y//cameraStartPosition.y
                        
                        //self.addOrRemovePanGesture()
                        
                        
                    }
                SCNTransaction.commit()
                
            //map on
            }else if isShowingMap && isOutwardPinch{
                // *** background stars return to stage ***
                //emittorNode.position.z = -1
                //self.myScene.rootNode.addChildNode(emittorNode)
                //particleSystem.speedFactor = 3
                // ************
                isShowingMap = false
                //self.addOrRemovePanGesture()
                
                isMapKeyPressed[.up] = false
                isMapKeyPressed[.right] = false
                isMapKeyPressed[.down] = false
                isMapKeyPressed[.left] = false
                
                self.myStageNode.isHidden = false
                self.isReturnToCurrentStageMap = true
                
                self.returningToCurrentStageMapTime = ( 1 ) * CFTimeInterval(self.cameraDistanceFromCurrentStage() / myMaze!.maxMapAreaXValue)
                SCNTransaction.begin()
                SCNTransaction.animationDuration = self.returningToCurrentStageMapTime
                
                myCameraNode.position.x = myPlayerNode.position.x
                myCameraNode.position.y = myPlayerNode.position.y
                
                
                SCNTransaction.completionBlock = {
                        self.myScene.rootNode.addChildNode(self.emittorNode)
                        self.particleSystem.speedFactor = 3
                        self.isReturnToCurrentStageMap = false
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = self.showingMapTime
                        self.myCameraNode.position = self.currentCameraPosition
                        SCNTransaction.completionBlock = {
                                self.particleSystem.speedFactor = 1
                                self.removeMap()
                                
                                self.didReturnFromMap = true
                                self.myGameScene.isPaused = false
                                // --------------------------------
                                // need to resume 3D particle system here
                                // --------------------------------
                                
                                self.myCameraNode.position = self.currentCameraPosition
                                print("View Controller finished showing map")
                                print("playerNode x y = \(myPlayerNode.position.x), \(myPlayerNode.position.y)")
                                print("cameraNode x y = \(self.myCameraNode.position.x), \(self.myCameraNode.position.y)")
                                print("currentCameraNode x y = \(self.currentCameraPosition.x), \(self.currentCameraPosition.y)")
                            }
                        SCNTransaction.commit()
                    }
                SCNTransaction.commit()
            }
            
        }
        
    }
    
    
    var hasGameEnded:Bool = false
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        print("GVC handle tap")
        if isChoosingDifficulty{
            
            //let scnView = self.view as! SCNView
            let scnView = self.gameView as SCNView
            let viewPoint = gestureRecognize.location(in: scnView)
            
            let p = myHudOverlay.convertPoint(fromView: viewPoint)
            myHudOverlay.handleTap(p)
        
            return
        }
        
        
        if !myGameScene.isPaused { //while not showing the map
            
            
            
            if isGameOver{
                
                if let player = myPlayer{
                    if !player.isDying && !player.isAlive{
                        
                        isGameOver = false
                        hasGameEnded = true
                    }
                }
                
                
            }else{
                myGameScene.isFirstRound = false
                
                if let player = myPlayer{
                    if !player.isDying && !player.isAlive{
                        
                        
                        
                        myGameScene.playerComeBackToLife(player)
                    }
                }
                
            }
            
        }
     
        
 
    }
    
    
    
    #endif

    
    fileprivate var FIELD_STRENGTH:CGFloat = 6 * CGFloat(SPEED_PERCENTAGE)
    func addPhysicsField(){
        myPhysicsFieldNode = SCNNode()
        myScene.rootNode.addChildNode(myPhysicsFieldNode)
        myPhysicsFieldNode.position = SCNVector3(x: 0, y: 0, z: 0)
        myPhysicsField = SCNPhysicsField.spring()
        myPhysicsFieldNode.physicsField = myPhysicsField
        myPhysicsField.strength = FIELD_STRENGTH
    }
    
    func addEmittorNode(){
        myEmittorNode = SCNNode()
        myParticleSystem = SCNParticleSystem(named: "MyParticleSystem3.scnp", inDirectory: nil)
        myParticleSystem.isAffectedByPhysicsFields = true
        myScene.rootNode.addChildNode(myEmittorNode)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
    }
    //********************************************//
    /*
    override func mouseDown(theEvent: NSEvent) {
    print("mouseDown - GameViewController")
    super.mouseDown(theEvent)
    //        self.nextResponder!.mouseDown(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent) {
    super.mouseUp(theEvent)
    //        self.nextResponder!.mouseUp(theEvent)
    }*/
    //********************************************//
    var currentStageMapPosition:SCNVector3 = SCNVector3(x: 0, y: 0, z: 0)
    func showMap(){
        myScene = myView.scene
        myScene.rootNode.addChildNode(myMaze!)
        let currentStage = myGameScene.currentStage//myGameScene!.currentStage
        currentStageMapPosition = myMaze!.mazeCellMatrix[currentStage]!.position
        
        myMaze!.mazeCellMatrix[currentStage]!.isHidden = true
        myMaze!.position = SCNVector3(myStageNode.position.x - currentStageMapPosition.x, myStageNode.position.y -  currentStageMapPosition.y, 0)
        
    }
    
    func removeMap(){
        let currentStage = myGameScene.currentStage//myGameScene!.currentStage
        
        myMaze!.mazeCellMatrix[currentStage]!.isHidden = false
        myMaze!.removeFromParentNode()
    }
    
    func cameraDistanceFromCurrentStage()->CGFloat{
        var distance:CGFloat = 0
        distance = CGFloat(sqrt( pow(self.myCameraNode.position.x - myStageNode.position.x, 2) + pow(self.myCameraNode.position.y - myStageNode.position.y, 2)))
        
        return distance
    }
    
    var isShowingMap:Bool = false
    var currentCameraPosition = SCNVector3(x: 0, y: 0, z: 0)
    var showingMapTime:CFTimeInterval = 0.5
    var returningToCurrentStageMapTime:CFTimeInterval = 0.5
    var isReturnToCurrentStageMap:Bool = false
    
    #if os(OSX)
    override func keyDown(theEvent: NSEvent){
        Swift.print("KeyDown - GameViewController")
        
        let key = theEvent.keyCode
        switch key{
            
        case 126://up
            if isShowingMap && !isMapKeyPressed[.down]!{
                isMapKeyPressed[.up] = true
            }
        case 124://right
            if isShowingMap && !isMapKeyPressed[.left]!{
                isMapKeyPressed[.right] = true
            }
        case 125://down
            if isShowingMap && !isMapKeyPressed[.up]!{
                isMapKeyPressed[.down] = true
            }
        case 123://left
            if isShowingMap && !isMapKeyPressed[.right]!{
                isMapKeyPressed[.left] = true
            }
            
        case 46://M
            
            if !myGameScene.isMovingToNextArea{
                if !isShowingMap && didReturnFromMap{
                    print("View Controller starting to show map")
                    print("playerNode x y = \(myPlayerNode.position.x), \(myPlayerNode.position.y)")
                    print("cameraNode x y = \(self.myCameraNode.position.x), \(self.myCameraNode.position.y)")
                    print("currentCameraNode x y = \(self.currentCameraPosition.x), \(self.currentCameraPosition.y)")
    
                    myGameScene.paused = true
                    // --------------------------------
                    // need to pause 3D particle system here
                    // --------------------------------
                    
                    didReturnFromMap = false
                    self.showMap()
                    
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(self.showingMapTime)
                    
                    myCameraNode.position.x = myPlayerNode.position.x//cameraStartPosition.x
                    myCameraNode.position.y = myPlayerNode.position.y//cameraStartPosition.y
                    myCameraNode.position.z = 100
                    
                    
                    SCNTransaction.setCompletionBlock(
                        {
                            self.isShowingMap = true
                            self.isMapKeyPressed[.up] = false
                            self.isMapKeyPressed[.right] = false
                            self.isMapKeyPressed[.down] = false
                            self.isMapKeyPressed[.left] = false
                            self.mapLastUpdateTime = self.mapCurrentTime
                            
    
                            self.myCameraNode.constraints = nil
                            self.myCameraNode.position.x = myPlayerNode.position.x//cameraStartPosition.x
                            self.myCameraNode.position.y = myPlayerNode.position.y//cameraStartPosition.y
    
                            
                        }
                    )
                    SCNTransaction.commit()
                }else if isShowingMap{
    
                    isShowingMap = false
                    
                    isMapKeyPressed[.up] = false
                    isMapKeyPressed[.right] = false
                    isMapKeyPressed[.down] = false
                    isMapKeyPressed[.left] = false
    
    
                    self.myStageNode.hidden = false
                    self.isReturnToCurrentStageMap = true
    
                    
                    self.returningToCurrentStageMapTime = ( 1 ) * CFTimeInterval(self.cameraDistanceFromCurrentStage() / myMaze!.maxMapAreaXValue)
                    
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(self.returningToCurrentStageMapTime)
                    
                    myCameraNode.position.x = myPlayerNode.position.x
                    myCameraNode.position.y = myPlayerNode.position.y
    
                    
                    SCNTransaction.setCompletionBlock(
                        {
                            self.isReturnToCurrentStageMap = false
                            SCNTransaction.begin()
                            SCNTransaction.setAnimationDuration(self.showingMapTime)
                            self.myCameraNode.position = self.currentCameraPosition
                            SCNTransaction.setCompletionBlock(
                                {
                                    self.removeMap()
    
                                    self.didReturnFromMap = true
                                    self.myGameScene.paused = false
                                    // --------------------------------
                                    // need to resume 3D particle system here
                                    // --------------------------------
                                    
                                    self.myCameraNode.position = self.currentCameraPosition
                                    print("View Controller finished showing map")
                                    print("playerNode x y = \(myPlayerNode.position.x), \(myPlayerNode.position.y)")
                                    print("cameraNode x y = \(self.myCameraNode.position.x), \(self.myCameraNode.position.y)")
                                    print("currentCameraNode x y = \(self.currentCameraPosition.x), \(self.currentCameraPosition.y)")
                                }
                            )
                            SCNTransaction.commit()
                        }
                    )
                    SCNTransaction.commit()
                }
                
            }
        case 35://P
            if !myPlayer!.isAlive || myGameScene.isFirstRound || myGameScene.isMovingToNextArea{
                //break
            }else{
                myGameScene.paused = !myGameScene.paused
            }
            
        default:
            print("View Controller KeyDown")
            break
        }
        
        if !myGameScene.paused{
            self.myGameScene.keyDown(theEvent)
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        
        let key = theEvent.keyCode
        switch key{
            
        case 126://up
            if isShowingMap{
                isMapKeyPressed[.up] = false
            }
        case 124://right
            if isShowingMap{
                isMapKeyPressed[.right] = false
            }
        case 125://down
            if isShowingMap{
                isMapKeyPressed[.down] = false
            }
        case 123://left
            if isShowingMap{
                isMapKeyPressed[.left] = false
            }
        default:
            if isShowingMap{
                
            }
            break
        }
        
        
        
        self.myGameScene.keyUp(theEvent)
        
        
    }
    
    
    #endif //os(ios)
    
    func deathEffectUpdate(){
        if myGameScene.isSlowedDown{
            if myParticleSystem.isAffectedByPhysicsFields{
                myParticleSystem.isAffectedByPhysicsFields = false
            }
        }else if !myGameScene.isSlowedDown{
            
            if !myParticleSystem.isAffectedByPhysicsFields{
                myParticleSystem.isAffectedByPhysicsFields = true
            }
        }
        
        if myPlayer!.isDying{self.deathScene(myGameScene.deltaTime)}
        
    }
    
    func isPlayerMovingToNewAreaVertically()->Bool{
        var vertically:Bool = false
        //if myGameScene!.leavingVelocity.dx.abs() > myGameScene!.leavingVelocity.dy.abs(){
        if myGameScene.leavingVelocity.dx.abs() > myGameScene.leavingVelocity.dy.abs(){
            vertically = false
        //}else if myGameScene!.leavingVelocity.dy.abs() > myGameScene!.leavingVelocity.dx.abs(){
        }else if myGameScene.leavingVelocity.dy.abs() > myGameScene.leavingVelocity.dx.abs(){
            vertically = true
        }
        
        return vertically
    }
    
    func playerUpdate(){
        
        
        if myGameScene.hasWorldMovement{
            myPlayerNode.position = SCNVector3(x: 0, y: 0, z: myPlayerNode.position.z)
        }
        else{// now done in the GameScene.swift directly
            updateMyPlayerNode()
        }
        
        //check if player is alive and relate it to 3D
        let isAlive = myPlayer!.isAlive
        let isHidden = myPlayerNode.isHidden
        if isAlive {
            if isHidden{
                myPlayerNode.isHidden = false
                
                for (_, tailPiece) in myPlayerTailNodeArray.enumerated(){
                    tailPiece.isHidden = true
                }
                
                let playerLives = myGameScene.playerLives
                if playerLives > 1{
                    for tailIndex in 0...playerLives - 2{
                        myPlayerTailNodeArray[tailIndex].isHidden = false
                    }
                    
                }
                
                
                if myGameScene.isFirstRound {
                    myPlayerNode.isHidden = true
                    for (_, tailPiece) in myPlayerTailNodeArray.enumerated(){
                        
                        tailPiece.isHidden = true
                        
                    }
                }
                
                
                #if os(iOS)
                myPhysicsFieldNode.position = SCNVector3(x: Float(-gameFrame.size.width/2 + myPlayer!.position.x)  * 10   / Float(gameFrame.size.width) , y: Float(-gameFrame.size.height/2 + myPlayer!.position.y)  * 10  / Float(gameFrame.size.height), z: 0)
                #elseif os(OSX)
                myPhysicsFieldNode.position = SCNVector3(x: (-gameFrame.size.width/2 + myPlayer!.position.x)  * 10   / gameFrame.size.width , y: (-gameFrame.size.height/2 + myPlayer!.position.y)  * 10  / gameFrame.size.height, z: 0)
                 #endif
                if !myGameScene.hasWorldMovement{
                    myPhysicsFieldNode.position = self.myStageNode.position
                    
                }
                
            }
        }else {
            if !isHidden{
                #if os(iOS)
                myPhysicsFieldNode.position = SCNVector3(x: Float(gameFrame.size.width/2 - myPlayer!.deathPosition.x)  * 10 / Float(gameFrame.size.width) , y: Float(gameFrame.size.height/2 - myPlayer!.deathPosition.y)  * 10  / Float(gameFrame.size.height), z: Float(myPlayerNode.position.z))
                #elseif os(OSX)
                myPhysicsFieldNode.position = SCNVector3(x: (gameFrame.size.width/2 - myPlayer!.deathPosition.x)  * 10  / gameFrame.size.width , y: (gameFrame.size.height/2 - myPlayer!.deathPosition.y)  * 10  / gameFrame.size.height, z: myPlayerNode.position.z)
                #endif
                myEmittorNode.position = myPlayerNode.position
                
                
                if !myGameScene.hasWorldMovement{
                    myPhysicsFieldNode.position = self.myStageNode.position
                    
                    myEmittorNode.position = myPlayerNode.position
                    
                    
                }
                
                if myPlayer!.isDying{
                    myEmittorNode.addParticleSystem(myParticleSystem)
                }else if !myPlayer!.isDying{
                    
                }
                
                if myGameScene.isFirstRound {
                    
                    for (_, tailPiece) in myPlayerTailNodeArray.enumerated(){
                        
                        tailPiece.isHidden = true
                        
                    }
                }
                
                
                myPlayerNode.isHidden = true
                
            }
        }
    }
    
    
    let maxCameraDistance:CGFloat = 15
    let minimumCameraAngle:CGFloat = 25 //Maximum value allowed: 90
    
    var cameraMovingtoNewAreaPosition:SCNVector3 = SCNVector3(x: 0 , y: 0, z: 0)
    var leavingLastUpdateTime: TimeInterval = 0
    var leavingAreaTime: TimeInterval = 0
    
    var willChangeCameraForNewArea:Bool = false
    var didChangeCameraForNewArea:Bool = false
    var didReturnFromMap:Bool = true
    
    var mapLastUpdateTime: TimeInterval = 0
    var mapDeltaTime: TimeInterval = 0
    var mapCurrentTime: TimeInterval = 0
    
    
    
    func cameraUpdate(_ currentTime: TimeInterval){
       
        
        self.mapCurrentTime = currentTime //used for KeyDown time keeping
        if isShowingMap || !didReturnFromMap{
            if isShowingMap {
                myCameraNode.constraints = nil
                
                // *****add camera movement for map*****
                mapDeltaTime = currentTime - mapLastUpdateTime
                mapLastUpdateTime = currentTime
                
                    #if os(OSX)
                if isMapKeyPressed[.up]!{
                    myCameraNode.position.y = myCameraNode.position.y + 1 * CGFloat(mapDeltaTime)*100
                }else if isMapKeyPressed[.down]!{
                    myCameraNode.position.y = myCameraNode.position.y - 1 * CGFloat(mapDeltaTime)*100
                }
                
                if isMapKeyPressed[.left]!{
                    myCameraNode.position.x = myCameraNode.position.x - 1 * CGFloat(mapDeltaTime)*100
                }else if isMapKeyPressed[.right]!{
                    myCameraNode.position.x = myCameraNode.position.x + 1 * CGFloat(mapDeltaTime)*100
                }
                
                //******* Map Movement Limit **************
                
                if myCameraNode.position.x > myMaze!.position.x + myMaze!.maxMapAreaXValue{
                    myCameraNode.position.x = myMaze!.position.x + myMaze!.maxMapAreaXValue
                }
                if myCameraNode.position.x < myMaze!.position.x - myMaze!.minMapAreaXValue{
                    myCameraNode.position.x = myMaze!.position.x - myMaze!.minMapAreaXValue
                }
                if myCameraNode.position.y > myMaze!.position.y + myMaze!.maxMapAreaYValue{
                    myCameraNode.position.y = myMaze!.position.y + myMaze!.maxMapAreaYValue
                }
                if myCameraNode.position.y < myMaze!.position.y - myMaze!.minMapAreaYValue{
                    myCameraNode.position.y = myMaze!.position.y - myMaze!.minMapAreaYValue
                }
                    #elseif os(iOS)
                if isPanGestureChanging {
                    myCameraNode.position.y = myCameraNode.position.y + Float(mapDeltaTime) * Float(panVelocity.y) / 4
                    myCameraNode.position.x = myCameraNode.position.x - Float(mapDeltaTime) * Float(panVelocity.x) / 4
                            
                    isPanGestureChanging = false
                }
                        
                        if isShowingMap{ //delete
                            if hasPanGestureEnded{
                                let totalPanVelocity = sqrt(pow(panVelocity.y, 2) + pow(panVelocity.x, 2))
                                
                                //asfsdfadsf
                                
                                panVelocity.y -= 0.05 * panVelocity.y
                                panVelocity.x -= 0.05 * panVelocity.x
                                
                                if totalPanVelocity < 1 {
                                    hasPanGestureEnded = false
                                    panVelocity.y = 0
                                    panVelocity.x = 0
                                }
                                
                                myCameraNode.position.y = myCameraNode.position.y + Float(mapDeltaTime) * Float(panVelocity.y) / 4
                                myCameraNode.position.x = myCameraNode.position.x - Float(mapDeltaTime) * Float(panVelocity.x) / 4
                                
                            }
                            
                        }
                        
                //******* Map Movement Limit **************
                
                if myCameraNode.position.x > (myMaze!.position.x) + Float(myMaze!.maxMapAreaXValue){
                    myCameraNode.position.x = myMaze!.position.x + Float(myMaze!.maxMapAreaXValue)
                }
                if myCameraNode.position.x < myMaze!.position.x - Float(myMaze!.minMapAreaXValue){
                    myCameraNode.position.x = myMaze!.position.x - Float(myMaze!.minMapAreaXValue)
                }
                if myCameraNode.position.y > myMaze!.position.y + Float(myMaze!.maxMapAreaYValue){
                    myCameraNode.position.y = myMaze!.position.y + Float(myMaze!.maxMapAreaYValue)
                }
                if myCameraNode.position.y < myMaze!.position.y - Float(myMaze!.minMapAreaYValue){
                    myCameraNode.position.y = myMaze!.position.y - Float(myMaze!.minMapAreaYValue)
                }
                
                    #endif
                // *****************************************
                
                // *************************************
                
            }else if !isReturnToCurrentStageMap{
                myCameraNode.constraints = nil
                let lookAtPlayerConstraint = SCNLookAtConstraint(target: myPlayerNode)
                lookAtPlayerConstraint.isGimbalLockEnabled = false
                myCameraNode.constraints = [lookAtPlayerConstraint]
            }
            return
        }
        
        
        if myCameraNode == nil{
            self.setupCamera()
        }
        
        myCameraNode.constraints = nil
        
        if !myGameScene.isLeavingOldArea{
            
            
            leavingAreaTime = 0
            leavingLastUpdateTime = currentTime
            
            let playerRadius:CGFloat = (myPlayerNode.geometry as! SCNSphere).radius
            // pathegorian theorem
            let xMaxValuePlayerNode:CGFloat = (myStageNode.geometry as! SCNPlane).width/2 - playerRadius - cornerBlockFrame.width/10
            let yMaxValuePlayerNode:CGFloat = (myStageNode.geometry as! SCNPlane).height/2 - playerRadius - cornerBlockFrame.height/10
            
            // c squared = x squared + y squared
            //let cMaxValuePlayerNode:CGFloat = sqrt( pow(xMaxValuePlayerNode, 2) + pow(yMaxValuePlayerNode, 2) )
            
            //let midMaxValuePlayerNode:CGFloat = xMaxValuePlayerNode + (cMaxValuePlayerNode - xMaxValuePlayerNode)/2
            
            var xValue:CGFloat = maxCameraDistance * CGFloat((myPlayerNode.position.x - myStageNode.position.x)) / xMaxValuePlayerNode //c: makes the camera angle relative to the corners
            var yValue:CGFloat = maxCameraDistance * CGFloat((myPlayerNode.position.y - myStageNode.position.y)) / yMaxValuePlayerNode //c: makes the camera angle relative to the corners
            
            
            let cValueCameraScale:CGFloat = sqrt( pow( (xValue), 2) + pow( (yValue), 2))
            
            var zValueAlternative:CGFloat = sqrt( pow(maxCameraDistance, 2) - pow(cValueCameraScale, 2))
            if zValueAlternative <= maxCameraDistance * minimumCameraAngle/90{
                zValueAlternative = maxCameraDistance * minimumCameraAngle/90
                
                xValue = xValue / cValueCameraScale * sqrt( (1 - pow(minimumCameraAngle/90, 2)) * pow(maxCameraDistance,2) )
                yValue = yValue / cValueCameraScale * sqrt( (1 - pow(minimumCameraAngle/90, 2)) * pow(maxCameraDistance,2) )
                
            }
            
            
                #if os(OSX)
            let x:CGFloat = CGFloat(myPlayerNode.position.x) - xValue //-xValue
            let y:CGFloat = CGFloat(myPlayerNode.position.y) - yValue //-yValue
            let z:CGFloat =  zValueAlternative//zValue
                #elseif os(iOS)
            let x:Float = Float(myPlayerNode.position.x) - Float(xValue) //-xValue
            let y:Float = Float(myPlayerNode.position.y) - Float(yValue) //-yValue
            let z:Float = Float(zValueAlternative)//zValue
                #endif
            myCameraNode.position = SCNVector3(x: x , y: y, z: z)
            cameraMovingtoNewAreaPosition = myCameraNode.position
            currentCameraPosition = myCameraNode.position
            //c = 20 => max distance from camera to player c pow 2 = 400 = (x2 + y2) + z2
            
            
        }else if myGameScene.isLeavingOldArea{
            let leavingDeltaTime = currentTime - leavingLastUpdateTime
            leavingAreaTime += leavingDeltaTime
            leavingLastUpdateTime = currentTime
            
            
            if leavingAreaTime > myGameScene.leavingTime{
                didChangeCameraForNewArea = false
                willChangeCameraForNewArea = false
                
                
            }else if leavingAreaTime > myGameScene.leavingTime/2{
                if !didChangeCameraForNewArea{
                    willChangeCameraForNewArea = true
                    
                    if !isPlayerMovingToNewAreaVertically(){
                        
                        myCameraNode.position = SCNVector3(x: myStageNode.position.x - cameraMovingtoNewAreaPosition.x, y: cameraMovingtoNewAreaPosition.y, z: cameraMovingtoNewAreaPosition.z)
                        
                    }else if isPlayerMovingToNewAreaVertically(){
                        
                        myCameraNode.position = SCNVector3(x: cameraMovingtoNewAreaPosition.x, y: myStageNode.position.y - cameraMovingtoNewAreaPosition.y, z: cameraMovingtoNewAreaPosition.z)
                    }
                }
            }
        }
        
        
        
        if myCameraNode.constraints == nil{
            
            let lookAtPlayerConstraint = SCNLookAtConstraint(target: myPlayerNode)
            lookAtPlayerConstraint.isGimbalLockEnabled = false
            myCameraNode.constraints = [lookAtPlayerConstraint]
            
        }
        
        
        
        
    }
    
    func animationUpdate(){
        
        myView.isPlaying = true
        
    }
    
    
    var willComeToLife:Bool = true
    func updateMyPlayerNode(){
        if myPlayerNode == nil{
            self.addPlayerNode()
        }
        
        if myGameScene.isPaused{
            return
        }
        
        if !myGameScene.isLeavingOldArea{
            
            
            //all the detail added to account for corner hit deaths ie. isEdgeHitDeathOn = true
                #if os(iOS)
            if myPlayer!.isAlive{
                if willComeToLife{
                    myPlayerNode.position = SCNVector3(x: Float(myPlayer!.originalPosition.x - gameFrame.size.width/2) * 10 / Float(gameFrame.size.width) , y: Float(myPlayer!.originalPosition.y - gameFrame.size.height/2) * 10 / Float(gameFrame.size.height), z: 0)
                    willComeToLife = false
                }else{
                    myPlayerNode.position = SCNVector3(x: Float(myPlayer!.position.x - gameFrame.size.width/2) * 10 / Float(gameFrame.size.width) , y: Float(myPlayer!.position.y - gameFrame.size.height/2) * 10 / Float(gameFrame.size.height), z: 0)
                }
                
            }else if !myPlayer!.isAlive{
                willComeToLife = true
                myPlayerNode.position = SCNVector3(x: Float(myPlayer!.deathPosition.x - gameFrame.size.width/2) * 10 / Float(gameFrame.size.width) , y: Float(myPlayer!.deathPosition.y - gameFrame.size.height/2) * 10 / Float(gameFrame.size.height), z: 0)
                if myGameScene.isFirstRound{
                    myPlayerNode.position = SCNVector3(x: Float(myPlayer!.originalPosition.x - gameFrame.size.width/2) * 10 / Float(gameFrame.size.width) , y: Float(myPlayer!.originalPosition.y - gameFrame.size.height/2) * 10 / Float(gameFrame.size.height), z: 0)
                }
            }
                #elseif os(OSX)
            if myPlayer!.isAlive{
                if willComeToLife{
                    myPlayerNode.position = SCNVector3(x: (myPlayer!.originalPosition.x - gameFrame.size.width/2) * 10 / gameFrame.size.width , y: (myPlayer!.originalPosition.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0)
                    willComeToLife = false
                }else{
                    myPlayerNode.position = SCNVector3(x: (myPlayer!.position.x - gameFrame.size.width/2) * 10 / gameFrame.size.width , y: (myPlayer!.position.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0)
                }
                
            }else if !myPlayer!.isAlive{
                willComeToLife = true
                myPlayerNode.position = SCNVector3(x: (myPlayer!.deathPosition.x - gameFrame.size.width/2) * 10 / gameFrame.size.width , y: (myPlayer!.deathPosition.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0)
                if myGameScene.isFirstRound{
                    myPlayerNode.position = SCNVector3(x: (myPlayer!.originalPosition.x - gameFrame.size.width/2) * 10 / gameFrame.size.width , y: (myPlayer!.originalPosition.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0)
                }
            }
                #endif
    
            
            let playerLives = myGameScene.playerLives
            if playerLives > 0{//1
                for (tailIndex, _/*tailPiece*/) in myPlayerTailNodeArray.enumerated(){
                    
                        #if os(iOS)
                    if myPlayer!.isAlive{
                        
                        myPlayerTailNodeArray[tailIndex].position = SCNVector3(x: Float(myPlayerTail[tailIndex].position.x ) * 10 / Float(gameFrame.size.width) + myPlayerNode.position.x , y: Float(myPlayerTail[tailIndex].position.y) * 10 / Float(gameFrame.size.height) + myPlayerNode.position.y, z: 0)
                        
                        
                    }else if !myPlayer!.isAlive{
                        
                        myPlayerTailNodeArray[tailIndex].position = SCNVector3(x: Float(myPlayerTail[tailIndex].position.x - gameFrame.size.width/2) * 10 / Float(gameFrame.size.width) , y: Float(myPlayerTail[tailIndex].position.y - gameFrame.size.height/2) * 10 / Float(gameFrame.size.height), z: 0)
                        if myGameScene.isFirstRound{
                            //break
                        }
                    }
                        #elseif os(OSX)
                    if myPlayer!.isAlive{
                        
                        myPlayerTailNodeArray[tailIndex].position = SCNVector3(x: (myPlayerTail[tailIndex].position.x ) * 10 / gameFrame.size.width + myPlayerNode.position.x , y: (myPlayerTail[tailIndex].position.y) * 10 / gameFrame.size.height + myPlayerNode.position.y, z: 0)
                        
                    }else if !myPlayer!.isAlive{
                        
                        myPlayerTailNodeArray[tailIndex].position = SCNVector3(x: (myPlayerTail[tailIndex].position.x - gameFrame.size.width/2) * 10 / gameFrame.size.width , y: (myPlayerTail[tailIndex].position.y - gameFrame.size.height/2) * 10 / gameFrame.size.height, z: 0)
                        if myGameScene.isFirstRound{
                            //break
                        }
                    }
                    
                        #endif
                
                    
                    
                }
                
            }
            
            
        }else if myGameScene.isLeavingOldArea{
            let speedReductionFactor:CGFloat = 20
            
            var velocityX = myPlayer!.physicsBody!.velocity.dx
            var velocityY = myPlayer!.physicsBody!.velocity.dy
            
            //(myGameScene!.leavingVelocity.dx / speedReductionFactor).abs(){
            if velocityX.abs() > (myGameScene.leavingVelocity.dx / speedReductionFactor).abs(){
                velocityX = myGameScene.leavingVelocity.dx / speedReductionFactor//myGameScene!.leavingVelocity.dx / speedReductionFactor
            }
            //(myGameScene!.leavingVelocity.dy / speedReductionFactor).abs(){
            if velocityY.abs() > (myGameScene.leavingVelocity.dy / speedReductionFactor).abs(){
                velocityY = myGameScene.leavingVelocity.dy / speedReductionFactor//myGameScene!.leavingVelocity.dy / speedReductionFactor
            }
            
                #if os(OSX)
            myPlayerNode.position  = SCNVector3(x: myPlayerNode.position.x + (velocityX * 10 / gameFrame.size.width) , y: myPlayerNode.position.y + (velocityY * 10 / gameFrame.size.height), z: 0)
                #elseif os(iOS)
            myPlayerNode.position = SCNVector3(x: myPlayerNode.position.x + Float(velocityX * 10 / gameFrame.size.width) , y: myPlayerNode.position.y + Float(velocityY * 10 / gameFrame.size.height), z: 0)
                #endif
            
        
            for (tailIndex, _/*tailPiece*/) in myPlayerTailNodeArray.enumerated(){
                
                
                    #if os(iOS)
                myPlayerTailNodeArray[tailIndex].position = SCNVector3(x: Float(myPlayerTail[tailIndex].position.x ) * 10 / Float(gameFrame.size.width) + myPlayerNode.position.x, y: Float(myPlayerTail[tailIndex].position.y) * 10 / Float(gameFrame.size.height) + myPlayerNode.position.y, z: 0)
                    #elseif os(OSX)
                myPlayerTailNodeArray[tailIndex].position = SCNVector3(x: (myPlayerTail[tailIndex].position.x ) * 10 / gameFrame.size.width + myPlayerNode.position.x, y: (myPlayerTail[tailIndex].position.y) * 10 / gameFrame.size.height + myPlayerNode.position.y, z: 0)
                    #endif
                
            }
            
            
            //check if the Player has arrived in the new area
            if leavingAreaTime > myGameScene.leavingTime/2{
                var didReachNewArea:Bool = false
                
                    #if os(iOS)
                if myPlayerNode.position.x.abs() < Float(myGameScene.arrivingPosition.x.abs()) && !isPlayerMovingToNewAreaVertically(){
                    
                    if leavingAreaTime > myGameScene.leavingTime {
                        didReachNewArea = true
                    }
                    
                    
                }else if myPlayerNode.position.y.abs() < Float(myGameScene.arrivingPosition.y.abs()) && isPlayerMovingToNewAreaVertically(){
                    
                    if leavingAreaTime > myGameScene.leavingTime {
                        didReachNewArea = true
                    }
                    
                }
                    #elseif os(OSX)
                if myPlayerNode.position.x.abs() < myGameScene.arrivingPosition.x.abs() && !isPlayerMovingToNewAreaVertically(){
                    if leavingAreaTime > myGameScene.leavingTime {didReachNewArea = true}
                }else if myPlayerNode.position.y.abs() < myGameScene.arrivingPosition.y.abs() && isPlayerMovingToNewAreaVertically(){
                    if leavingAreaTime > myGameScene.leavingTime {didReachNewArea = true}
                }
                    #endif
                
                
                if didReachNewArea{
                    myGameScene.isLeavingOldArea = false
                    //Increase stage count / Level count
                    //myGameScene.stageUpLevelUp() //done in afterArrivingInNewAreaAction in GameScene
                    //********************************
                    
                    myGameScene.arrivedInNewArea(myGameScene.arrivingPosition, playerVelocity: myGameScene.leavingVelocity)
                    
                    
                    myGameScene.afterArrivingInNewAreaAction(myGameScene.arrivingPosition, playerVelocity: myGameScene.leavingVelocity)
                    
                    
                }
                
            }
            
            
            if willChangeCameraForNewArea{
                willChangeCameraForNewArea = false
                didChangeCameraForNewArea = true
                let newPlayerNodePositionX = myStageNode.position.x - myPlayerNode.position.x
                let newPlayerNodePositionY = myStageNode.position.y - myPlayerNode.position.y
                
                if !isPlayerMovingToNewAreaVertically(){
                    myPlayerNode.position = SCNVector3(x: newPlayerNodePositionX, y: myPlayerNode.position.y , z: myPlayerNode.position.z)
                    
                }else if isPlayerMovingToNewAreaVertically(){
                    myPlayerNode.position = SCNVector3(x: myPlayerNode.position.x, y: newPlayerNodePositionY , z: myPlayerNode.position.z)
                    
                }
                
                
                
                for (tailIndex, _/*tailPiece*/) in myPlayerTailNodeArray.enumerated(){
                    
                    
                    myPlayerTailNodeArray[tailIndex].position = SCNVector3(x: myPlayerTailNodeArray[tailIndex].position.x - newPlayerNodePositionX , y: myPlayerTailNodeArray[tailIndex].position.y - newPlayerNodePositionY, z: 0)
                    
                    
                }
            }
            
            
            
        }
    }
    
    func checkPanGestureDuringActiveGame(){
        if !gameScene.isPaused{ //with map off
            if isPanGestureChanging {
                isPanGestureChanging = false
            }else if !isPanGestureChanging{
                //add here
                
                myGameScene.controller.isChangedDirection = false
                isKeyPressed[.up] = false
                isKeyPressed[.right] = false
                isKeyPressed[.down] = false
                isKeyPressed[.left] = false
            }
        }
    }
    
    var currentSwipeDirection:JoyStick.direction? = nil
    func didCorrectSwipe(_ panDirection:JoyStick.direction)->Bool{
        var isCorrectDirection:Bool = false
        
        let block:SmashBlock.blockPosition = myGameScene.activeSmashBlock!
        let exit:SmashBlock.blockPosition = myGameScene.exitBlock
        currentSwipeDirection = panDirection
        //var correctSwipeDirection:JoyStick.direction = panDirection
        
        if myGameScene.level > 1 {
            isCorrectDirection = true
            didCorrectSwipeDirection = false
        }else if !didCorrectSwipeDirection{
        
            switch block{
            case .bottomLeft, .topLeft:
                print("dodge right or exit left")
                if block.opposite() == exit{
                    //correctSwipeDirection = .left
                    if currentSwipeDirection! == .left{
                        isCorrectDirection = true
                    }
                }else{
                    //correctSwipeDirection = .right
                    if currentSwipeDirection! == .right{
                        isCorrectDirection = true
                    }
                }
            case .bottomRight, .topRight:
                print("dodge left or exit right")
                if block.opposite() == exit{
                    //correctSwipeDirection = .right
                    if currentSwipeDirection! == .right{
                        isCorrectDirection = true
                    }
                }else{
                    //correctSwipeDirection = .left
                    if currentSwipeDirection! == .left{
                        isCorrectDirection = true
                    }
                }
            case .rightTop, .leftTop:
                print("dodge down or exit up")
                if block.opposite() == exit{
                    //correctSwipeDirection = .up
                    if currentSwipeDirection! == .up{
                        isCorrectDirection = true
                    }
                }else{
                    //correctSwipeDirection = .down
                    if currentSwipeDirection! == .down{
                        isCorrectDirection = true
                    }
                }
            case .rightBottom, .leftBottom:
                print("dodge up or exit down")
                if block.opposite() == exit{
                    //correctSwipeDirection = .down
                    if currentSwipeDirection! == .down{
                        isCorrectDirection = true
                    }
                }else{
                    //correctSwipeDirection = .up
                    if currentSwipeDirection! == .up{
                        isCorrectDirection = true
                    }
                }
            }
            
            didCorrectSwipeDirection = isCorrectDirection

            //print("\(didCorrectSwipeDirection) ---- WHAT THE FUCK")
        }
        
        
        
        
        return isCorrectDirection
    }
    
    
    var hasTutorialImage:Bool = false
    func addTutorialImage(){
        let block:SmashBlock.blockPosition = myGameScene.activeSmashBlock!
        let exit:SmashBlock.blockPosition = myGameScene.exitBlock
        var correctSwipeDirection:JoyStick.direction? = nil//JoyStick.direction.down
        
        switch block{
        case .bottomLeft, .topLeft:
            if block.opposite() == exit{
                correctSwipeDirection = .left
            }else{
                correctSwipeDirection = .right
            }
        case .bottomRight, .topRight:
            if block.opposite() == exit{
                correctSwipeDirection = .right
            }else{
                correctSwipeDirection = .left
            }
        case .rightTop, .leftTop:
            if block.opposite() == exit{
                correctSwipeDirection = .up
            }else{
                correctSwipeDirection = .down
            }
        case .rightBottom, .leftBottom:
            if block.opposite() == exit{
                correctSwipeDirection = .down
            }else{
                correctSwipeDirection = .up
            }
        }
        //let folder = "tutorial images"
        
        //tutorialImages = ["left":UIImage.init(named: "\(folder)/left.png")!, "right":UIImage.init(named: "\(folder)/right.png")!, "up":UIImage.init(named: "\(folder)/up.png")!, "down":UIImage.init(named: "\(folder)/down.png")!, "in":UIImage.init(named: "\(folder)/in.png")!, "out":UIImage.init(named: "\(folder)/out.png")!, "tap":UIImage.init(named: "\(folder)/tap.png")!]
        
        //imageView.image = nil//UIImage.init(named: "\(folder)/right.png")!//tutorialImages["right"]
        print("\(correctSwipeDirection)")
        switch correctSwipeDirection!{
        case .up:
            myHudOverlay.image.texture = SKTexture(imageNamed: "tutorial images/up.png")
            hasTutorialImage = true
            print(" got here up image")
        case .down:
            myHudOverlay.image.texture = SKTexture(imageNamed: "tutorial images/down.png")
            hasTutorialImage = true
            print(" got here down image")
        case .left:
            myHudOverlay.image.texture = SKTexture(imageNamed: "tutorial images/left.png")
            hasTutorialImage = true
            print(" got here -left image")
        case .right:
            myHudOverlay.image.texture = SKTexture(imageNamed: "tutorial images/right.png")
            hasTutorialImage = true
            print(" got here -right image")
        default:
            break
        }
        
        myHudOverlay.image.isHidden = false
        
    }
    
    
    var pauseControls:Bool = false
    var didCorrectSwipeDirection:Bool = false
    func updateTutorial(){
        //myGameScene.isTrapWallPaused = true //this will pause the wall traps
        
        if myGameScene.level == 1{
        
            let timer:CFTimeInterval = myGameScene.wallTimer
            let totalWaitingTime:CFTimeInterval = myGameScene.TIME_UNTIL_TRAP
            let status:SmashBlock.activity = myGameScene.smashBlockStatus
            //let exit:SmashBlock.blockPosition = myGameScene.exitBlock
            //let block:SmashBlock.blockPosition = myGameScene.activeSmashBlock!
            //let hasStatusChanged:Bool = myGameScene.smashStatusChanged
            //var swipeDirection:UISwipeGestureRecognizerDirection? = currentSwipeDirection
        
            
            if myGameScene.isPaused {
                //imageView.hidden = false
            }
            
            if status == .waiting{
                var pauseOnSec:CFTimeInterval = totalWaitingTime/1.5
                //if optionsData["difficulty"]
                if gameDifficultySetting == .easy{
                    pauseOnSec = totalWaitingTime/3
                    
                }
                
                
                //pauseControls = false
                
                if timer >= pauseOnSec{
                    //pauseControls = false
                    if !didCorrectSwipeDirection{
                        
                        if !hasTutorialImage{
                            addTutorialImage()
                            
                            
                            //print(" got here \(imageView.image)")
                            //imageView.hidden = false
                            
                        }
                        
                        myGameScene.isPaused = true
                        myPlayer?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                        
                        myGameScene.needsRecoveryTimeFromPause = true
                        /*
                        if exit.opposite() == block{
                            //myGameScene.wallTimer = 0
                            myGameScene.needsRecoveryTimeFromPause = true
                            //myGameScene.paused = true
                        }
 */
                        
                    }else{
                        myGameScene.isPaused = false
                        myHudOverlay.image.isHidden = true
                    }
                    
                }else {
                   // pauseControls = true
                    myGameScene.isPaused = false
                    myHudOverlay.image.isHidden = true
                    if !didCorrectSwipeDirection{
                        
                    }else{
                        myGameScene.isPaused = false
                    }
                }
                
                
                // ***************
                //tutorial images setting
                //if !isShowingMap && !isGameOver && (myPlayer?.isAlive)! && myGameScene.paused{
                //    imageView.hidden = false
                //}
                // ***************
               
                
            }else if status == .smashing || status == .returning{
                //didCorrectSwipe = false
                didCorrectSwipeDirection = false
                pauseControls = true
                hasTutorialImage = false
                myHudOverlay.image.isHidden = true
                
            }
            
        }
    }
    var showOneTime:Bool = false
    var showOneTime2:Bool = false
    //var hasChangedGlobalBackground:Bool = false
    func renderer(_ aRenderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if showOneTime == false{
          //  imageView.image = UIImage(named: "tutorial images/left.png")
            showOneTime = true
        }
        
        
        //addTutorialImage()
        //****
        //checkPanGestureDuringActiveGame() //with map off
        // add a timer if going to use this function
        //***
        
        /*
        if isGameOver && !hasChangedGlobalBackground{
            hasChangedGlobalBackground = true
        }
    */
        
        if hasGameEnded{
            //hasChangedGlobalBackground = false
            self.backToTitleScreen()
            return
        }
        
        if myGameScene.willChangeBackground{ //Level up
            if myGameScene.level > 30 { //"You Beat the Game"
                myGameScene.myMaze = nil
                self.myMaze = nil
                
                self.performSegue(withIdentifier: "CongratulationsScreen", sender: nil)
                return
            }
            updateBackgroundImage(myGameScene.level)
            self.myMaze = myGameScene.myMaze
            
            myGameScene.willChangeBackground = false
        }
        
        
        self.animationUpdate()
        
        
        
        
        
        self.deathEffectUpdate() // if isSlowedDown or not
        self.playerUpdate()
        
        self.updateTutorial() // only for Level 1
        
        self.cameraUpdate(time)
        
        // ******* update background stars to pause during map
        
            if !isShowingMap{
                //emittorNode.position.z = -1
                //particleSystem.speedFactor = 1
            }else{
                //particleSystem.reset()
                //emittorNode.position.z = myCameraNode.position.z + 15
                //particleSystem.speedFactor = 0
            }
        
        
        // ***********************
        
        
    }
    
    func renderer(_ aRenderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ aRenderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
    
    }
    
    func renderer(_ aRenderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
    
    func renderer(_ aRenderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        
        
    }
    //******************************
    //*****************************
    
    
    func addPlayerNode(){
        myPlayerNode = nil
        myPlayerNode = SCNNode()
        
        let player = myPlayerNode
       
        
        player?.geometry = SCNSphere(radius: myPlayer!.radius * 10 / gameFrame.width)
        player?.position = SCNVector3(x: 0, y: 0, z: 0)
        player?.geometry!.firstMaterial!.diffuse.contents = Color.blue
        
        
        myScene.rootNode.addChildNode(player!)
        
        player?.isHidden = true
        
        func addPlayerTailNode()->SCNNode{
            let tail = SCNNode()
            tail.geometry = SCNSphere(radius: myPlayerTail[0].radius * 10 / gameFrame.width)
            
            tail.position = SCNVector3(x: 0, y: 0, z: 0)
            tail.geometry!.firstMaterial!.diffuse.contents = Color.blue
            
            return tail
            
        }
        
        
        if myGameScene.playerLivesMAX > 1{//myGameScene.playerLivesMAX > 1{
            myPlayerTailNodeArray = []
            
            for life in 0...(myGameScene.playerLivesMAX - 2){//(myGameScene.playerLivesMAX - 2){
                
                myPlayerTailNodeArray.append(addPlayerTailNode())
                myPlayerTailNodeArray[life].isHidden = true
                myScene.rootNode.addChildNode(myPlayerTailNodeArray[life])
            }
        }
        
    }
    
    func setupBackground(){
    
        myScene.rootNode.addChildNode(backgroundNode)
        backgroundNode.geometry = SCNSphere(radius: 750)
        backgroundNode.position = SCNVector3(x: 0, y: 0, z: -200)
        
        
        #if os(iOS)
            backgroundNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(M_PI))
            
        #elseif os(OSX)
            backgroundNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: CGFloat(M_PI))
            
        #endif
        
        let myMaterial = imageData[(LEVEL - 1) % imageData.count ]
        backgroundNode.geometry!.firstMaterial!.diffuse.contents = myMaterial
        backgroundNode.geometry!.firstMaterial!.isDoubleSided = true
    }
    
    func updateBackgroundImage(_ level:Int){
        
        let myMaterial = imageData[(level - 1) % 10 ]
        backgroundNode.geometry!.firstMaterial!.diffuse.contents = myMaterial
    }
    
    
    func setupEnvironment(){
        let myTestTrap = SCNNode()
        self.myStageNode = myTestTrap
        myPlayer = nil
        myMaze = nil
        
        //gameScene = nil
        
        //myGameScene = nil
        myGameScene = GameScene(size: CGSize(width: 100, height: 100))
        gameScene = myGameScene
        //gameScene = myGameScene
        self.myMaze = myGameScene.myMaze
        
        
        let materialScene = myGameScene
        
        myTestTrap.geometry = SCNPlane(width: 10, height: 10)
        myTestTrap.position = SCNVector3(x: 0, y: 0, z: 0)
        
            #if os(iOS)
        myTestTrap.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(M_PI))
                
            #elseif os(OSX)
        myTestTrap.rotation = SCNVector4(x: 1, y: 0, z: 0, w: CGFloat(M_PI))
                
            #endif
        myTestTrap.geometry!.firstMaterial!.diffuse.contents = materialScene
        myTestTrap.geometry!.firstMaterial!.isDoubleSided = true   //****** Fix sides
        
        
        myScene.rootNode.addChildNode(myTestTrap)
        
    }
    
    func setupLights(){
        
        myView.autoenablesDefaultLighting = true
        
    }
    
    let cameraStartPosition:SCNVector3 = SCNVector3(x: 0, y: 0, z: 15)// 15 = maxCameraDistance
    
    func setupCamera(){
        // create and add a camera to the scene
        if myCameraNode == nil{
            myCamera = SCNCamera()
            myCamera.xFov = 40
            myCamera.yFov = 40
            myCamera.zFar = 10000//110
            myCameraNode = SCNNode()
            myCameraNode.camera = myCamera
            
            myScene.rootNode.addChildNode(myCameraNode)
        }
        myCameraNode.camera = myCamera
        #if os(iOS)
        myCameraNode.position = SCNVector3(x: 0, y: 0  , z: Float(maxCameraDistance))
        #elseif os(OSX)
        myCameraNode.position = SCNVector3(x: 0, y: 0, z: maxCameraDistance)
        #endif
        
        
    }
    
    func setupHUD(){
        //add Heads Up Display (SpriteKit Overlay) code here!!!
        
        myHudOverlay = HudOverlay(size: self.view.bounds.size)
        
        
        self.myView.overlaySKScene = myHudOverlay
        myHUDView = self.view
        
    }
    
    func setupDebugDisplay(){
        // show statistics such as fps and timing information
        //self.gameView.showsStatistics = true
    }
    
    
    
    fileprivate var sizeEffectSwitch:Bool = false
    fileprivate var sizeEffectSwitchCounter = 0
    
    fileprivate func deathScene(_ deltaTime: CFTimeInterval){
        
        if myGameScene.isPaused{
            return
        }
        
        if self.myGameScene.deathTimer == 0{
            // --- used in GameScene -- 2D
            //self.slowDownSceneTime()
            // --------------------------
            sizeEffectSwitch = true
        }
        
        if self.myGameScene.deathTimer <= 1 || !sizeEffectSwitch{
            
            sizeEffectSwitchCounter += 1
            if sizeEffectSwitch && sizeEffectSwitchCounter >= 3 {
                
                self.myStageNode.scale = SCNVector3(x: 1.01, y: 1.01, z: 1)
                sizeEffectSwitch = !sizeEffectSwitch
                sizeEffectSwitchCounter = 0
            }
            else if !sizeEffectSwitch && sizeEffectSwitchCounter >= 3{
                self.myStageNode.scale = SCNVector3(x: 1, y: 1, z: 1)
                
                sizeEffectSwitch = !sizeEffectSwitch
                sizeEffectSwitchCounter = 0
            }
            
            
        }
        else{
            //break
            
        }
        
    }



}







