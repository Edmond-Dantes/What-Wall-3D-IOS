//
//  MazeScene.swift
//  Roly Moly
//
//  Created by Future on 1/19/15.
//  Copyright (c) 2015 Future. All rights reserved.
//

import Foundation
import SpriteKit



var mymyMaze:Maze? = nil


class MazeScene: SKScene, SKPhysicsContactDelegate {
    
    
    var allLevelMazes = [Maze]()
    
    var level:Int = 1
    var stage:Int = 0
    
    var isStageBlinking: Bool = false
    var isViewingMap: Bool = false
    var isChangingScene: Bool = false
    
    let levelNumberView = SKLabelNode(fontNamed: "Chalkduster")
    
    override func didMoveToView(view: SKView) {
        
        
        
        isStageBlinking = false
        
        
        
        isViewingMap = true
        self.runAction(SKAction.waitForDuration(1)){
            
            self.isViewingMap = false
        }
        
        
        self.stage = STAGE
        if mymyMaze == nil{
        mymyMaze = Maze(level: CGFloat(level))

        }else{
            if self.level != LEVEL{
                self.level = LEVEL
                
                mymyMaze = Maze(level: CGFloat(level))
                
                levelNumberView.removeFromParent()
                
            }
        }

        levelNumberView.fontSize = 20//65
        levelNumberView.text = "LEVEL \(self.level)";
        
        levelNumberView.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - cornerBlockFrame.height)
        levelNumberView.fontColor = SKColor.whiteColor()
        levelNumberView.alpha = 0.5
        
        levelNumberView.hidden = false
        levelNumberView.name = "world"
        levelNumberView.zPosition = -100
        
        
        
        
                
        
    }
    
    
    
    
    //------------------------------------------
    //--------------UPDATES--------------------
    //------------------------------------------
    
    #if os(iOS)
    
    #elseif os(OSX)
    override func keyDown(theEvent: NSEvent) {
        
        let key = theEvent.keyCode
    
            
            switch key{
            case 126://up
    
                print("\(key) up")
                if !isViewingMap{
                     //*************************
                    let currentStage = myMaze?.escapePath[self.stage * 2]
                    if isStageBlinking{
                        
                        self.removeAllActions()
                    }
                    
                    isChangingScene = true
                }
            case 124://right
                controller.joyStickDirection = .right
                print("\(key) right")
            case 125://down
                controller.joyStickDirection = .down
                print("\(key) down")
            case 123://left
                controller.joyStickDirection = .left
                print("\(key) left")
            default:
                break
            }
    
        
    
        
        
        
        
    }
    
    override func keyUp(theEvent: NSEvent) {
        let key = theEvent.keyCode
   
    }
    

    #endif
    
    
    override func update(currentTime: NSTimeInterval) {

        
    }
    
    override func didEvaluateActions() {
        
        
        
    }
    
    override func didSimulatePhysics() {
        
    }
    
    override func didApplyConstraints() {
        
    }
    
    override func didFinishUpdate() {
        if isChangingScene{
            
            isStageBlinking = false
            isChangingScene = false
            
            
        }
    }
    
}