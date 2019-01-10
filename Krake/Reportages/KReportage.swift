//
//  KReportage.swift
//  Krake
//
//  Created by Marco Zanino on 26/05/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation

/**
 Main class to access reportage functionalities, like preparing the view controller
 for the list of report.
*/
open class KReportage {
    public static let GALLERY = "Gallery"
    public static let TITLE = "TitlePart.Title"
    public static let SUBTITLE = "Sottotitolo"
    public static let CATEGORY = "Categoria"
    public static let DESCRIPTION = "BodyPart.Text"
    public static let LOCATION = "MapPart.Latitude"

    /**
     Create a new KListMapViewController that will present the reports retrieved
     from Krake.

     - Parameters:
     - tabs: A list of tabs, each one defining the entry point of a list of report.
     This must not be empty, otherwise a fatalError will be thrown.
     - delegate: The delegate that will be notified by the KListReport about
     actions performed by the user.
     - showMap: True if the map should be visible, false otherwise.
     - contentStatus: A list of status used to visually represent the status of a report.
     - Returns: A new ready-to-use instance of KListMapViewController.
     */
    public static func reportViewController(_ tabs: [TabBarItem],
                                          delegate: KListReportDelegate? = nil,
                                          showMap: Bool = false,
                                          contentStatus: [ContentStatus] =
        [ContentStatus(keyPath: "Created",
                       title: "Created".localizedString(),
                       textColor: #colorLiteral(red: 0.9213396256, green: 0.4393665225, blue: 0.007960174915, alpha: 1),
                       backgroundColor: #colorLiteral(red: 0.9213396256, green: 0.4393665225, blue: 0.007960174915, alpha: 1)),
         ContentStatus(keyPath: "Loaded",
                       title: "Loaded".localizedString(),
                       textColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),
                       backgroundColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)),
         ContentStatus(keyPath: "Accepted",
                       title: "Accepted".localizedString(),
                       textColor: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1),
                       backgroundColor: #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)),
         ContentStatus(keyPath: "Rejected",
                       title: "Rejected".localizedString(),
                       textColor: #colorLiteral(red: 0.8724222716, green: 0, blue: 0.008167404037, alpha: 1),
                       backgroundColor: #colorLiteral(red: 0.8724222716, green: 0, blue: 0.008167404037, alpha: 1))]) -> UIViewController {
        // Checking that the list of tab isn't empty.
        guard !tabs.isEmpty else {
            fatalError("You must specify at least one tab element.")
        }
        // Preparing the delegate of the list view controller.
        let listReportDelegate = KListReport(reportStatuses: contentStatus)
        listReportDelegate.delegate = delegate
        // Preparing the list view controller.
        let dataOptions = KListMapData(endPoint: tabs.first?.endPoint)
        var options = KListMapOptions(data: dataOptions)
        options.tabManagerOptions = KTabManagerOptions(tabs: tabs)
        options.listMapDelegate = listReportDelegate
        options.mapOptions = .default
        options.searchFilterOptions = KSearchFilterOptions(filterableKeys: ["titlePartTitle", "sottotitoloValue", "bodyPartText"])
        let vc = KListMapViewController(listMapOptions: options)
        // Storing a reference to the list view controller inside the delegate.
        listReportDelegate.listVC = vc
        return vc
    }
}
