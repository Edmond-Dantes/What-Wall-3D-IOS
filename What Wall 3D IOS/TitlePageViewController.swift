//
//  TitlePageViewController.swift
//  What Wall 3D IOS
//
//  Created by Edmond Akpan on 7/4/16.
//  Copyright © 2016 future. All rights reserved.
//

import UIKit
import SceneKit
import GoogleMobileAds

//var globalBackgroundNode:SCNNode!

var imageData:[UIImage]!

class TitlePageViewController: UIViewController {
    
    var optionsData:[String:AnyObject] = [:]
    //var imageData:[UIImage] = []
    var imageDataStrings:[String] = []
    
    let backgroundNode = SCNNode()

    @IBOutlet weak var titlePageSCNView: SCNView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    var myLight:SCNNode!
    var myCamera:SCNCamera!
    var myCameraNode:SCNNode!
    
    let emittorNode = SCNNode()
    let particleSystem = SCNParticleSystem(named: "MyParticleSystem2.scnp", inDirectory: nil)

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        print("shouldPerformSegueWithIdentifier called")
        return true//false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    func updateBackgroundImage(){
        
        //let myMaterial = imageData[0]//UIImage(named: "NASA images/\(imageData[0]).jpg")!
        
        backgroundNode.geometry!.firstMaterial!.diffuse.contents = nil
        backgroundNode.geometry!.firstMaterial!.diffuse.contents = imageData[0]//myMaterial
        
