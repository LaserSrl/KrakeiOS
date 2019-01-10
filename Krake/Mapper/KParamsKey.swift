//
//  KrakeParamsKey.swift
//  Krake
//
//  Created by Patrick on 30/08/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation

@objc open class KParamsKey: NSObject
{
    /// is "Language"
    public static let language = "Language"
    public static let produzione = "Produzione"
    public static let token = "Token"
    public static let UUID = "UUID"
    public static let device = "Device"
    public static let contentId = "ContentId"
    public static let sendTo = "SendTo"
    public static let sendFrom = "SendFrom"
    public static let messageText = "MessageText"
    public static let senderName = "SenderName"
    public static let recipeName = "RecipeName"
    public static let signalName = "SignalName"
    public static let fromLatitude = "FromLatitude"
    public static let fromLongitude = "FromLongitude"
    public static let point = "Point"
    public static let award = "Award"
    public static let fromNameLocation = "FromNameLocation"
    public static let attachment = "Attachment"
    public static let attachmentName = "AttachmentName"
    public static let additionalData = "AdditionalData"
    /// is "\_\_provider\_\_"
    public static let provider = "__provider__"
    public static let createPersistentCookie = "createPersistentCookie"
    
    @objc public static let terms = "TermIds"
    @objc public static let displayAlias = "displayAlias"
    @objc public static let lang = "lang"
    @objc public static let page = "page"
    @objc public static let pageSize = "pageSize"
    @objc public static let itemsFieldsFilter = "mfilter"
    @objc public static let resultTarget = "resultTarget"
    @objc public static let showPrivacy = "showPrivacy"
    @objc public static let realFormat = "realformat"
    @objc public static let complexBehaviour = "complexbehaviour"
    @objc public static let noCache = "no-cache"
    @objc public static let deepLevel = "deepLevel"
    @objc public static let dateStart = "dataInizio"
    @objc public static let dateEnd = "dataFine"
    @objc public static let aroundMeLatitude = "lat"
    @objc public static let aroundMeLongitude = "lng"
    @objc public static let aroundMeRadius = "dist"
}
