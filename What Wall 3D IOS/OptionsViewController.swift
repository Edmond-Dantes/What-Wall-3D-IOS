//
//  OptionsTableViewController.swift
//  What Wall 3D IOS
//
//  Created by Edmond Akpan on 7/5/16.
//  Copyright © 2016 future. All rights reserved.
//

import UIKit
import SceneKit
import GoogleMobileAds


//let myOptions = ["Level Select", "Difficulty", "Custom Walls" ,"Back"]
class OptionsViewController: UIViewController {
    
    var optionsData:[String:AnyObject] = [:]
    
    @IBOutlet weak var optionsPageSCNView: SCNView!
    
    @IBOutlet weak var levelOptionButton: UIButton!
    @IBOutlet weak var difficultyOptionButton: UIButton!
    @IBOutlet weak var livesOptionButton: UIButton!
    @IBOutlet weak var backOptionButton: UIButton!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    weak var myScene:SCNScene!
    
    
    var myLight:SCNNode!
    var myCamera:SCNCamera!
    var myCameraNode:SCNNode!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.preferredStatusBarStyle()
        
        optionsPageSCNView.scene = myScene
        optionsPageSCNView.backgroundColor = UIColor.blackColor()
        
        if !(optionsData["optionsUnlocked"] as! Bool){
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView.rootViewController = self
            bannerView.loadRequest(GADRequest())
            bannerView.hidden = false//true
        }else{
            bannerView.hidden = true
        }
        
    }
    
    //MARK: TextLabel actions
   
    @IBAction func levelChangeAction(sender: AnyObject) {
        
        self.performSegueWithIdentifier("optionDetailsSegue", sender: sender)
        
    }
    
    @IBAction func difficultyChangeAction(sender: AnyObject) {
        self.performSegueWithIdentifier("optionDetailsSegue", sender: sender)
    }
    
    @IBAction func livesChangeAction(sender: AnyObject) {
        self.performSegueWithIdentifier("optionDetailsSegue", sender: sender)
    }
    
    
   
    @IBAction func backButtonAction(sender: AnyObject) {
        
        self.performSegueWithIdentifier("unwindFromOptions", sender: nil)
    }
    
    
    @IBAction func unwindFromOptionDetails(segue: UIStoryboardSegue) {
        
       // bannerView.loadRequest(GADRequest())
        
    }
   
    
    
 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "optionDetailsSegue" {
            
            let optionDetailsVC = segue.destinationViewController as! OptionDetailsViewController
            optionDetailsVC.optionsData = self.optionsData
            
            print(optionDetailsVC.optionsData)
            
            optionDetailsVC.myScene = self.optionsPageSCNView.scene!
            
            if (sender as! UIButton).currentTitle == "DIFFICULTY"{
                optionDetailsVC.maxPickerViewRows = 3
            }else if (sender as! UIButton).currentTitle == "LEVEL"{
                optionDetailsVC.maxPickerViewRows = 30
            }else if (sender as! UIButton).currentTitle == "LIVES"{
                optionDetailsVC.maxPickerViewRows = 9
            }
            
            
            
            
        }else if segue.identifier == "unwindFromOptions"{
            
            let titlePageVC = segue.destinationViewController as! TitlePageViewController
            titlePageVC.optionsData = self.optionsData
            
            self.optionsPageSCNView.scene = nil
        }
        
    }
    
    
    
    func setupLights(){
        
        optionsPageSCNView.autoenablesDefaultLighting = true
        
    }
    
    let cameraStartPosition:SCNVector3 = SCNVector3(x: 0, y: 0, z: 15)// 15 = maxCameraDistance
    
    func setupCamera(){
        // create and add a camera to the scene
        if myCameraNode == nil{
            myCamera = SCNCamera()
            myCamera.xFov = 40
            myCamera.yFov = 40
            myCamera.zFar = 110
            myCameraNode = SCNNode()
            myCameraNode.camera = myCamera
            
            optionsPageSCNView.scene!.rootNode.addChildNode(myCameraNode)
        }
        myCameraNode.camera = myCamera
        #if os(iOS)
            myCameraNode.position = SCNVector3(x: 0, y: 0  , z: 15)//Float(maxCameraDistance))
        #elseif os(OSX)
            myCameraNode.position = SCNVector3(x: 0, y: 0, z: maxCameraDistance)
        #endif
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}