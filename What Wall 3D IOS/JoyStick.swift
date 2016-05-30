//
//  JoyStick.swift
//  Roly Moly
//
//  Created by Future on 1/29/15.
//  Copyright (c) 2015 Future. All rights reserved.
//

import Foundation
import SpriteKit




class JoyStick{
    
    var isChangedDirection: Bool = false
    
    enum direction{
        case left, upLeft, up, upRight, right, downRight, down, downLeft, neutral
    }
    
    var joyStickDirection:direction = .neutral
    
    func controllDirections() -> CGVector{
        var dx = 0
        var dy = 0
        switch joyStickDirection{
        
        case .neutral:
            dx = 0
            dy = 0
        case .right:
            dx = 1
            dy = 0
            
        case .left:
            dx = -1
            dy = 0
            
        case .up:
            dx = 0
            dy = 1
        case .down:
            dx = 0
            dy = -1
        default:
        dx = 0
        dy = 0
        
        }
        
        return CGVector(dx: dx, dy: dy)
    }
    
    
    
    
    
    
    
}



