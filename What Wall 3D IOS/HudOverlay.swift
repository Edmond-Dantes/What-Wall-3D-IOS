//
//  HudOverlay.swift
//  What Wall 3D MAC
//
//  Created by Edmond on 12/25/15.
//  Copyright (c) 2015 Future. All rights reserved.
//

import Foundation
import SpriteKit
//import Cocoa



var isChoosingDifficulty:Bool = false//true

var isGameOver:Bool = false

class HudOverlay: SKScene {
    
    var restartLabel:SKLabelNode = SKLabelNode()
    var levelNumberLabel:SKLabelNode = SKLabelNode()
    
    var easyLabel:SKLabelNode = SKLabelNode()
    var hardLabel:SKLabelNode = SKLabelNode()
    var ultraHardLabel:SKLabelNode = SKLabelNode()
    
    var gameOverLabel1:SKLabelNode = SKLabelNode()
    var gameOverLabel2:SKLabelNode = SKLabelNode()
    
    
    //var dogdeCountLabel:SKLabelNode = SKLabelNode()
    var level:Int = 1
    var stage:Int = 0
    var hasMoveToView:Bool = true

    override init(size: CGSize) {
        super.init(size: size)//override func didMoveToView(view: SKView) {
        
        self.level = LEVEL
        
        self.levelNumberLabel.fontName = "DINAlternate-Bold"//"Chalkduster"
        self.levelNumberLabel.fontSize = 60//65
        self.levelNumberLabel.position = CGPoint(x: self.frame.width/5, y: self.frame.height/10 )//cornerBlockFrame.height)
        self.levelNumberLabel.fontColor = SKColor.orangeColor()
        self.levelNumberLabel.alpha = 1//0.5
        self.levelNumberLabel.hidden = false //true
        self.levelNumberLabel.text = "LEVEL \(LEVEL)"
        
        //self.restartLabel = myRestartLabel
        self.restartLabel.fontName = "DINAlternate-Bold"//"Chalkduster"
        self.restartLabel.fontSize = 60//65
        self.restartLabel.text = "START";
        self.restartLabel.position = CGPoint(x: 4 * self.frame.width/5, y: self.frame.height/10)
        self.restartLabel.fontColor = SKColor.orangeColor()
        self.restartLabel.hidden = false //true
        
        //add the game over labels
        self.gameOverLabel1.fontName = "DINAlternate-Bold"//"Chalkduster"
        self.gameOverLabel1.fontSize = 100//65
        self.gameOverLabel1.text = "GAME";
        self.gameOverLabel1.position = CGPoint(x: self.frame.width/2, y: 6 * self.frame.height/12)
        self.gameOverLabel1.fontColor = SKColor.purpleColor()
        self.gameOverLabel1.hidden = false //true
        
        self.gameOverLabel2.fontName = "DINAlternate-Bold"//"Chalkduster"
        self.gameOverLabel2.fontSize = 100//65
        self.gameOverLabel2.text = "OVER";
        self.gameOverLabel2.position = CGPoint(x: self.frame.width/2, y: 4 * self.frame.height/12)
        self.gameOverLabel2.fontColor = SKColor.purpleColor()
        self.gameOverLabel2.hidden = false //true
        
        self.gameOverLabel1.removeFromParent()
        self.gameOverLabel2.removeFromParent()
        //self.addChild(self.gameOverLabel1)
        //self.addChild(self.gameOverLabel2)
        
        #if os(iOS)
            
            
            self.easyLabel.fontName = "DINAlternate-Bold"//"Chalkduster"
            self.easyLabel.fontSize = 100//65
            self.easyLabel.position = CGPoint(x: self.frame.width/2, y: 7 * self.frame.height/12 )
            self.easyLabel.fontColor = SKColor.whiteColor()
            self.easyLabel.alpha = 1//0.5
            self.easyLabel.hidden = false //true
            self.easyLabel.text = "EASY"
            
            self.hardLabel.fontName = "DINAlternate-Bold"//"Chalkduster"
            self.hardLabel.fontSize = 100//65
            self.hardLabel.text = "HARD";
            self.hardLabel.position = CGPoint(x: self.frame.width/2, y: 5 * self.frame.height/12)
            self.hardLabel.fontColor = SKColor.blueColor()
            self.hardLabel.hidden = false //true
            
            self.ultraHardLabel.fontName = "DINAlternate-Bold"//"Chalkduster"
            self.ultraHardLabel.fontSize = 100//65
            self.ultraHardLabel.text = "WTF";
            self.ultraHardLabel.position = CGPoint(x: self.frame.width/2, y: 3 * self.frame.height/12)
            self.ultraHardLabel.fontColor = SKColor.redColor()
            self.ultraHardLabel.hidden = false //true
            
            //************************
            // moved difficulty choices to the options screen
            /*
            self.easyLabel.removeFromParent()
            self.hardLabel.removeFromParent()
            self.ultraHardLabel.removeFromParent()
            self.addChild(self.easyLabel)
            self.addChild(self.hardLabel)
            self.addChild(self.ultraHardLabel)
            */
            //************************
            
            
            
            self.levelNumberLabel.position = CGPoint(x: self.frame.width/2, y: 7 * self.frame.height/60 )
            self.restartLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/30)
            
