//
//  DropDownTextField.swift
//  OrchardCore
//
//  Created by Patrick on 26/01/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import UIKit
import LaserFloatingTextField


public protocol DropDownTextFieldDelegate: UITextFieldDelegate{
    func textField(_ textField: DropDownTextField, didSelectItems: [ContentTypeSelectionFieldItem])
}

open class DropDownTextField: EGFloatingTextField, UITableViewDelegate, UITableViewDataSource{
    weak var ddDelegate: DropDownTextFieldDelegate?
    var tableView: UITableView
    var isMultiSelection: Bool = false
    var required: Bool = false{
        didSet{
            canBeEmpty = !required
        }
    }
    var imageMode: PickerImageMode = PickerImageMode.none
    var itemList: [ContentTypeSelectionFieldItem]?{
        didSet{
            if itemList != nil {
                if itemList!.count > 0 {
                    tableView.reloadData()
                }
            }
        }
    }
    var mSelectedItems = [ContentTypeSelectionFieldItem]()

    init (){
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 200), style: .plain)
        super.init(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        setupTableView()
    }
    
    required public init(coder aDecoder: NSCoder) {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 200), style: .plain)
        super.init(coder: aDecoder)
        setupTableView()
    }
    
    func setupTableView() {

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        inputView = tableView
    }

    //MARK: - UIPickerView data source
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return itemList != nil ? itemList!.count : 0
    }
    
    //MARK: - UIPickerView delegate

    open func setSelectedItems(_ items: [ContentTypeSelectionFieldItem]){
        mSelectedItems = items

        if let items = itemList , items.count > 0 {

            tableView.reloadData()

            var string: String = ""

            for item in mSelectedItems {
                if !string.isEmpty {
                    string.append(", ")
                }
                string.append(item.name)
            }

            text = string
        }

    }

    private func indexPaths(ofSelectedItems selected: [ContentTypeSelectionFieldItem], inItems: [ContentTypeSelectionFieldItem]) -> [IndexPath]
    {
        var paths = [IndexPath]()

        for selectedItem in selected {
            for (index, item) in inItems.enumerated() {
                if item == selectedItem {
                    paths.append(IndexPath(row: index, section: 1))
                }
            }
        }

        return paths
    }
    
    //MARK: - UITableView Datasource & Delegate

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList != nil ? itemList!.count : 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = itemList![(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = item.name
        
        if imageMode != .none {
            if let mediaId = item.mediaId {
                let url = KMediaImageLoader.generateURL(forMediaPath: mediaId.stringValue, mediaImageOptions: KMediaImageLoadOptions(size: CGSize(width: 200,height: 200)))
                if let data = try? Data(contentsOf: url!){
                    let image = UIImage(data: data)
                    if imageMode == .tintedImage {
                        cell.imageView?.image = image?.imageTinted(KTheme.current.color(.tint))
                    }
                    else {
                        cell.imageView?.image = image
                    }
                }
            } else {
                cell.imageView?.image =  UIImage.image(UIColor.white, size: CGSize(width: 200,height: 200))
            }
        }
        
        if mSelectedItems.contains(where: { $0 == item }) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.selectedBackgroundView = UIView()
        cell.indentationLevel = item.level
        cell.indentationWidth = imageMode != .none ? 25 : 0

        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = itemList![(indexPath as NSIndexPath).row]
        if selectedItem.selectable {
            if !(isMultiSelection) {
                if(!mSelectedItems.contains(selectedItem) || required) {
                    setSelectedItems([selectedItem])
                }
                else {
                    setSelectedItems([])
                }
            }
            else {
                if let index = mSelectedItems.index(of: selectedItem){
                    if !(mSelectedItems.count == 1 && required){
                        mSelectedItems.remove(at: index)
                    }
                }
                else {
                    mSelectedItems.append(selectedItem)
                }
                setSelectedItems(mSelectedItems)
            }
            ddDelegate?.textField(self, didSelectItems: mSelectedItems)
        }
    }
}
