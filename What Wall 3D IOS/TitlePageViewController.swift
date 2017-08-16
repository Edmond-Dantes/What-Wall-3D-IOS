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

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        print("shouldPerformSegueWithIdentifier called")
        return true//false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    func updateBackgroundImage(){
        
        //let myMaterial = imageData[0]//UIImage(named: "NASA images/\(imageData[0]).jpg")!
        
        backgroundNode.geometry!.firstMaterial!.diffuse.contents = nil
        backgroundNode.geometry!.firstMaterial!.diffuse.contents = imageData[0]//myMaterial
        
        //imageData.shuffle()
    }
    
    func setupBackgroundImage(_ scene:SCNScene?){
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
        backgroundNode.geometry!.firstMaterial!.isDoubleSided = true   //****** Fix sides
        
        
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
        titlePageSCNView.backgroundColor = UIColor.black
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
            bannerView.load(GADRequest())
            bannerView.isHidden = false//true
        }else{
            bannerView.isHidden = true
        }
        
    }
    
    
    func readPropertyList(_ plistName:String)->AnyObject?{//[String:AnyObject]{
        
        var data:AnyObject?
        let bundleID = "com.aggressiveTurtle.What-Wall-3D-IOS"
        //Bundle path
        let plistSourcePath:String? = Bundle.main.path(forResource: plistName, ofType: "plist")!
        
        //Document Directory Path
        let fileManager = FileManager.default
        //let documentDirectory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true)[0]
        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, .userDomainMask, true)[0]
        let customDirectory = (applicationSupportDirectory as NSString).appendingPathComponent("\(bundleID)/")
        let plistDestinationPath:String? = (customDirectory as NSString).appendingPathComponent("\(plistName).plist")

        if plistName == "Options"{
            var plistData:[String:AnyObject] = [:]
            
            if !fileManager.fileExists(atPath: plistDestinationPath!){
                print("******************File Doesn't Exist******************")
                print("Creating Directory******************")
                do{
                   try fileManager.createDirectory(atPath: customDirectory, withIntermediateDirectories: false, attributes: nil)
                }catch{
                    print("|||********* error creating Directory: \((error as NSError).localizedDescription) *********|||")
                }
                
                
                plistData = NSDictionary(contentsOfFile: plistSourcePath!) as! [String : AnyObject]
                
                do{
                    try fileManager.copyItem(atPath: plistSourcePath!, toPath: plistDestinationPath!)//documentDirectory)
                }catch{
                    print("||| ************************** error copying options plist from bundle to directory: \((error as NSError).localizedDescription) ************************** |||")
                    
                }
                
                
            }else{
                plistData = NSDictionary(contentsOfFile: plistDestinationPath!) as! [String : AnyObject]
                
            }
            data = plistData as AnyObject? //as [String:AnyObject]
            return plistData as AnyObject?
            
        }else if plistName == "NASAImages"{
            var plistData:[String] = []
            
            plistData = NSArray(contentsOfFile: plistSourcePath!) as! [String]
              
            data = plistData as AnyObject? //as [String]
            return plistData as AnyObject?
        }
        
        return data
    }
    
    func loadPropertyList(_ plistName:String, propertyListData:AnyObject){
        
        //let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let bundleID = "com.aggressiveTurtle.What-Wall-3D-IOS"
        let applicationSupportDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, .userDomainMask, true)[0]
        let customDirectory = (applicationSupportDirectory as NSString).appendingPathComponent("\(bundleID)/")
        let plistPath:String? = (customDirectory as NSString).appendingPathComponent("\(plistName).plist")
        
        (propertyListData as! NSDictionary).write(toFile: plistPath!, atomically: true)
        
    }
    
 
    
    @IBAction func startGameAction(_ sender: AnyObject) {
        //globalBackgroundNode.geometry!.firstMaterial!.diffuse.contents = nil
        //globalBackgroundNode.geometry!.firstMaterial!.diffuse.contents = UIColor.blackColor()
        
        returnedFromGame = true
        
        //backgroundNode.geometry!.firstMaterial!.diffuse.contents = nil
        //backgroundNode.geometry!.firstMaterial!.diffuse.contents = UIColor.blackColor()
        
        self.performSegue(withIdentifier: "startGameSegue", sender: nil)
    }
    
    
    @IBAction func optionsAction(_ sender: AnyObject) {
        
        
        if optionsData["optionsUnlocked"] as! Bool {
            self.performSegue(withIdentifier: "optionsSegue", sender: nil)
        }else{
            
            //add logic for in-app purchases
            
            
            
            
        }
    }
    
    @IBAction func testCongratsAction(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "test", sender: nil)
        
        
    }
    
    
    var returnedFromGame:Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("********************View Appeared********************")
        
        if returnedFromGame{
            //updateBackgroundImage()
            returnedFromGame = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier! == "startGameSegue" {
            
            let rootVC = segue.destination as! RootViewController
            rootVC.optionsData = self.optionsData
            //gameVC.imageData = self.imageData
            
            rootVC.emittorNode = self.emittorNode
            rootVC.particleSystem = self.particleSystem!
            
            //self.backgroundNode.geometry!.firstMaterial!.diffuse.contents = nil
            //self.backgroundNode.geometry!.firstMaterial!.diffuse.contents = UIColor.blackColor()
            
            self.emittorNode.removeFromParentNode()
            //gameVC.myScene.rootNode.addChildNode(gameVC.emittorNode)
 
        }else if segue.identifier == "optionsSegue" {
            
            let optionsVC = segue.destination as! OptionsViewController
            optionsVC.optionsData = self.optionsData
            print(optionsVC.optionsData)
            optionsVC.myScene = self.titlePageSCNView.scene!
            
            //emittorNode.removeParticleSystem(particleSystem!)
            
        }else if segue.identifier == "test" {
            
            let testVC = segue.destination as! CongratulationsViewController
            testVC.optionsData = self.optionsData
            print(testVC.optionsData)
            
            
            //emittorNode.removeParticleSystem(particleSystem!)
            
        }
        
        
        
    }
    
    @IBAction func unwindFromOptions(_ segue: UIStoryboardSegue){
    
        //loadPropertyList("Options", propertyListData: optionsData)
    
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
