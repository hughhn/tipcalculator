//
//  ViewController.swift
//  tips
//
//  Created by Hieu Nguyen on 12/25/15.
//  Copyright © 2015 codepath. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    var formatter = NSNumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale.currentLocale()
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(
                self,
                selector: "onAppEnterBackground:",
                name: AppEvents.appEnterBackgroundEvent,
                object: nil)
        
        setupBillAmount()
    }
    
    func setupBillAmount() {
        tipLabel.text = formatter.stringFromNumber(0.0)
        totalLabel.text = formatter.stringFromNumber(0.0)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let lastTipDate = defaults.objectForKey(AppKeys.lastTipDateKey)
        let lastBillAmount = defaults.objectForKey(AppKeys.lastBillAmountKey)
        
        // try to restore the last bill amount if its < 10 mins ago
        if (lastTipDate != nil && lastBillAmount != nil) {
            let elapsedTime = Int(NSDate().timeIntervalSinceDate(lastTipDate as! NSDate))
            if (elapsedTime < AppConfig.maxCacheTime) {
                billField.text = lastBillAmount as? String
                onEditingChanged(nil)
            }
        }
        
        // Reset cache
        defaults.setObject(nil, forKey: AppKeys.lastTipDateKey)
        defaults.setObject(nil, forKey: AppKeys.lastBillAmountKey)
    }
    
    dynamic func onAppEnterBackground(notification: NSNotification){
        // app is entering background, save the time and bill amount
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSDate(), forKey: AppKeys.lastTipDateKey)
        defaults.setObject(billField.text, forKey: AppKeys.lastBillAmountKey)
        defaults.synchronize()
    }
    
    override func viewWillAppear(animated: Bool) {
        billField.becomeFirstResponder()
        
        // refresh to the correct percentage tab
        let defaults = NSUserDefaults.standardUserDefaults()
        let defaultTipIndex = defaults.integerForKey(AppKeys.tipIndexKey)
        tipControl.selectedSegmentIndex = defaultTipIndex
        onEditingChanged(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onEditingChanged(sender: AnyObject?) {
        let tipPercentage = AppConfig.tipPercentages[tipControl.selectedSegmentIndex]
        let billAmount = NSString(string: billField.text!).doubleValue
        let tip = billAmount * tipPercentage
        let total = billAmount + tip
                
        tipLabel.text = formatter.stringFromNumber(tip)
        totalLabel.text = formatter.stringFromNumber(total)
    }

    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }

}

