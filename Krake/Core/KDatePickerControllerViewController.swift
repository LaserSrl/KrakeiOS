//
//  KDatePickerControllerViewController.swift
//  Krake
//
//  Created by joel on 09/06/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import UIKit

open class KDatePickerControllerViewController: UIViewController {
    
    public let datePicker = UIDatePicker();
    open var startDate = Date();
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.datePickerMode = .dateAndTime
        
        let visualView =  UIVisualEffectView(effect:  UIBlurEffect(style: .light))
        
        self.view.addSubview(visualView);
        
        self.view.addSubview(datePicker)
        
        self.view.frame = datePicker.frame;
        
        visualView.frame = self.view.bounds
        self.preferredContentSize = self.view.bounds.size;
        
        // Do any additional setup after loading the view.
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        datePicker.date = startDate
    }
}
