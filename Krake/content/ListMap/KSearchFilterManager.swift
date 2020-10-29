//
//  OCSearchFilterManager.swift
//  OrchardCore
//
//  Created by joel on 09/03/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation

public struct KSearchFilterOptions
{
    /// Use .default for a default struct settings, by default
    /// - filterableKeys is ["titlePartTitle"]
    /// - onlineSearch is false
    public static let `default` = KSearchFilterOptions()
    
    public var filterableKeys: [String]! = ["titlePartTitle"]
    public var onlineSearch: Bool = false
    
    public init(filterableKeys: [String]! = ["titlePartTitle"],
                onlineSearch: Bool = false) {
        self.filterableKeys = filterableKeys
        self.onlineSearch = onlineSearch
    }
    
    public func isValid() -> Bool
    {
        return !filterableKeys.isEmpty
    }
}

class KSearchFilterManager: NSObject, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    weak var delegate: KSearchFilterManagerDelegate!
    public let searchOptions: KSearchFilterOptions
    weak var searchBar: UISearchBar!
    weak var rootView: UIView? = nil
    fileprivate var leftSearchBarConstraint: NSLayoutConstraint? = nil
    
    init(searchBar: UISearchBar? = nil, delegate: KSearchFilterManagerDelegate!, searchOptions: KSearchFilterOptions)
    {
        self.searchOptions = searchOptions
        super.init()
        self.searchBar = searchBar
        self.delegate = delegate
        if searchBar != nil {
            applyStyleToSearchBar()
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleTouchUpOutside))
        tap.cancelsTouchesInView = false
        searchBar?.superview?.superview?.addGestureRecognizer(tap)
    }
    
    func applyStyleToSearchBar(){
        searchBar.sizeToFit()
        searchBar.showsScopeBar = true
        searchBar.placeholder = KLocalization.Commons.insertTextToSearch
        searchBar.delegate = self
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        delegate.searchFilter(self, textDidChange: nil)
        delegate.searchFilterDidEndEditing(self, searchBar: searchBar)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchOptions.onlineSearch {
            delegate.searchFilter(self, textDidChange: searchBar.text)
        }
        delegate.searchFilterDidEndEditing(self, searchBar: searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchOptions.onlineSearch {
            let empty = searchBar.text != nil && searchBar.text!.isEmpty
            delegate.searchFilter(self, textDidChange: empty ? nil : searchBar.text!)
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchOptions.onlineSearch {
            let empty = searchBar.text != nil && searchBar.text!.isEmpty
            delegate.searchFilter(self, textDidChange: empty ? nil : searchBar.text!)
        }
    }
    
    func generateAndSaveSearchBar(_ tabView :UIView, rootView: UIView)
    {
        self.rootView = rootView
        let searchBar = UISearchBar()
        self.searchBar = searchBar
        applyStyleToSearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tabView.insertSubview(searchBar, at: 10)
        tabView.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .centerY, relatedBy: .equal, toItem: tabView, attribute: .centerY, multiplier: 1, constant: 0))
        tabView.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .height, relatedBy: .equal, toItem: tabView, attribute: .height, multiplier: 1, constant: 0))
        tabView.addConstraint(NSLayoutConstraint(item: searchBar, attribute: .width, relatedBy: .equal, toItem: tabView, attribute: .width, multiplier: 1, constant: 0))
        leftSearchBarConstraint = NSLayoutConstraint(item: searchBar, attribute: .left, relatedBy: .equal, toItem: tabView, attribute: .left, multiplier: 1, constant: 0)
        tabView.addConstraint(leftSearchBarConstraint!)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(KSearchFilterManager.toggleTouchUpOutside))
        gesture.delegate = self
        rootView.addGestureRecognizer(gesture)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if searchBar!.isFirstResponder {
            return true
            
        }
        return false
    }
    
    var text: String? {get{
        return searchBar?.text
        }
    }
    
    @objc func toggleTouchUpOutside(){
        if searchBar!.isFirstResponder {
            searchBar?.resignFirstResponder()
        }
    }
    
    func updateHideConstraintIfSearchBarHidden()
    {
        if self.leftSearchBarConstraint?.constant != 0 {
            hideSearchBar()
        }
    }
    
    func hideSearchBar()
    {
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.leftSearchBarConstraint?.constant = -self.searchBar!.frame.width
            self.rootView!.layoutIfNeeded()
        })
        
    }
    
    func showSearchBar()
    {
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.leftSearchBarConstraint?.constant = 0
            self.rootView!.layoutIfNeeded()
        }
        searchBar!.becomeFirstResponder()
    }
    
}

protocol KSearchFilterManagerDelegate : NSObjectProtocol
{
    func searchFilterDidEndEditing(_ manager: KSearchFilterManager, searchBar: UISearchBar)
    
    func searchFilter(_ manager: KSearchFilterManager, textDidChange newText: String?)
    
}
