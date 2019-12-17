//
//  KContentItemAutocompleteTableViewController.swift
//  Krake
//
//  Created by joel on 06/12/2019.
//  Copyright © 2019 Laser Srl. All rights reserved.
//

import UIKit
import LaserFloatingTextField

public protocol KContentItemAutocompleteTableViewControllerDelegate: NSObjectProtocol{

    func autocompleteTableViewController(_ controller: KAutocompleteTableViewController,
                                         didSelect item: ContentItem,
                                         for textField: UITextField?)

}

public struct KAutocompleteTableViewControllerOptions {
    public let endPoint: String
    public let searchOnline: Bool
    public let minNumberOfLetter: Int
    public let paramsKey: String

    public init(endPoint: String,
                searchOnline: Bool = false,
                minNumberOfLetter: Int = 3,
                paramsKey: String = "") {

        self.endPoint = endPoint
        self.searchOnline = searchOnline
        self.minNumberOfLetter = minNumberOfLetter
        self.paramsKey = paramsKey
    }
}

open class KAutocompleteTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!

    fileprivate var items: [ContentItem]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    fileprivate var allItems: [ContentItem]?

    var options: KAutocompleteTableViewControllerOptions!

    open weak var delegate: KContentItemAutocompleteTableViewControllerDelegate? = nil

    open weak var searchField: UITextField? = nil
    private var searchTimer: Timer? = nil
    fileprivate var task: OMLoadDataTask?

    //MARK: - static method

    public static func getViewController(options: KAutocompleteTableViewControllerOptions,
                                         searchField: UITextField) -> KAutocompleteTableViewController {

        let URLBundle : URL! = Bundle(for: object_getClass(CategoryPreferencesViewController.self)!).url(forResource: "ContentManager", withExtension: "bundle")
        let bundle = Bundle(url: URLBundle)!
        let container = UIStoryboard(name: "ContentModificationContainer", bundle: bundle)
            .instantiateViewController(withIdentifier: "AutocompleteViewController") as! KAutocompleteTableViewController

        container.options = options
        container.searchField = searchField

        return container
    }

    //MARK: - View

    open override func viewDidLoad() {
        view.tintColor = KTheme.current.color(.tint)

        if let textToSearch = searchField?.text {
            searchBar.text = textToSearch
            searchBar(searchBar, textDidChange: textToSearch)
        }
        if searchField is EGFloatingTextField {
            searchBar.placeholder = (searchField as? EGFloatingTextField)?.IBPlaceholder
        }
        else {
            searchBar.placeholder = searchField?.placeholder
        }

        searchBar.becomeFirstResponder()

        if (!options.searchOnline) {
            loadFromWS()
        }
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return KTheme.current.statusBarStyle(.default)
    }

    //MARK: - UISearchBar Delegate

    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !options.searchOnline ||
            searchText.count >= options.minNumberOfLetter {
            if (options.searchOnline) {
                searchTimer?.invalidate()
                searchTimer = Timer.scheduledTimer(withTimeInterval: 0.2,
                                                   repeats: false,
                                                   block: { (timer) in
                                                    self.searchTimer = nil
                                                    self.loadFromWS(searchText)
                })
            }
            else {
                items = allItems?.filter({$0.titlePartTitle?.contains(searchText) ?? false})
            }
        }
        else {
            searchTimer?.invalidate()
        }
    }

    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTimer?.invalidate()
        task?.cancel()
        dismiss(animated: true, completion: nil)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchTimer?.invalidate()
        searchTimer = nil
    }
    //MARK: - UITableView Delegate & DataSource

    override open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if let item = items?[(indexPath as NSIndexPath).row],
            let textLabel = cell.textLabel{
            textLabel.text = item.titlePartTitle
            KTheme.current.applyTheme(toLabel: textLabel, style: .title)
        }

        return cell
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[(indexPath as NSIndexPath).row] {
            delegate?.autocompleteTableViewController(self, didSelect: item, for: searchField)
        }

        dismiss(animated: true, completion: nil)
    }

    //MARK: - Table

    open func loadFromWS(_ searchWord: String = "")
    {
        task?.cancel()
        var params = KRequestParameters.parameters(currentPage: 1, pageSize: 9999)

        if (options.searchOnline && !searchWord.isEmpty) {
            params[options.paramsKey] = searchWord
        }

        task = OGLCoreDataMapper.sharedInstance().loadData(withDisplayAlias: options.endPoint,
                                                                  extras: params, loginRequired: false) { [weak self] (parsedObject, error, completed) -> Void in
                   if let mySelf = self
                   {
                       if parsedObject != nil
                       {
                           let cache = OGLCoreDataMapper.sharedInstance().managedObjectContext.object(with: parsedObject!) as! DisplayPathCache
                        mySelf.allItems = cache.cacheItems.array as? [ContentItem]
                    }
                       else {
                        mySelf.allItems = nil
                    }

                    if mySelf.options.searchOnline {
                        mySelf.items = mySelf.allItems
                    }
                    else {
                        let searchText = mySelf.searchBar.text
                        mySelf.items = searchText?.isEmpty ?? true ?
                            mySelf.allItems :
                            mySelf.allItems?.filter({$0.titlePartTitle?.contains(searchText!) ?? false})
                    }

                        mySelf.tableView.reloadData()

                   }
               }
    }

}
