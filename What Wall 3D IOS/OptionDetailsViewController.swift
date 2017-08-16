//
//  OptionDetailsViewController.swift
//  What Wall 3D IOS
//
//  Created by Edmond Akpan on 8/8/16.
//  Copyright © 2016 future. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SceneKit

class OptionDetailsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var optionsData:[String:AnyObject] = [:]
    
    @IBOutlet weak var optionDetailsSCNView: SCNView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    weak var myScene:SCNScene!
    
    
    var maxPickerViewRows:Int = 0

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.dataSource = self
        pickerView.delegate = self
        
        if maxPickerViewRows == 3{ //difficulty
            
            let optionDifficulty:Int = self.optionsData["difficulty"] as! Int - 1
            pickerView.selectRow(optionDifficulty, inComponent: 0, animated: false)
            
        }else if maxPickerViewRows == 30{ //levels
            
            let optionLevel:Int = (optionsData["level"] as! Int) - 1
            pickerView.selectRow(optionLevel, inComponent: 0, animated: false)
        }else if maxPickerViewRows == 9{ //lives
            
            let optionLives:Int = (optionsData["lives"] as! Int) - 1
            pickerView.selectRow(optionLives, inComponent: 0, animated: false)
        }
        optionDetailsSCNView.scene = myScene
        optionDetailsSCNView.backgroundColor = UIColor.black
        
        if !(optionsData["optionsUnlocked"] as! Bool){
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.isHidden = false//true
        }else{
            bannerView.isHidden = true
        }
        
        
        
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return maxPickerViewRows
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 75
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 250
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = view as? UILabel ?? UILabel()
        
        label.textColor = UIColor.white
        var text = ""
        
        if maxPickerViewRows == 3{ //difficulty levels
            
            var difficultyString = ""
            if row + 1 == 1{
                difficultyString = "easy"
            }else if row + 1 == 2{
                difficultyString = "hard"
            }else if row + 1 == 3{
                difficultyString = "ultra hard"
            }
            text = difficultyString
            
        }else if maxPickerViewRows == 30{ //game levels
            
            text = "\(row + 1)"
            
        }else if maxPickerViewRows == 9{ //game lives
            
            text = "\(row + 1)"
            
        }
        
        label.font = UIFont(name: "IowanOldStyle-Roman", size: 50)!
        
        label.text = text
        label.textAlignment = NSTextAlignment.center
        
        return label
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if maxPickerViewRows == 3{ //difficulty levels
            
            optionsData["difficulty"] = (row + 1) as AnyObject
            
        }else if maxPickerViewRows == 30{ //game levels
            
            optionsData["level"] = (row + 1) as AnyObject
        }else if maxPickerViewRows == 9{ //game lives
            
            optionsData["lives"] = (row + 1) as AnyObject
        }
    }
    
    
    
    
    
    @IBAction func backButtonAction(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "unwindFromOptionDetails", sender: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier! == "unwindFromOptionDetails"{
            
            let optionsVC = segue.destination as! OptionsViewController
            optionsVC.optionsData = self.optionsData
            
            optionDetailsSCNView.scene = nil
            
        }
    
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    /*
    // MARK: - Navigation

    */

}
