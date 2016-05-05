import Foundation
import SceneKit
import QuartzCore

class MazeCell:SCNNode{
    
    
    enum wallLocations{
        case up, down, left, right
    }
    enum type{
        case square, border
    }
    var cellType:type
    
    
    var walls:[wallLocations:Bool] = [ .up: false, .down: false, .left: false, .right: false ]
    
    var gridPoint:Int
    var visited:Bool = false
    var alpha:CGFloat{
        get{
            return self.alpha
        }
        set{
            self.geometry?.firstMaterial?.transparency = newValue
        }
    }
    #if os(iOS)
    var color:UIColor{
        get{
            return self.color
        }
        set{
            self.geometry?.firstMaterial?.diffuse.contents = newValue
        }
    }
    #elseif os(OSX)
    var color:NSColor{
        get{
            return self.color
        }
        set{
            self.geometry?.firstMaterial?.diffuse.contents = newValue
        }
    }
    #endif
    
    
    init(gridPoint:Int, size: CGSize){
        
        self.gridPoint = gridPoint
        self.cellType = .square
        super.init()
        
        #if os(iOS)
        let w:Float = Float(M_PI / 2)
        #elseif os(OSX)
        let w:CGFloat = CGFloat(M_PI / 2)
        #endif
        self.geometry = SCNPlane(width: size.width, height: size.height)
        self.position = SCNVector3(x: 0, y: 0, z: 0)
        self.rotation = SCNVector4(x: 0, y: 0, z: 0, w: w )
        
        //self.geometry?.firstMaterial = SCNMaterial()
        self.geometry?.firstMaterial?.doubleSided = true
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}