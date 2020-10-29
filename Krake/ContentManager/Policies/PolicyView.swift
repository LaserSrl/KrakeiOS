//
//  PolicyView.swift
//  Krake
//
//  Created by Patrick on 29/09/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation

class FieldItemWithPolicy: NSObject, FieldItem{
    
    public var key: String = ""
    public var coreDataKeyPath: String?
    public var placeholder: String?
    public var view: UIView?
    public var required: Bool = false
    
    open var visibleOnly: Bool = false{
        didSet{
            policySwitch.isEnabled = !visibleOnly
        }
    }
    
    weak var policyText: UILabel!
    weak var policySwitch: UISwitch!
    public var target: AnyObject
    public var action: Selector
    public var policy: PolicyProtocol?{
        didSet{
            required = policy?.policyTextInfoPartUserHaveToAccept?.boolValue ?? false
            if required
            {
                let string = NSMutableAttributedString(string:policy?.titlePartTitle ?? "")
                string.append(NSAttributedString(string: "\n"))
                
                string.append(NSAttributedString(string: KLocalization.Policies.required, attributes: [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote), NSAttributedString.Key.foregroundColor : UIColor.red]))
                
                policyText?.attributedText = string
            }
            else
            {
                policyText?.text = policy?.titlePartTitle
            }
        }
    }
    public var userPolicyAnswerRecord: UserPolicyAnswersRecordProtocol?{
        didSet{
            if required{
                visibleOnly = userPolicyAnswerRecord?.accepted?.boolValue ?? false
            }
            policySwitch?.isOn = userPolicyAnswerRecord?.accepted?.boolValue ?? false
        }
    }
    
    init(_ target: AnyObject, action: Selector) {
        self.target = target
        self.action = action
        super.init()
        let view = UIView()
        
        let label = UILabel()
        policyText = label
        policyText.numberOfLines = 0
        policyText.translatesAutoresizingMaskIntoConstraints = false
        policyText.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openPolicy))
        label.addGestureRecognizer(gesture)
        view.addSubview(label)
        
        let switcher = UISwitch()
        policySwitch = switcher
        policySwitch.tintColor = KTheme.current.color(.tint)
        policySwitch.onTintColor = KTheme.current.color(.tint)
        policySwitch.addTarget(self, action: #selector(changeValue), for: .touchUpInside)
        policySwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switcher)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-(8)-[policyText]-(8)-[policySwitch(44)]-(8)-|", options: .directionLeftToRight, metrics: nil, views: ["policyText" : policyText!, "policySwitch" :  policySwitch!]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[policyText]-(8)-|", options: .directionLeftToRight, metrics: nil, views: ["policyText" : policyText!]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[policySwitch]-(8)-|", options: .directionLeftToRight, metrics: nil, views: ["policySwitch" : policySwitch!]))
        
        self.view = view
    }
    
    @objc func changeValue(){
        _ = target.perform(action, with: self)
    }
    
    @objc func openPolicy(){
        view?.containingViewController()?.presentPolicyViewController(policyEndPoint: policy?.autoroutePartDisplayAlias, policyTitle: policy?.titlePartTitle, policyText: policy?.bodyPartText, largeMargin: false)
    }
    
    
    func setInitialValue(_ value: Any?) {
        policySwitch.isOn = (value as? NSNumber)?.boolValue ?? false
    }
    
    func currentValue() -> Any? {
        return policySwitch.isOn
    }
    
    func isDataValid(params: NSMutableDictionary) throws {
        if(policySwitch.isOn == false && required) {
            throw FieldItemError.notValidData(KLocalization.Policies.undoPrivacy)
        }
    }
}
