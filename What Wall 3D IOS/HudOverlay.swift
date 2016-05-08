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



var isChoosingDifficulty:Bool = true

class HudOverlay: SKScene {
    
    var restartLabel:SKLabelNode = SKLabelNode()
    var levelNumberLabel:SKLabelNode = SKLabelNode()
    
    var easyLabel:SKLabelNode = SKLabelNode()
    var hardLabel:SKLabelNode = SKLabelNode()
    
    
    //var dogdeCountLabel:SKLabelNode = SKLabelNode()
    var level:Int = 1
    var stage:Int = 0
    var hasMoveToView:Bool = true

    override init(size: CGSize) {
        super.init(size: size)//override func didMoveToView(view: SKView) {
        
        self.level = LEVEL
        //self.stage = STAGE
        
        
        
        //self.levelNumberLabel = myLevelNumberLabel
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
        self.restartLabel.text = "RESTART";
        self.restartLabel.position = CGPoint(x: 4 * self.frame.width/5, y: self.frame.height/10)
        self.restartLabel.fontColor = SKColor.orangeColor()
        self.restartLabel.hidden = false //true
        
        #if os(iOS)
            
            
            self.easyLabel.fontName = "DINAlternate-Bold"//"Chalkduster"
            self.easyLabel.fontSize = 100//65
            self.easyLabel.position = CGPoint(x: self.frame.width/2, y: 2 * self.frame.height/4 )//cornerBlockFrame.height)
            self.easyLabel.fontColor = SKColor.redColor()
            self.easyLabel.alpha = 1//0.5
            self.easyLabel.hidden = false //true
            self.easyLabel.text = "EASY"
            
            //self.restartLabel = myRestartLabel
            self.hardLabel.fontName = "DINAlternate-Bold"//"Chalkduster"
            self.hardLabel.fontSize = 100//65
            self.hardLabel.text = "HARD";
            self.hardLabel.position = CGPoint(x: self.frame.width/2, y: self.frame.height/4)
            self.hardLabel.fontColor = SKColor.redColor()
            self.hardLabel.hidden = false //true
            
            self.easyLabel.removeFromParent()
            self.hardLabel.removeFromParent()
            self.addChild(self.easyLabel)
            self.addChild(self.hardLabel)
            
            
            
            
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

    
    func setDifficulty(setting:CGFloat){
        if setting == EASY_SETTING{
            SPEED_PERCENTAGE = EASY_SETTING
            CONSTANT_WALLSPEED = 1000 * SPEED_PERCENTAGE
        }else if setting == HARD_SETTING{
            SPEED_PERCENTAGE = HARD_SETTING
            CONSTANT_WALLSPEED = 1000 * SPEED_PERCENTAGE
        }
    }
    
    #if os(iOS)
    
    func handleTap(p: CGPoint) {
        if !isChoosingDifficulty{
            return
        }
        print("HUD handle Tap")
        
        //let myView = myHUDView// as! SKView
         
         // check what nodes are tapped
        //let p = gestureRecognize.locationInView(myView)
        
        if easyLabel.containsPoint(p){
            print("changed to EASY")
            
            setDifficulty(EASY_SETTING)
            self.easyLabel.removeFromParent()
            self.hardLabel.removeFromParent()
            isChoosingDifficulty = false
            
            
            
            
        }else if hardLabel.containsPoint(p){
            print("changed to HARD")
            
            setDifficulty(HARD_SETTING)
            self.easyLabel.removeFromParent()
            self.hardLabel.removeFromParent()
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
        
        
       /* if hasMoveToView{
            self.didMoveToView(self.view!)
            hasMoveToView = false
        }
        */
        
        self.levelNumberLabel.text = myLevelNumberLabel.text
        //self.levelNumberLabel.hidden = myLevelNumberLabel.hidden
        //self.levelNumberLabel.alpha = myLevelNumberLabel.alpha
        
        self.restartLabel.text = myRestartLabel.text
        //self.restartLabel.hidden = myRestartLabel.hidden
        //self.restartLabel.alpha = myRestartLabel.alpha
 
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