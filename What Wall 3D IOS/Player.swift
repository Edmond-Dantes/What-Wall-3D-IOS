//
//  RolyPauly.swift
//  Roly Moly
//
//  Created by Future on 12/24/14.
//  Copyright (c) 2014 Future. All rights reserved.
//

import SpriteKit


class Player: SKSpriteNode{
    
    fileprivate var rad:CGFloat = 40 * gameFrame.height/1000
    var radius:CGFloat {
        get {
            return self.rad
        }
        set {
            self.rad = newValue
        }
    }
    
    
    var timesTheWeight:CGFloat = 3
    
    var lifeTimer: CFTimeInterval = 0
    
    var isAlive:Bool = true
    
    var isDying:Bool = false
    var justDied:Bool = false
    
    var isStunned:Bool = false
    var hitCount:Int = 0
    var contactStatic:Bool = false
    var contactActive:Bool = false
    
    var deathPosition:CGPoint = CGPoint(x: 0, y: 0)
    var cornerHitPosition:CGPoint? = nil
    
    var deathVelocity:CGVector = CGVector(dx: 0, dy: 0)
    
    let originalPosition = CGPoint(x: gameFrame.width/2, y: gameFrame.height/2)
    
    enum direction{
        case left, right, down, up
        
        
    }
    
    var hitDirection:SmashBlock.blockPosition? = nil
    
    init(){
        let initTexture:SKTexture? = nil
        let initSize = CGSize()
        let initColor = Color.white
        
        super.init(texture: initTexture, color: initColor, size: initSize)
        
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.radius)
        self.position = self.originalPosition
        self.physicsBody?.mass = self.physicsBody!.mass * timesTheWeight
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = 0
        self.physicsBody!.linearDamping = 0
        self.physicsBody!.categoryBitMask = CollisionType.player.rawValue
        self.physicsBody!.collisionBitMask = CollisionType.activeWall.rawValue | CollisionType.staticWall.rawValue
        self.physicsBody!.contactTestBitMask = CollisionType.activeWall.rawValue | CollisionType.staticWall.rawValue
        
        self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.fieldBitMask = CollisionType.player.rawValue
        
    }
    
    init(r:CGFloat){
        let initTexture:SKTexture? = nil
        let initSize = CGSize()
        let initColor = Color.white
        
        super.init(texture: initTexture, color: initColor, size: initSize)
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.radius/2)
        self.radius = self.radius/2
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = 0
        self.physicsBody!.linearDamping = 0
        self.physicsBody!.categoryBitMask = CollisionType.tail.rawValue
        self.physicsBody!.collisionBitMask = 0x0
        self.physicsBody!.contactTestBitMask = 0x0
        
        self.physicsBody!.mass = self.physicsBody!.mass / 85
        
        self.physicsBody!.fieldBitMask = CollisionType.tail.rawValue
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func clone() -> Player{
        let clone = Player()
        clone.physicsBody = nil
        
        
        return clone
    }
    
    func clone(_ r:CGFloat) -> Player{
        let clone = Player(r: r)
        clone.physicsBody = nil
        
        return clone
    }
    
    
    
    
    
    
    
    
}
