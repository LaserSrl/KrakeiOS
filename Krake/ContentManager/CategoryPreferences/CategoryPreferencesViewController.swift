//
//  CategoryPreferencesViewController.swift
//  ExpertMallardo
//
//  Created by Marco Zanino on 05/05/16.
//  Copyright © 2016 Laser Group. All rights reserved.
//

import UIKit

open class CategoryPreferencesViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var imgView: UIImageView?
}

open class CategoryPreferencesViewController: ContentModificationViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet open weak var categoriesTableView: UITableView!
    
    /// Array of categories that can be selected by the user.
    fileprivate var categories: [ContentTypeSelectionEnumOrTerm]? {
        didSet {
            if categoriesTableView != nil{
                categoriesTableView.reloadData()
            }
        }
    }
    
    /// Customization of the colors used to tint the table cell.
    fileprivate var selectedColor: UIColor!
    fileprivate var unselectedColor: UIColor!
    fileprivate var canShowImage: Bool = false
    fileprivate var cellNib: UINib!
    
    
    open func setupParams(fieldItem item: FieldItem,
                                      checkmarkSelectedColor _selectedColor: UIColor? = nil,
                                                             checkmarkUnselectedColor _unselectedColor: UIColor? = nil,
                                                                                      tableViewCellNib _cellNib: UINib? = nil) {
        
        selectedColor = _selectedColor ?? KTheme.current.color(.tint)
        unselectedColor = _unselectedColor ?? UIColor.lightGray
        let URLBundle : URL! = Bundle(for: object_getClass(CategoryPreferencesViewController.self)!).url(forResource: "ContentManager", withExtension: "bundle")
        let bundle = Bundle(url: URLBundle)
        let nibTake = UINib(nibName: "CategoryPreferencesCellView", bundle: bundle)
        cellNib = _cellNib ?? nibTake
        categoriesTableView.register(cellNib, forCellReuseIdentifier: "cell")
        
        fields = [ item ]
        
        title = item.placeholder
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if categoriesTableView.indexPathsForVisibleRows != nil {
            categoriesTableView.reloadRows(at: categoriesTableView.indexPathsForVisibleRows!, with: .automatic)
        }
    }
    
    // MARK : - ContentModificationViewController methods
    
    /**
     Initialize the parameters with the configuration object in cache.
     
     - parameter item: The NSManagedObject that contains the configurations.
     */
    override open func setInitialData(_ item: AnyObject) {
        guard let coreDataKeyPath = fields.first?.coreDataKeyPath else {
            fatalError("No core data keypath founded of no FieldItem setted.")
        }
        
        if let value = item.value(forKeyPath: coreDataKeyPath) {
            if let array = value as? NSOrderedSet {
                if array.firstObject is TermPartProtocol {
                    var categories = [Int]()
                    for elem in array {
                        let term = elem as! TermPartProtocol
                        categories.append(term.identifier!.intValue)
                    }
                    params[fields.first!.key] = categories
                    
                    categoriesTableView.reloadData()
                }
            }
        }
    }
    
    /**
     Notify the view controller that some data is available from WS.
     */
    override open func reloadAllDataFromParams() {
        if let field = contentTypeSelectionFields {
            for csf in field{
                if csf.key == fields.first!.key{
                    categories = csf.values
                    canShowImage = csf.settings.imageVisible
                }
            }
        }
    }
    
    // MARK: - UITableView delegate & data source
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryPreferencesViewCell
        let category = categories![(indexPath as NSIndexPath).row]
        // Adding the title of the current category.
        cell.label?.text = category.name
        // Checking if the current category has already been selected by the user.
        if let categoryId = category.numberValue {
            cell.tintColor = unselectedColor
            if let selectedCategories = params[fields.first!.key] as? [Int] {
                #if swift(>=4)
                    if selectedCategories.contains(Int(truncating: categoryId))
                    {
                    cell.tintColor = selectedColor
                    }
                #else
                    if selectedCategories.contains(Int(categoryId))
                    {
                        cell.tintColor = selectedColor
                    }
                #endif
            }
        }
        if canShowImage == true {
            if category.mediaId != nil && cell.imgView != nil{
                
                cell.imgView!.setImage(media: category.mediaId!, placeholderImage: nil, completed: { (image, error, cache, url) in
                    if image != nil {
                        cell.imgView!.image = image!.withRenderingMode(.alwaysTemplate)
                    }
                })
                cell.imgView?.tintColor = KTheme.current.color(.tint)
            }
        }else{
            cell.imgView?.removeFromSuperview()
        }
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var selectedCategories = params[fields.first!.key] as? [Int] ?? [Int]()
        let selectedCategory = categories![(indexPath as NSIndexPath).row]
        #if swift(>=4)
            let categoryId = Int(truncating: selectedCategory.numberValue!)
        #else
            let categoryId = Int(selectedCategory.numberValue!)
        #endif

        if let index = selectedCategories.index(where: {$0 == categoryId}) {
            selectedCategories.remove(at: index)
        }
        else {
            selectedCategories.append(categoryId)
        }

        params[fields.first!.key] = selectedCategories

        tableView.reloadRows(at: [indexPath], with: .automatic)

        containerViewController.isChanged = true
    }
    
}
