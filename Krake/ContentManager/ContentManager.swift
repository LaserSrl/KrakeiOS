//
//  ContentManager.swift
//  Krake
//
//  Created by Patrick on 08/07/15.
//  Copyright (c) 2015 Laser Group. All rights reserved.
//

import UIKit
import MBProgressHUD

public struct ContentManagerKeys {
    public static let GALLERY = "Gallery"
    public static let CONTENT_TYPE = "ContentType"
    public static let STATUS = "PublishExtensionStatus"
    public static let LANGUAGE = "Language"
    public static let TITLE = "TitlePart.Title"
    public static let SUBTITLE = "Sottotitolo"
    public static let CATEGORY = "Categoria"
    public static let DESCRIPTION = "BodyPart.Text"
    public static let MAPPART = "MapPart"
    public static let LATITUDE = "Latitude"
    public static let LONGITUDE = "Longitude"
    public static let USERPOLICYPART = "UserPolicyPart.UserPolicyAnswers"
}

public struct ContentTypeDefinition{
    
    var viewControllers: [ContentModificationViewController]!
    var contentType: String
    var customParams: [String: Any]? = nil
    
    public init (contentType _contentType: String,
                             viewControllers _viewControllers: [ContentModificationViewController] ,
                                             customParams _customParams: [String: Any]? = nil
        ){
        assert(_viewControllers.count > 0, "Devi inserire almeno un controller")
        viewControllers = _viewControllers
        contentType = _contentType
        customParams = _customParams
    }
}

open class ContentTypeSelectionField{
    
    var key: String
    var values: [ContentTypeSelectionEnumOrTerm]
    var settings: ContentTypeSelectionFieldSettings
    
    public init(keyPath: String!, object: [String : AnyObject]){
        key = keyPath
        values = [ContentTypeSelectionEnumOrTerm]()
        for obj in (object["Values"] as! [[String : AnyObject]]){
            values.append(ContentTypeSelectionEnumOrTerm(object: obj, atLevel: 0))
        }
        settings = ContentTypeSelectionFieldSettings(object: (object["Setting"] as! [String : AnyObject]))
    }
}

public struct ContentTypeSelectionFieldSettings{
    
    var required: Bool
    var imageVisible: Bool
    var selectionType: SelectionType
    
    public init(object: [String : AnyObject]!){
        imageVisible = (object["Type"] as! String).lowercased() == "taxonomie" ? true : false
        if object["SingleChoice"] == nil {
            selectionType = .single
        }else{
            selectionType = object["SingleChoice"] as! Bool == true ? .single : .multiple
        }
        required = object["Required"] as! Bool
    }
}

@objc public class ContentTypeSelectionFieldItem: NSObject {

    public var name: String = ""

    func  referenceValue() -> Any? {return nil}

    public var level: Int = 0

    public var selectable: Bool = true

    public var mediaId: NSNumber? = nil

    public static func ==(lhs: ContentTypeSelectionFieldItem, rhs: ContentTypeSelectionFieldItem) -> Bool {
        if let sLhs = lhs.referenceValue() as? NSNumber, let sRhs = rhs.referenceValue()  as? NSNumber {
            return sLhs == sRhs
        }
        else if let nLhs = lhs.referenceValue()  as? String, let nRhs = rhs.referenceValue()  as? String {
            return nLhs == nRhs
        }

        return false
    }

    public func hasAny(ofValues values: [Any]) -> Bool
    {
        for value in values {
            if has(value: value)
            {
                return true
            }
        }

        return false
    }

    private func has(value: Any) -> Bool
    {
        if let sValue = value as? String, let sMValue = referenceValue() as? String {
            return sMValue == sValue
        }
        else if let nValue = value as? NSNumber, let sMValue = referenceValue() as? NSNumber  {
            return sMValue == nValue
        }
        return false
    }
}

extension ContentTypeSelectionFieldItem {

