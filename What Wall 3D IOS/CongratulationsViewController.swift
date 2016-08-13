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
    var congratsTimer:NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        congratsTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(timerFireMethod(_:)), userInfo: nil, repeats: false)
        //congratsTimer.fire()
        
    }
    
    func timerFireMethod(timer:NSTimer){
        isCreditsStarted = true
    }
    
    var isCreditsStarted:Bool = false
    @IBAction func returnToTitleTapAction(sender: AnyObject) {
        
        if isCreditsStarted{
            performSegueWithIdentifier("unwindFromGameBeaten", sender: self)
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "unwindFromGameBeaten"{
            let rootVC = segue.destinationViewController as! RootViewController
            rootVC.goingToTitle = true
            self.optionsData["optionsUnlocked"] = true
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
