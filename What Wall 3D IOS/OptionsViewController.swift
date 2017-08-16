//
//  OptionsTableViewController.swift
//  What Wall 3D IOS
//
//  Created by Edmond Akpan on 7/5/16.
//  Copyright © 2016 future. All rights reserved.
//

import UIKit
import SceneKit
//import GoogleMobileAds


//let myOptions = ["Level Select", "Difficulty", "Custom Walls" ,"Back"]
class OptionsViewController: UIViewController {
    
    var optionsData:[String:AnyObject] = [:]
    
    @IBOutlet weak var optionsPageSCNView: SCNView!
    
    @IBOutlet weak var levelOptionButton: UIButton!
    @IBOutlet weak var difficultyOptionButton: UIButton!
    @IBOutlet weak var livesOptionButton: UIButton!
    @IBOutlet weak var backOptionButton: UIButton!
    
    //@IBOutlet weak var bannerView: GADBannerView!
    
    weak var myScene:SCNScene!
    
    
    var myLight:SCNNode!
    var myCamera:SCNCamera!
    var myCameraNode:SCNNode!
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.preferredStatusBarStyle()
        
        optionsPageSCNView.scene = myScene
        optionsPageSCNView.backgroundColor = UIColor.black
        /*
        if !(optionsData["optionsUnlocked"] as! Bool){
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.isHidden = false//true
        }else{
            bannerView.isHidden = true
        }*/
        
    }
    
    func loadPropertyList(_ plistName:String, propertyListData:AnyObject){
        
        //let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let bundleID = "com.aggressiveTurtle.What-Wall-3D-IOS"
        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, .userDomainMask, true)[0]
        let customDirectory = (applicationSupportDirectory as NSString).appendingPathComponent("\(bundleID)/")
        let plistPath:String? = (customDirectory as NSString).appendingPathComponent("\(plistName).plist")
        
        (propertyListData as! NSDictionary).write(toFile: plistPath!, atomically: true)
        
    }
    
    //MARK: TextLabel actions
   
    @IBAction func levelChangeAction(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "optionDetailsSegue", sender: sender)
        
    }
    
    @IBAction func difficultyChangeAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "optionDetailsSegue", sender: sender)
    }
    
    @IBAction func livesChangeAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "optionDetailsSegue", sender: sender)
    }
    
    
   
    @IBAction func backButtonAction(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "unwindFromOptions", sender: nil)
    }
    
    
    @IBAction func unwindFromOptionDetails(_ segue: UIStoryboardSegue) {
        
       // bannerView.loadRequest(GADRequest())
        
        loadPropertyList("Options", propertyListData: self.optionsData as AnyObject)
        
    }
   
    
    
 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "optionDetailsSegue" {
            
            let optionDetailsVC = segue.destination as! OptionDetailsViewController
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
            
            let titlePageVC = segue.destination as! TitlePageViewController
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