    public func isEqual(to rhs:ContentTypeSelectionFieldItem) -> Bool
    {
        if let sLhs = self.referenceValue() as? NSNumber, let sRhs = rhs.referenceValue()  as? NSNumber {
            return sLhs == sRhs
        }
        else if let nLhs = self.referenceValue()  as? String, let nRhs = rhs.referenceValue()  as? String {
            return nLhs == nRhs
        }
        return false
    }
}


@objc public class ContentTypeSelectionEnumOrTerm : ContentTypeSelectionFieldItem {

    var stringValue: String? = nil
    var numberValue: NSNumber? = nil
    var children: [ContentTypeSelectionEnumOrTerm]? = nil
    
    public init(object: [String : AnyObject], atLevel: Int){
        super.init()
        name = object["Name"] as! String
        if object["Value"] is NSNull{
            selectable = false
        }else{
            selectable = true
        }
        level = atLevel
        mediaId = object["ImageId"] as? NSNumber
        let value = object["Value"]

        if let sValue = value as? String {
            stringValue = sValue
            numberValue = nil
        }
        else if let nValue  = value as? NSNumber {
            stringValue = nil
            numberValue = nValue
        }
        else {
            stringValue = nil
            numberValue = nil
        }

        if object["Children"] != nil {
            children = [ContentTypeSelectionEnumOrTerm]()
            for obj in (object["Children"] as! [[String : AnyObject]]){
                children?.append(ContentTypeSelectionEnumOrTerm(object: obj, atLevel: atLevel + 1))
            }
        }
        else {
            children = nil
        }
    }

    init(title: String, stringValue: String, level: Int = 0, mediaId: NSNumber? = nil, selectable: Bool = true) {
         super.init()
        self.name = title
        self.stringValue = stringValue
        self.mediaId = mediaId
        self.level = level
        self.selectable = selectable
        numberValue = nil
        children = nil
    }

    init(title: String, numberValue: NSNumber, level: Int = 0, mediaId: NSNumber? = nil, selectable: Bool = true) {
         super.init()
        self.name = title
        self.numberValue = numberValue
        self.mediaId = mediaId
        self.level = level
        self.selectable = selectable
        stringValue = nil
        children = nil
    }
/*
    public static func ==(lhs: ContentTypeSelectionEnumOrTerm, rhs: ContentTypeSelectionEnumOrTerm) -> Bool {
        if let sLhs = lhs.stringValue, let sRhs = rhs.stringValue  {
            return sLhs == sRhs
        }
        else if let nLhs = lhs.numberValue, let nRhs = rhs.numberValue  {
            return nLhs == nRhs
        }
        
        return false
    }
*/
    override public func  referenceValue() -> Any? {
        if stringValue != nil {
            return stringValue
        }
        else {
            return numberValue
        }
    }
}

public class ContentTypeSelectionContentItem: ContentTypeSelectionFieldItem
{
    private let contentItem: ContentItem

    init(contentItem ci: ContentItem) {
        contentItem = ci
        super.init()
        name = ci.titlePartTitle ?? ""
        mediaId = ((ci as? ContentItemWithGallery)?.galleryMediaParts?.firstObject as? MediaPartProtocol)?.identifier

    }

    override public func referenceValue() -> Any? {
        if contentItem.identifier != nil {
            return contentItem.identifier
        }

        return (contentItem as? ManagedMappedContentItem)?.stringIdentifier
    }
}

public enum SelectionType: Int{
    case single
    case multiple
}

//MARK: - ContentModificationViewController

open class ContentModificationViewController: UIViewController{
    
    open var fields: [FieldItem]!
    open var params : NSMutableDictionary! = NSMutableDictionary()
    open var contentTypeSelectionFields: [ContentTypeSelectionField]? = nil
    open weak var parentParentViewController: UIViewController!
    open weak var containerViewController: ContentModificationContainerViewController!
    
    open func reloadAllDataFromParams(){
        KLog(type: .warning, "manca l'implementazione del metodo reloadAllDataFromParams del ViewController. I fields presenti nel view controller non verranno aggiornati.")
    }
    
    open func setInitialData(_ item: AnyObject){
        KLog(type: .warning, "manca l'implementazione del metodo setInitialData del ViewController. I fields presenti nel view controller non verranno inizializzati.")
    }
}
