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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var splitButton: UIButton!
    
    var formatter = NSNumberFormatter()
    var timer: NSTimer!
    var showDetails = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale.currentLocale()
        currencyLabel.text = formatter.currencySymbol
        
        splitButton.layer.cornerRadius = 4;
        splitButton.layer.borderWidth = 1;
        splitButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(
                self,
                selector: "onAppEnterBackground:",
                name: AppEvents.appEnterBackgroundEvent,
                object: nil)
        
        initBillAmount()
    }
    
    func initBillAmount() {
        tipLabel.text = formatter.stringFromNumber(0.0)
        totalLabel.text = formatter.stringFromNumber(0.0)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let lastTipDate = defaults.objectForKey(AppKeys.lastTipDateKey)
        let lastBillAmount = defaults.objectForKey(AppKeys.lastBillAmountKey)
        
        // try to restore the last bill amount if its < 10 mins ago
        if lastTipDate != nil && lastBillAmount != nil {
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
        updateViews()
        
        let tipPercentage = AppConfig.tipPercentages[tipControl.selectedSegmentIndex]
        let billAmount = NSString(string: billField.text!).doubleValue
        let tip = billAmount * tipPercentage
        let total = billAmount + tip
                
        tipLabel.text = formatter.stringFromNumber(tip)
        totalLabel.text = formatter.stringFromNumber(total)
        
        animateTotal()
    }
    
    func updateViews() {
        if billField.text!.isEmpty {
            self.tipControl.hidden = true
            self.containerView.hidden = true
            self.currencyLabel.hidden = false
            UIView.animateWithDuration(0.4, animations: {
                self.currencyLabel.frame = CGRectOffset(self.currencyLabel.frame, 0, 100)
                self.billField.frame = CGRectOffset(self.billField.frame, 0, 100)
            }, completion: { finished in
                self.showDetails = false
            })
            
        } else if !showDetails {
            self.currencyLabel.hidden = true
            UIView.animateWithDuration(0.4, animations: {
                self.currencyLabel.frame = CGRectOffset(self.currencyLabel.frame, 0, -100)
                self.billField.frame = CGRectOffset(self.billField.frame, 0, -100)
            }, completion: { finished in
                self.showDetails = true
                self.tipControl.hidden = false
                self.containerView.hidden = false
            })
        }
    }
    
    func animateTotal() {
        if billField.text?.isEmpty == false {
            if (timer != nil) {
                timer.invalidate()
                timer = nil
            }
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: Selector("timedAnimation"), userInfo: nil, repeats: false)
        } else {
            if (timer != nil) {
                timer.invalidate()
                timer = nil
            }
        }
    }
    
    func timedAnimation() {
        let shakeAnim = CABasicAnimation(keyPath: "position")
        shakeAnim.duration = 0.07
        shakeAnim.repeatCount = 6
        shakeAnim.autoreverses = true
        shakeAnim.fromValue = NSValue(CGPoint: CGPointMake(totalLabel.center.x - 10, totalLabel.center.y))
        shakeAnim.toValue = NSValue(CGPoint: CGPointMake(totalLabel.center.x + 10, totalLabel.center.y))
        totalLabel.layer.addAnimation(shakeAnim, forKey: "position")
        
        UIView.transitionWithView(totalLabel, duration: 1, options: .TransitionCrossDissolve, animations: { self.totalLabel.textColor = UIColor.redColor() }, completion: { finished in
            // completion
            self.totalLabel.textColor = UIColor.whiteColor()
        })
    }
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }

    @IBAction func onSplitClicked(sender: AnyObject) {
        view.endEditing(true)
    }
    
}

