//
//  GameView.swift
//  What Wall 3D MAC repository
//
//  Created by Edmond on 1/5/16.
//  Copyright (c) 2016 Future. All rights reserved.
//

import SceneKit

class GameView: SCNView {
    
    #if os(iOS)
    
    weak var controller:GameViewController!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if controller.isShowingMap{
            
            
            controller.panVelocity.y = 0
            controller.panVelocity.x = 0
        }
    }
    
    
    
    #elseif os(OSX)
    
    override func mouseUp(theEvent: NSEvent) {
//        self.nextResponder = nil
        super.mouseUp(theEvent)
//        self.nextResponder!.mouseUp(theEvent)
        
    }
   
    override func mouseDown(theEvent: NSEvent) {
        Swift.print("mouseDown - GameView")
//        self.nextResponder = nil
        super.mouseDown(theEvent)
//        self.nextResponder!.mouseDown(theEvent)
        
    }

    override func keyDown(theEvent: NSEvent) {
        //super.keyDown(theEvent)
        Swift.print("KeyDown - GameViewController")
        self.nextResponder!.keyDown(theEvent)
        //gameScene.keyDown(theEvent)
    }
    
    override func keyUp(theEvent: NSEvent) {
        //super.keyUp(theEvent)
        self.nextResponder!.keyUp(theEvent)
        //gameScene.keyUp(theEvent)
    }

    #endif
}
