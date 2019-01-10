//
//  TaxonomyProtocol.swift
//  OrchardGen
//
//  Created by Patrick on 04/08/16.
//  Copyright © 2016 Dream Team. All rights reserved.
//

import Foundation

public protocol TaxonomyProtocol: KeyValueCodingProtocol
{
    var taxonomyPartTermTypeName: String? {get}
    var taxonomyPartAutoroutePartDisplayAlias: String? {get}
    var taxonomyPartTerms: NSOrderedSet? {get}
    var contentType: String? {get}
    var titlePartTitle: String? {get}
    var taxonomyPartIsInternal: NSNumber? {get}
    var taxonomyExtensionPartOrderBy: String? {get}
    var autoroutePartDisplayAlias: String? {get}
    var taxonomyPartName: String? {get}

    func firstLevelTerms() ->  [TermPartProtocol]
}

public extension TaxonomyProtocol {

    func firstLevelTerms() ->  [TermPartProtocol]
    {

        var terms = [TermPartProtocol]()
        if self.taxonomyPartTerms != nil {
            for loop in self.taxonomyPartTerms! {
                let term = loop as! TermPartProtocol

                let path = term.fullPath!.components(separatedBy: "/").filter({ (value: String) -> Bool in
                    return !value.isEmpty
                })
                if path.count < 2
                {
                    terms.append(term)
                }
            }
        }
        return terms
    }

}

