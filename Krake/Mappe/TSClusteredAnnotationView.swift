//
//  TSClusteredAnnotationView.swift
//  OrchardCore
//
//  Created by Patrick on 04/02/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import Cluster
import MapKit

open class KClusterAnnotationView: ClusterAnnotationView {

    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {

        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func configure() {
        super.configure()
        guard let annotation = annotation as? ClusterAnnotation else { return }
        countLabel.text = numberLabelText(annotation.annotations.count )
    }

    func numberLabelText(_ count: Int) -> String?{
        if count == 0{
            return nil
        }else{
            var rounded: Float = 0.0
            if count < 10{
                image = UIImage(krakeNamed: "small-cluster")
            }else if count < 100 {
                image = UIImage(krakeNamed: "medium-cluster")
            }else{
                image = UIImage(krakeNamed: "bigCluster")
            }
            frame = CGRect(origin: CGPoint.zero, size: CGSize( width: image!.size.width, height: image!.size.height))
            centerOffset = CGPoint.zero
            
            if count < 1000{
                return String(format: "%lu", count)
            }else if (count < 10000) {
                rounded = ceilf(Float(count)/100)/10
                return String(format: "%.1fk", rounded)
            }
            else {
                rounded = roundf(Float(count)/1000)
                return String(format: "%luk", rounded)
            }
        }
    }
    
}

