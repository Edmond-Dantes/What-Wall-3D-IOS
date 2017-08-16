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
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("shouldPerformSegueWithIdentifier called")
        return true//false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if goingToTitle{
            performSegue(withIdentifier: "showTitle", sender: nil)
            goingToTitle = false
        }else{ //going to the game
            goingToTitle = true
            performSegue(withIdentifier: "showGame", sender: nil)
        }
    }
    
    /*
    @IBAction func pressMeAction(sender: AnyObject) {
        performSegueWithIdentifier("showTitle", sender: nil)
    }
    
    */
    
    func loadPropertyList(_ plistName:String, propertyListData:AnyObject){
        
        //let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let bundleID = "com.aggressiveTurtle.What-Wall-3D-IOS"
        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, .userDomainMask, true)[0]
        let customDirectory = (applicationSupportDirectory as NSString).appendingPathComponent("\(bundleID)/")
        let plistPath:String? = (customDirectory as NSString).appendingPathComponent("\(plistName).plist")
        
        (propertyListData as! NSDictionary).write(toFile: plistPath!, atomically: true)
        
    }
    
    @IBAction func unwindFromGameBeaten(_ segue: UIStoryboardSegue){
        loadPropertyList("Options", propertyListData: self.optionsData as AnyObject)
    }
    
    @IBAction func unwindFromTitleToGame(_ segue: UIStoryboardSegue){
        //performSegueWithIdentifier("showGame", sender: nil)
    }
    
    @IBAction func unwindFromGameToTitle(_ segue: UIStoryboardSegue){
        //performSegueWithIdentifier("showTitle", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //add segue related information
        if segue.identifier! == "showTitle"{
            
            //print("Show Title")
            //let titleVC = segue.destinationViewController as! TitlePageViewController
            //titleVC.optionsData = self.optionsData
            
            //titleVC.loadPropertyList("Options", propertyListData: self.optionsData)
            
        }else if segue.identifier! == "showGame" {
            
            let gameVC = segue.destination as! GameViewController
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
