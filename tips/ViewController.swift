//
//  ViewController.swift
//  tips
//
//  Created by Hieu Nguyen on 12/25/15.
//  Copyright © 2015 codepath. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var splitButton: UIButton!
    @IBOutlet weak var numberPicker: UIPickerView!
    @IBOutlet weak var splitTotalLabel: UILabel!
    
    var total = 0.0
    var splitBase = 2
    
    var formatter = NSNumberFormatter()
    var timer: NSTimer!
    var showDetails = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.numberPicker.dataSource = self;
        self.numberPicker.delegate = self;
        currencyLabel.hidden = true
        
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale.currentLocale()
        currencyLabel.text = formatter.currencySymbol
        
        billField.textColor = UIColor.grayColor()
        totalLabel.textColor = UIColor.redColor()
        
        splitButton.layer.cornerRadius = 4;
        splitButton.layer.borderWidth = 1;
        splitButton.layer.borderColor = UIColor.whiteColor().CGColor
//        splitTotalLabel.textColor = UIColor(red: CGFloat(40/255.0), green: CGFloat(240/255.0), blue: CGFloat(40/255.0), alpha: CGFloat(1.0))
        splitTotalLabel.textColor = UIColor.greenColor()
        
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
        showDetails = true
        billField.text = ""
        tipLabel.text = formatter.stringFromNumber(0.0)
        totalLabel.text = formatter.stringFromNumber(0.0)
        onEditingChanged(nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let lastTipDate = defaults.objectForKey(AppKeys.lastTipDateKey)
        let lastBillAmount = defaults.objectForKey(AppKeys.lastBillAmountKey)
        
        // try to restore the last bill amount if its < 10 mins ago
        if lastTipDate != nil && lastBillAmount != nil {
            let elapsedTime = Int(NSDate().timeIntervalSinceDate(lastTipDate as! NSDate))
            if (elapsedTime < AppConfig.maxCacheTime) {
                billField.text = lastBillAmount as? String
            }
        }
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
    
    override func viewDidAppear(animated: Bool) {
        let window = UIApplication.sharedApplication().keyWindow
        let overlay = UIView(frame: UIScreen.mainScreen().bounds)
//        overlay.backgroundColor = UIColor(red: CGFloat(38/255.0), green: CGFloat(114/255.0), blue: CGFloat(38/255.0), alpha: CGFloat(1.0))
        overlay.backgroundColor = UIColor.greenColor()
        overlay.alpha = 0.1
        overlay.userInteractionEnabled = false
        window?.addSubview(overlay)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onEditingChanged(sender: AnyObject?) {
        updateViews()
        calculateTotal()
    }
    
    func calculateTotal() {
        let tipPercentage = AppConfig.tipPercentages[tipControl.selectedSegmentIndex]
        let billAmount = NSString(string: billField.text!).doubleValue
        let tip = billAmount * tipPercentage
        total = billAmount + tip
        
        tipLabel.text = formatter.stringFromNumber(tip)
        totalLabel.text = formatter.stringFromNumber(total)
        calculateSplitTotal()
        
        animateTotal()
    }
    
    func updateViews() {
        if showDetails && billField.text!.isEmpty {
            self.showDetails = false
            self.tipControl.hidden = true
            self.containerView.hidden = true
            self.currencyLabel.hidden = false
            UIView.animateWithDuration(0.4, animations: {
                self.currencyLabel.frame = CGRectOffset(self.currencyLabel.frame, 0, 100)
                self.billField.frame = CGRectOffset(self.billField.frame, 0, 100)
            }, completion: { finished in
                
            })
        } else if !showDetails && !billField.text!.isEmpty {
            self.showDetails = true
            self.currencyLabel.hidden = true
            UIView.animateWithDuration(0.4, animations: {
                self.currencyLabel.frame = CGRectOffset(self.currencyLabel.frame, 0, -100)
                self.billField.frame = CGRectOffset(self.billField.frame, 0, -100)
            }, completion: { finished in
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
            
            timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("timedAnimation"), userInfo: nil, repeats: false)
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
        
        UIView.transitionWithView(totalLabel, duration: 1, options: .TransitionCrossDissolve, animations: { self.totalLabel.textColor = UIColor.whiteColor() }, completion: { finished in
            // completion
            self.totalLabel.textColor = UIColor.redColor()
        })
    }
    
    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }

    @IBAction func onSplitClicked(sender: AnyObject) {
        view.endEditing(true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100;
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let myTitle = NSAttributedString(string: String(row + 2), attributes: [NSFontAttributeName:UIFont(name: "Helvetica Neue", size: 26.0)!,NSForegroundColorAttributeName:UIColor.blackColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .Center
        pickerLabel.textColor = UIColor.whiteColor()
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        splitBase = row + 2
        calculateSplitTotal()
    }
    
    func calculateSplitTotal() {
        let oldTotal = splitTotalLabel.text
        var newTotal: String!
        if (splitBase == 0) {
            newTotal = formatter.stringFromNumber(0.0)
        } else {
            let splitTotal = total / Double(splitBase)
            newTotal = formatter.stringFromNumber(splitTotal)
        }
        UIView.animateWithDuration(0.4, animations: {
            self.splitTotalLabel.text = oldTotal
            self.splitTotalLabel.alpha = 0.0
            }, completion: { finished in
                self.splitTotalLabel.alpha = 1.0
                self.splitTotalLabel.text = newTotal
        })
    }
}