        //imageData.shuffle()
    }
    
    func setupBackgroundImage(scene:SCNScene?){
        let myScene = scene
        
        //globalBackgroundNode = backgroundNode
        
        let myMaterial = imageData[0]
        
        backgroundNode.geometry = SCNSphere(radius: 750)
        backgroundNode.position = SCNVector3(x: 0, y: 0, z: -200)
        //backgroundNode.geometry = SCNPlane(width: 100, height: 100)
        //backgroundNode.position = SCNVector3(x: 0, y: 0, z: -30)
        
        #if os(iOS)
            backgroundNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(M_PI))
            
        #elseif os(OSX)
            backgroundNode.rotation = SCNVector4(x: 1, y: 0, z: 0, w: CGFloat(M_PI))
            
        #endif
        backgroundNode.geometry!.firstMaterial!.diffuse.contents = myMaterial
        backgroundNode.geometry!.firstMaterial!.doubleSided = true   //****** Fix sides
        
        
        myScene!.rootNode.addChildNode(backgroundNode)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("TITLE PAGE VIEW CONTROLLER")
        
        
        optionsData = readPropertyList("Options") as! [String:AnyObject]
        imageDataStrings = readPropertyList("NASAImages")! as! [String]
        
        imageData = []
        for image in imageDataStrings{
            imageData.append(UIImage(named: "NASA images/\(image).jpg")!)
        }
        
        imageData.shuffle()
        
        let myScene = SCNScene()
        titlePageSCNView.scene = myScene//SCNScene()
        titlePageSCNView.backgroundColor = UIColor.blackColor()
        titlePageSCNView.scene!.rootNode.addChildNode(emittorNode)
        emittorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        emittorNode.addParticleSystem(particleSystem!)
        //emittorNode.removeParticleSystem(particleSystem!)
        
        self.setupLights()
        self.setupCamera()
        
        setupBackgroundImage(titlePageSCNView.scene)
        
        //imageData.shuffle()
        
        if !(optionsData["optionsUnlocked"] as! Bool){
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView.rootViewController = self
            bannerView.loadRequest(GADRequest())
            bannerView.hidden = false//true
        }else{
            bannerView.hidden = true
        }
        
    }
    
    
    func readPropertyList(plistName:String)->AnyObject?{//[String:AnyObject]{
        
        var data:AnyObject?
        
        //Bundle path
        let plistSourcePath:String? = NSBundle.mainBundle().pathForResource(plistName, ofType: "plist")!
        
        //Document Directory Path
        let fileManager = NSFileManager.defaultManager()
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let plistDestinationPath:String? = (documentDirectory as NSString).stringByAppendingPathComponent("\(plistName).plist")
        

        if plistName == "Options"{
            var plistData:[String:AnyObject] = [:]
            
            if !fileManager.fileExistsAtPath(plistDestinationPath!){
                plistData = NSDictionary(contentsOfFile: plistSourcePath!) as! [String : AnyObject]
                
                do{
                    try fileManager.copyItemAtPath(plistSourcePath!, toPath: documentDirectory)
                }catch{
                    print("error copying options plist from bundle to directory: \(error)")
                }
                
                
            }else{
                plistData = NSDictionary(contentsOfFile: plistDestinationPath!) as! [String : AnyObject]
                
            }
            data = plistData //as [String:AnyObject]
            return plistData
            
        }else if plistName == "NASAImages"{
            var plistData:[String] = []
            
            plistData = NSArray(contentsOfFile: plistSourcePath!) as! [String]
              
            data = plistData //as [String]
            return plistData
        }
        
        return data
    }
    
    func loadPropertyList(plistName:String, propertyListData:AnyObject){
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let plistPath:String? = (documentDirectory as NSString).stringByAppendingPathComponent("\(plistName).plist")  //("OptionsSettings.plist")
        
        (propertyListData as! NSDictionary).writeToFile(plistPath!, atomically: true)
        
    }
    
 
    
    @IBAction func startGameAction(sender: AnyObject) {
        //globalBackgroundNode.geometry!.firstMaterial!.diffuse.contents = nil
        //globalBackgroundNode.geometry!.firstMaterial!.diffuse.contents = UIColor.blackColor()
        
        returnedFromGame = true
        
        //backgroundNode.geometry!.firstMaterial!.diffuse.contents = nil
        //backgroundNode.geometry!.firstMaterial!.diffuse.contents = UIColor.blackColor()
        
        self.performSegueWithIdentifier("startGameSegue", sender: nil)
    }
    
    
    @IBAction func optionsAction(sender: AnyObject) {
        
        
        if optionsData["optionsUnlocked"] as! Bool {
            self.performSegueWithIdentifier("optionsSegue", sender: nil)
        }else{
            
            //add logic for in-app purchases
            
            
            
            
        }
    }
    
    @IBAction func testCongratsAction(sender: AnyObject) {
        self.performSegueWithIdentifier("test", sender: nil)
        
        
    }
    
    
    var returnedFromGame:Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("********************View Appeared********************")
        
        if returnedFromGame{
            //updateBackgroundImage()
            returnedFromGame = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier! == "startGameSegue" {
            
            let rootVC = segue.destinationViewController as! RootViewController
            rootVC.optionsData = self.optionsData
            //gameVC.imageData = self.imageData
            
            rootVC.emittorNode = self.emittorNode
            rootVC.particleSystem = self.particleSystem!
            
            //self.backgroundNode.geometry!.firstMaterial!.diffuse.contents = nil
            //self.backgroundNode.geometry!.firstMaterial!.diffuse.contents = UIColor.blackColor()
            
            self.emittorNode.removeFromParentNode()
            //gameVC.myScene.rootNode.addChildNode(gameVC.emittorNode)
 
        }else if segue.identifier == "optionsSegue" {
            
            let optionsVC = segue.destinationViewController as! OptionsViewController
            optionsVC.optionsData = self.optionsData
            print(optionsVC.optionsData)
            optionsVC.myScene = self.titlePageSCNView.scene!
            
            //emittorNode.removeParticleSystem(particleSystem!)
            
        }else if segue.identifier == "test" {
            
            let testVC = segue.destinationViewController as! CongratulationsViewController
            testVC.optionsData = self.optionsData
            print(testVC.optionsData)
            
            
            //emittorNode.removeParticleSystem(particleSystem!)
            
        }
        
        
        
    }
    
    @IBAction func unwindFromOptions(segue: UIStoryboardSegue){
    
        loadPropertyList("Options", propertyListData: optionsData)
    
    }
    
    //@IBAction func unwindFromGame(segue: UIStoryboardSegue){
        
    //}
    
    func setupLights(){
        
        titlePageSCNView.autoenablesDefaultLighting = true
        
    }
    
    let cameraStartPosition:SCNVector3 = SCNVector3(x: 0, y: 0, z: 15)// 15 = maxCameraDistance
    
    func setupCamera(){
        // create and add a camera to the scene
        if myCameraNode == nil{
            myCamera = SCNCamera()
            myCamera.xFov = 40
            myCamera.yFov = 40
            myCamera.zFar = 10000 //110
            myCameraNode = SCNNode()
            myCameraNode.camera = myCamera
            
            titlePageSCNView.scene!.rootNode.addChildNode(myCameraNode)
        }
        myCameraNode.camera = myCamera
        #if os(iOS)
            myCameraNode.position = SCNVector3(x: 0, y: 0, z: 15)//Float(maxCameraDistance))
        #elseif os(OSX)
            myCameraNode.position = SCNVector3(x: 0, y: 0, z: maxCameraDistance)
        #endif
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