            /*
            // add a tap gesture recognizer to the HUD for difficulty settings
            let hudTapGesture = UITapGestureRecognizer(target: self, action: #selector(HudOverlay.handleTap(_:)))
            self.view!.addGestureRecognizer(hudTapGesture)
            */
            
            #endif
    
        
        
        self.levelNumberLabel.removeFromParent()
        self.restartLabel.removeFromParent()
        self.addChild(self.levelNumberLabel)
        self.addChild(self.restartLabel)
        
        
        
        //self.resignFirstResponder()
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func setDifficulty(setting:difficultySetting){ //(setting:CGFloat){
        if setting == .easy{
            gameDifficultySetting = .easy
            SPEED_PERCENTAGE = EASY_SETTING
            CONSTANT_WALLSPEED = 1000 * SPEED_PERCENTAGE
            gameScene.isEdgeHitDeathOn = false
            
        }else if setting == .hard{
            gameDifficultySetting = .hard
            SPEED_PERCENTAGE = HARD_SETTING
            CONSTANT_WALLSPEED = 1000 * SPEED_PERCENTAGE
            gameScene.isEdgeHitDeathOn = false
            
        }else if setting == .ultraHard{  //same as hard with edgeHitDeathOn = true
            gameDifficultySetting = .ultraHard
            SPEED_PERCENTAGE = ULTRA_HARD_SETTING
            CONSTANT_WALLSPEED = 1000 * SPEED_PERCENTAGE
            gameScene.isEdgeHitDeathOn = true
        }
    }
    
    #if os(iOS)
    
    func handleTap(p: CGPoint) {
        if isGameOver{
            return
        }
        
        if !isChoosingDifficulty{
            return
        }
        print("HUD handle Tap")
        
        //let myView = myHUDView// as! SKView
         
         // check what nodes are tapped
        //let p = gestureRecognize.locationInView(myView)
        
        if easyLabel.containsPoint(p){
            print("changed to EASY")
            
            setDifficulty(.easy)
            self.easyLabel.removeFromParent()
            self.hardLabel.removeFromParent()
            self.ultraHardLabel.removeFromParent()
            isChoosingDifficulty = false
            
            
            
            
        }else if hardLabel.containsPoint(p){
            print("changed to HARD")
            
            setDifficulty(.hard)
            self.easyLabel.removeFromParent()
            self.hardLabel.removeFromParent()
            self.ultraHardLabel.removeFromParent()
            isChoosingDifficulty = false
            
            
        }else if ultraHardLabel.containsPoint(p){
            print("changed to ULTRA_HARD")
            
            setDifficulty(.ultraHard)
            self.easyLabel.removeFromParent()
            self.hardLabel.removeFromParent()
            self.ultraHardLabel.removeFromParent()
            isChoosingDifficulty = false
            
            
        }
        
        
        
        
    }
    
    
    #elseif os(OSX)
    
    override func mouseUp(theEvent: NSEvent) {
        super.mouseUp(theEvent)
//        self.view!.nextResponder!.mouseUp(theEvent)
        
    }
    
    override func mouseDown(theEvent: NSEvent) {
        Swift.print("mouseDown - HudOverlay")
        super.mouseDown(theEvent)
        //Swift.print("\(self.nextResponder)")
        
        
    }

    
    
    override func keyDown(theEvent: NSEvent) {
        //gameScene.keyDown(theEvent)
        Swift.print("KeyDown - HudOverlay")
        super.keyDown(theEvent)
    }
    
    override func keyUp(theEvent: NSEvent) {
        //gameScene.keyUp(theEvent)
        super.keyUp(theEvent)
    }
    #endif
    
    override func update(currentTime: NSTimeInterval) {
        if isGameOver{
            
            if gameOverLabel1.parent == nil{
                self.addChild(self.gameOverLabel1)
                self.addChild(self.gameOverLabel2)
            }
            return
        }else{
            if gameOverLabel1.parent != nil{
                self.gameOverLabel1.removeFromParent()
                self.gameOverLabel2.removeFromParent()
            }
        }
        
        
       /* if hasMoveToView{
            self.didMoveToView(self.view!)
            hasMoveToView = false
        }
        */
        
        self.levelNumberLabel.text = myLevelNumberLabel.text
        
        self.restartLabel.text = myRestartLabel.text
 
    }
    
    override func didEvaluateActions() {
    
    }
    
    override func didSimulatePhysics() {
        
    }
    
    override func didApplyConstraints() {
        
    }
    
    override func didFinishUpdate() {
        
    }
    
    
    

}