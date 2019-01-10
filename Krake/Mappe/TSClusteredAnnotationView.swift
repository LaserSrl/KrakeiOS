//
//  TSClusteredAnnotationView.swift
//  OrchardCore
//
//  Created by Patrick on 04/02/16.
//  Copyright © 2016 Laser Group srl. All rights reserved.
//

import Foundation
import TSClusterMapView

open class TSClusteredAnnotationView: TSRefreshedAnnotationView {
    
    var label: UILabel! = UILabel(frame: CGRect(origin: CGPoint.zero , size: CGSize(width:10,height:10)))
        
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = UIImage(krakeNamed: "bigCluster")
        frame = CGRect(origin: CGPoint.zero, size: CGSize( width:  image!.size.width, height: image!.size.height))
        label.frame = frame
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textColor = UIColor.white
        label.center = CGPoint(x: image!.size.width/2, y: image!.size.height/2)
        centerOffset = CGPoint.zero
        addSubview(label)
        canShowCallout = true
        
        if let clusterAnnotation = annotation as? ADClusterAnnotation{
            let count = clusterAnnotation.clusterCount
            label.text = numberLabelText(count)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var annotation: MKAnnotation?{
        didSet{
            if annotation != nil {
                if let clusterAnnotation = annotation as? ADClusterAnnotation{
                    let count = clusterAnnotation.clusterCount
                    label.text = numberLabelText(count)
                }
            }
        }
    }
    
    func numberLabelText(_ count: UInt?) -> String?{
        if count ?? 0 == 0{
            return nil
        }else{
            var rounded: Float = 0.0
            if count! < 10{
                image = UIImage(krakeNamed: "small-cluster")
            }else if count! < 100 {
                image = UIImage(krakeNamed: "medium-cluster")
            }else{
                image = UIImage(krakeNamed: "bigCluster")
            }
            frame = CGRect(origin: CGPoint.zero, size: CGSize( width: image!.size.width, height: image!.size.height))
            label.frame = frame
            label.center = CGPoint(x:image!.size.width/2,y: image!.size.height/2);
            centerOffset = CGPoint.zero
            
            if count! < 1000{
                return String(format: "%lu", count!)
            }else if (count! < 10000) {
                rounded = ceilf(Float(count!)/100)/10
                return String(format: "%.1fk", rounded)
            }
            else {
                rounded = roundf(Float(count!)/1000)
                return String(format: "%luk", rounded)
            }
        }
    }
    
}

