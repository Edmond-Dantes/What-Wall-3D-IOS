//
//  OsColor.swift
//  Roly Moly
//
//  Created by Future on 2/2/15.
//  Copyright (c) 2015 Future. All rights reserved.
//

import Foundation



    #if os(iOS)
import UIKit
class Color: UIColor {
    
        var colorArray:[UIColor]{
        
        get{
        return [.blueColor(),
        .brownColor(),
        .cyanColor(),
        .greenColor(),
        .magentaColor(),
        .orangeColor(),
        .purpleColor(),
        .redColor(),
        .whiteColor(),
        .yellowColor()]
        }
        }
    
    override init(){
        super.init()
    }

    required convenience init(colorLiteralRed red: Float, green: Float, blue: Float, alpha: Float) {
        fatalError("init(colorLiteralRed:green:blue:alpha:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//        class func nextColor(index:Int){
        
//        return self.colorArray[index]
        
        
//        }
        
}
    #elseif os(OSX)

import Cocoa
        
class Color: NSColor {
    
    class var colorArray:[NSColor] {
        
        get{
            return [NSColor.blueColor(), NSColor.brownColor(), NSColor.cyanColor(), NSColor.greenColor(), NSColor.magentaColor(), NSColor.orangeColor(), NSColor.purpleColor(), NSColor.redColor(), NSColor.whiteColor(), NSColor.yellowColor()]
        }
    }
    
    override init(){
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init!(pasteboardPropertyList propertyList: AnyObject, ofType type: String) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }
    
   /* class func nextColor(index:Int){
        
        let tempArray = colorArray[]
        
        return tempArray[index]
        
    }*/
}
    #endif
    
    
    
    
    
