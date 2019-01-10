//
//  PoliciesSignatureViewController.swift
//  VerticalRetail
//
//  Created by Patrick on 11/08/17.
//  Copyright © 2017 Laser. All rights reserved.
//

import Foundation
import UIKit

public enum PolicyType: String{
    case all
    case forRegistration = "ForRegistration"
}

class PoliciesRegistrationViewController: ContentModificationViewController{
    
    @IBOutlet weak var policiesStackView: UIStackView?
    
    var policies: NSOrderedSet?{
        didSet{
            refreshData()
        }
    }
    var policyType: PolicyType = .all
    var policyEndPoint: String!
    var initialValue: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fields = [FieldItemWithPolicy]()
    }
    
    public func startLoadingData(policyType: PolicyType = .all, policyEndPoint: String){
        self.policyType = policyType
        self.policyEndPoint = policyEndPoint
        loadAllPolicies()
    }
    
    func loadAllPolicies(){
        var extras = KRequestParameters.parametersShowPrivacy()
        extras["type"] = policyType.rawValue
        OGLCoreDataMapper.sharedInstance().loadData(withController: KAPIConstants.policiesList, extras:  extras, loginRequired: false) { (object, error, completed) in
            if let object = object, completed{
                let cache = OGLCoreDataMapper.sharedInstance().displayPathCache(from: object)
                self.policies = cache.cacheItems
            }
        }
    }
    
    func refreshData(){
        if policies != nil{
            for case let policy as PolicyProtocol in policies!{
                if let fieldIndex = fields.index(where: { (item) -> Bool in
                    return (item as! FieldItemWithPolicy).policy?.identifier == policy.identifier
                }){
                    let field = fields[fieldIndex] as! FieldItemWithPolicy
                    field.policy = policy
                }else{
                    let field = FieldItemWithPolicy(self, action: #selector(changeValueFromFieldItem(_:)))
                    field.policy = policy
                    fields.append(field)
                    policiesStackView?.addArrangedSubview(field.view!)
                    saveOnParams(policyId: policy.identifier)
                }
            }
        }
        if let policy = initialValue as? ContentItemWithUserPolicyAnswersRecord, let answered = policy.userPolicyPartUserPolicyAnswers{
            for case let answer as UserPolicyAnswersRecordProtocol in answered{
                if let fieldIndex = fields.index(where: { (item) -> Bool in
                    return (item as! FieldItemWithPolicy).policy?.identifier == answer.policyTextInfoPartRecordIdentifier
                }){
                    let field = fields[fieldIndex] as! FieldItemWithPolicy
                    field.userPolicyAnswerRecord = answer
                }else{
                    KLog(type: .error, "Error")
                }
                if let identifier = answer.policyTextInfoPartRecordIdentifier{
                    saveOnParams(policyId: identifier, accepted: answer.accepted?.boolValue)
                }
            }
        }
    }
    
    override func reloadAllDataFromParams() {
        refreshData()
    }
    
    override func setInitialData(_ item: AnyObject) {
        initialValue = item
    }
    
    @objc func changeValueFromFieldItem(_ fieldItem: FieldItemWithPolicy){
        saveOnParams(policyId: fieldItem.policy!.identifier, accepted: fieldItem.currentValue() as? Bool)
    }
    
    func saveOnParams(policyId: NSNumber, accepted: Bool? = nil){
        var userPolicyAnswers: NSMutableArray? = params[policyEndPoint] as? NSMutableArray
        if userPolicyAnswers == nil {
            userPolicyAnswers = NSMutableArray()
        }
        var findUserPolicyAnswer: NSMutableDictionary? = nil
        for case let userPolicyAnswer as NSMutableDictionary in userPolicyAnswers!{
            if userPolicyAnswer["Id"] as? NSNumber == policyId {
                findUserPolicyAnswer = userPolicyAnswer
                break
            }
        }
        if findUserPolicyAnswer == nil
        {
            let findUserPolicyAnswer = NSMutableDictionary(dictionary: ["Id" : policyId, "Accepted" : accepted ?? false])
            userPolicyAnswers!.add(findUserPolicyAnswer)
        }else{
            if accepted != nil {
                findUserPolicyAnswer!["Accepted"] = accepted
            }
        }
        params[policyEndPoint] = userPolicyAnswers
    }

}

