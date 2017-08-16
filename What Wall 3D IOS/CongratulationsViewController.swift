//
//  CongratulationsViewController.swift
//  What Wall 3D IOS
//
//  Created by Edmond Akpan on 8/13/16.
//  Copyright © 2016 future. All rights reserved.
//

import UIKit

class CongratulationsViewController: UIViewController {

    var optionsData:[String:AnyObject] = [:]
    var congratsTimer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        congratsTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerFireMethod(_:)), userInfo: nil, repeats: false)
        //congratsTimer.fire()
        
    }
    
    func timerFireMethod(_ timer:Timer){
        isCreditsStarted = true
    }
    
    var isCreditsStarted:Bool = false
    @IBAction func returnToTitleTapAction(_ sender: AnyObject) {
        
        if isCreditsStarted{
            performSegue(withIdentifier: "unwindFromGameBeaten", sender: self)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "unwindFromGameBeaten"{
            let rootVC = segue.destination as! RootViewController
            rootVC.goingToTitle = true
            self.optionsData["optionsUnlocked"] = true as AnyObject?
            rootVC.optionsData = self.optionsData
        }
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
