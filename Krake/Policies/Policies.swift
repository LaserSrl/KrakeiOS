//
//  Policies.swift
//  Krake
//
//  Created by Patrick on 26/05/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

open class PoliciesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate var policies: [String : [PolicyProtocol?]]? = [String : [PolicyProtocol?]]()
    fileprivate var categories = [String]()
    fileprivate var response: [[String : AnyObject]]?
    fileprivate var modifiedResponse: [AnyHashable: Any]?
    fileprivate var progressUpload: MBProgressHUD? = nil
    
    fileprivate lazy var sendButton = { () -> UIBarButtonItem in
        return UIBarButtonItem(title: KLocalization.Commons.send, style: .done, target: self, action: #selector(PoliciesViewController.sendPolicy))
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Static method
    @available(*, deprecated, renamed: "newPolicies")
    public static func preparePoliciesViewController() -> PoliciesViewController{
        return PoliciesViewController.newPolicies()
    }
    
    public static func newPolicies() -> PoliciesViewController{
        let url = Bundle(for: PoliciesViewController.self).url(forResource: "Policies", withExtension: "bundle")!
        let story = UIStoryboard(name: "Policies", bundle: Bundle(url: url))
        let vc = story.instantiateInitialViewController() as! PoliciesViewController
        return vc
    }
    
    //MARK: - UIView
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        KTheme.current.applyTheme(toView: view, style: .default)
        KTheme.current.applyTheme(toTableView: tableView, style: .default)
        loadCookiesParams()
        var extras = KRequestParameters.parametersShowPrivacy()
        extras["type"] = "All"
        OGLCoreDataMapper.sharedInstance().loadData(withController: KAPIConstants.policiesList, extras: extras, loginRequired: true) { (parsedObject, error, completed) in
            if parsedObject != nil && completed {
                let cache = OGLCoreDataMapper.sharedInstance().displayPathCache(from: parsedObject!)
                let arrayPol = cache.cacheItems.array
                var mutablePolicies = [String : [PolicyProtocol?]]()
                self.categories = [String]()
                for policy in arrayPol{
                    if let pol = policy as? PolicyProtocol, let type = pol.policyTextInfoPartPolicyType {
                        var policies = mutablePolicies[type] ?? { let newPolicies = [PolicyProtocol](); mutablePolicies[type] = newPolicies; return newPolicies}()
                        if !self.categories.contains(type){
                            self.categories.append(type)
                        }
                        policies.append(pol)
                        mutablePolicies[type] = policies;
                    }
                }
                self.policies = mutablePolicies
                self.tableView.reloadData()
            }
            if completed && error != nil{
                KMessageManager.showMessage(error!.localizedDescription, type: .error)
            }
        }
        navigationItem.rightBarButtonItem = sendButton
        checkIfChangedValues()
        title = KLocalization.Policies.managePolicy
        
        progressUpload = MBProgressHUD(view: view)
        view.addSubview(progressUpload!)
    }
    
    func loadCookiesParams(){
        if let data = UserDefaults.standard.object(forKey: "PoliciesAnswers") as? Data,
           let policiesAnswers = NSKeyedUnarchiver.unarchiveObject(with: data),
           let datac = Data(base64Encoded: (policiesAnswers as AnyObject).value, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters){
            do {
                response = try JSONSerialization.jsonObject(with: datac, options: .allowFragments) as? [[String : AnyObject]]
            }catch{
            }
        }
    }
    
    @objc func sendPolicy(){
        if modifiedResponse != nil && response != nil {
            progressUpload?.showAsUploadProgress()
            for res in response!{
                let number: NSNumber = res["PolicyTextId"] as! NSNumber
                
                if modifiedResponse![number.stringValue] == nil {
                    let bol = NSNumber(value: res["Accepted"] as! Bool)
                    modifiedResponse![number.stringValue] = bol
                }else{
                    
                }
            }
            KNetworkAccess.sharedInstance().sendPoliciesToKrake(modifiedResponse! as NSDictionary, success: { (task, object) in
                self.modifiedResponse = nil
                self.checkIfChangedValues()
                self.loadCookiesParams()
                self.tableView.reloadData()
                self.progressUpload?.dismissAsUploadProgress(completedWithSuccess: true)
                }, failure: { (task, error) in
                    
                    KMessageManager.showMessage(error.localizedDescription, type: .error)
                    self.progressUpload?.dismissAsUploadProgress(completedWithSuccess: false)
            })
        }
    }
    
    func checkIfChangedValues(){
        sendButton.isEnabled = (modifiedResponse != nil)
    }
    
    //MARK: - UITableViewDelegate, UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return policies![categories[section]]!.count
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return KLocalization.ocLocalizable("Policies." + categories[section])
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let policy = policies?[categories[indexPath.section]]?[indexPath.row]{
            if let nav = navigationController{
                nav.pushPolicyViewController(policyTitle: policy.titlePartTitle, policyText: policy.bodyPartText, largeMargin: false)
            }else{
                presentPolicyViewController(policyEndPoint: policy.autoroutePartDisplayAlias, policyTitle: policy.titlePartTitle, policyText: policy.bodyPartText, largeMargin: false)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let switchButton = UISwitch()
        let policy = policies![categories[indexPath.section]]![indexPath.row]!
        cell.textLabel?.text = policy.titlePartTitle
        var accepted = false
        if response != nil {
            for res in response!{
                if res["PolicyTextId"] as? NSNumber == policy.identifier! {
                    if res["Accepted"] as? Bool == true {
                        accepted = true
                    }
                    break
                }
            }
        }
        var acceptedModified = false
        if modifiedResponse != nil {
            if ((modifiedResponse![String(describing: policy.identifier)] as? Bool) != nil) {
                acceptedModified = (modifiedResponse![String(describing: policy.identifier)] as? Bool)!
            }
        }
        var obbligatorio = ""
        if let bool = policy.policyTextInfoPartUserHaveToAccept{
            if bool.boolValue {
                obbligatorio = KLocalization.Policies.required
                switchButton.isEnabled = !accepted
            }else{
                switchButton.isEnabled = true
            }
        }
        cell.detailTextLabel?.text = obbligatorio
        
        cell.imageView?.image = policy.policyTextInfoPartPolicyTypeImage()
        cell.imageView?.contentMode = .scaleAspectFit
        
        KTheme.current.applyTheme(toSwitch: switchButton, style: .policy)
        switchButton.isOn = (accepted || acceptedModified)
        switchButton.addTarget(self, action: #selector(PoliciesViewController.changeSwitch(_:)), for: UIControl.Event.valueChanged)
        cell.accessoryView = switchButton
        
        return cell
    }
    
    
    @objc func changeSwitch(_ constrolSwitch: UISwitch){
        if let cell = constrolSwitch.superview as? UITableViewCell {
            
            if modifiedResponse == nil {
                modifiedResponse = [AnyHashable: Any]()
            }
            if let indexPath = tableView.indexPath(for: cell){
                let policy = policies![categories[indexPath.section]]![indexPath.row]
                modifiedResponse?[policy!.identifier.stringValue] = NSNumber(value: constrolSwitch.isOn)
            }
            checkIfChangedValues()
        }
    }
    
}
