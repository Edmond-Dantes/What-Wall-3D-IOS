//
//  RootViewController.swift
//  What Wall 3D IOS
//
//  Created by Edmond Akpan on 8/12/16.
//  Copyright © 2016 future. All rights reserved.
//

import UIKit
import SceneKit

//var gameScene:GameScene!

class RootViewController: UIViewController {

    var optionsData:[String:AnyObject] = [:]
    var emittorNode:SCNNode!
    var particleSystem:SCNParticleSystem!
    
    var goingToTitle:Bool = true
    
    //@IBOutlet weak var pressMe: UIButton!
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        print("shouldPerformSegueWithIdentifier called")
        return true//false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if goingToTitle{
            performSegueWithIdentifier("showTitle", sender: nil)
            goingToTitle = false
        }else{ //going to the game
            goingToTitle = true
            performSegueWithIdentifier("showGame", sender: nil)
        }
    }
    
    /*
    @IBAction func pressMeAction(sender: AnyObject) {
        performSegueWithIdentifier("showTitle", sender: nil)
    }
    
    */
    
    func loadPropertyList(plistName:String, propertyListData:AnyObject){
        
        //let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let bundleID = "com.aggressiveTurtle.What-Wall-3D-IOS"
        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, .UserDomainMask, true)[0]
        let customDirectory = (applicationSupportDirectory as NSString).stringByAppendingPathComponent("\(bundleID)/")
        let plistPath:String? = (customDirectory as NSString).stringByAppendingPathComponent("\(plistName).plist")
        
        (propertyListData as! NSDictionary).writeToFile(plistPath!, atomically: true)
        
    }
    
    @IBAction func unwindFromGameBeaten(segue: UIStoryboardSegue){
        loadPropertyList("Options", propertyListData: self.optionsData)
    }
    
    @IBAction func unwindFromTitleToGame(segue: UIStoryboardSegue){
        //performSegueWithIdentifier("showGame", sender: nil)
    }
    
    @IBAction func unwindFromGameToTitle(segue: UIStoryboardSegue){
        //performSegueWithIdentifier("showTitle", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //add segue related information
        if segue.identifier! == "showTitle"{
            
            //print("Show Title")
            //let titleVC = segue.destinationViewController as! TitlePageViewController
            //titleVC.optionsData = self.optionsData
            
            //titleVC.loadPropertyList("Options", propertyListData: self.optionsData)
            
        }else if segue.identifier! == "showGame" {
            
            let gameVC = segue.destinationViewController as! GameViewController
            gameVC.optionsData = self.optionsData
            //gameVC.imageData = self.imageData
            
            gameVC.emittorNode = self.emittorNode
            gameVC.particleSystem = self.particleSystem
            
            //self.backgroundNode.geometry!.firstMaterial!.diffuse.contents = nil
            //self.backgroundNode.geometry!.firstMaterial!.diffuse.contents = UIColor.blackColor()
            
            self.emittorNode.removeFromParentNode()
            //gameVC.myScene.rootNode.addChildNode(gameVC.emittorNode)
        }
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    

}
