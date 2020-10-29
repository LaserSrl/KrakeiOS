//
//  KTripPlannerResultsDisplayer.swift
//  Krake
//
//  Created by joel on 11/05/17.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit

public protocol ResultTableDisplayer: UITableViewDelegate, UITableViewDataSource
{
    var searchController: KTripPlannerSearchController! {get set}
}

open class SingleTripModeDatasource : NSObject, ResultTableDisplayer
{
    public var searchController: KTripPlannerSearchController!
    public var complexStep : KStepGroup

    private let distanceFormatter: MKDistanceFormatter
    private let durationFormatter: KDurationFormatter

    public init(with complexStep: KStepGroup) {
        distanceFormatter = MKDistanceFormatter()
        durationFormatter = KDurationFormatter()
        self.complexStep = complexStep

    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }

        return complexStep.steps.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "SingleModeHeader", for: indexPath) as! SingleModeHeaderCell

            cell.distanceLabel.text = String(format: "(%@)",distanceFormatter.string(fromDistance: CLLocationDistance(complexStep.distance)))
            KTripTheme.shared.applyTheme(toLabel: cell.distanceLabel, type: .distance)
            cell.distanceLabel.font = KTripTheme.shared.fontFor(text: .distance)
            cell.distanceLabel.textColor = KTripTheme.shared.colorFor(text: .distance)
            cell.timeLabel.text = durationFormatter.string(from: complexStep.duration)
            KTripTheme.shared.applyTheme(toLabel: cell.distanceLabel, type: .mainInfo)

            return cell
        }
        else {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "SingleModeStep", for: indexPath) as! SingleModeStepCell

            let step = complexStep.steps[indexPath.row]

            cell.distanceLabel.text = distanceFormatter.string(fromDistance: CLLocationDistance(step.distance))
            KTripTheme.shared.applyTheme(toLabel: cell.distanceLabel, type: .distance)
            cell.instructionLabel.attributedText = step.instruction
            cell.instructionImage.image = KTripTheme.shared.imageFor(maneuver: step.maneuver)

            return cell
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0)
        {
            searchController.updateUIState(.allVisible)
        }
        else
        {
            searchController.zoomMap(onStep: complexStep.steps[indexPath.row])
        }
    }
}

open class TransitsDatasource: NSObject, UITableViewDataSource, ResultTableDisplayer
{
    public var searchController: KTripPlannerSearchController!
    let distanceFormatter: MKDistanceFormatter
    let durationFormatter: KDurationFormatter
    let timeFormatter: DateFormatter
    let dateAndTimeFormatter: DateFormatter

    public let routes : [KRoute]
    public init(with routes : [KRoute]) {
        self.routes = routes

        distanceFormatter = MKDistanceFormatter()
        durationFormatter = KDurationFormatter()
        dateAndTimeFormatter = DateFormatter()
        dateAndTimeFormatter.timeStyle = .short
        dateAndTimeFormatter.dateStyle = .short

        timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransitHeader", for: indexPath) as! TransitHeaderCell

        let route = routes[indexPath.row]
        cell.durationLabel.text = durationFormatter.string(from: route.duration)

        let transits = route.steps.filter({return $0 is KTransitStep}) as! [KTransitStep]

        let formattedStartDate : String
        if route.startTime.isToday()
        {
            formattedStartDate = timeFormatter.string(from: route.startTime)
        }
        else
        {
            formattedStartDate = dateAndTimeFormatter.string(from: route.startTime)
        }
        cell.dateLabel.text = String(format: "%@ - %@", formattedStartDate, timeFormatter.string(from: route.endTime))
        
        KTripTheme.shared.applyTheme(toLabel: cell.dateLabel, type: .date)
        KTripTheme.shared.applyTheme(toLabel: cell.durationLabel, type: .distance)

        for child in cell.partsStackView.subviews {
            cell.partsStackView.removeArrangedSubview(child)
            child.removeFromSuperview()
        }

        if transits.count > 0 {
        for transit in transits {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            let name = UILabel()

            imageView.addConstraint(NSLayoutConstraint(item: imageView,
                                                       attribute: .height,
                                                       relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                                       multiplier: 1, constant: 25))

            imageView.addConstraint(NSLayoutConstraint(item: imageView,
                                                       attribute: .height,
                                                       relatedBy: .equal, toItem: imageView, attribute: .width,
                                                       multiplier: 1, constant: 0))

            name.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[name(>=18)]", options: .alignAllCenterX, metrics: nil, views: ["name":name]))
            name.textAlignment = .center
            name.text = transit.line.shortName

            if let icon = transit.line.lineIcon {
                imageView.setImage(media: icon, placeholderImage: KTripTheme.shared.imageFor(vehicleType: transit.vehicle))
            }
            else {
                imageView.image = KTripTheme.shared.imageFor(vehicleType: transit.vehicle)
            }
            imageView.setContentHuggingPriority(UILayoutPriority.priority(1000.0), for: .horizontal)

            name.setContentHuggingPriority(UILayoutPriority.priority(1000.0), for: .horizontal)

            if(cell.partsStackView.arrangedSubviews.count > 0)
            {
                let label = UILabel()
                label.text = " > "
                label.font = UIFont.boldSystemFont(ofSize: 12)
                label.setContentHuggingPriority(UILayoutPriority.priority(1000.0), for: .horizontal)
                cell.partsStackView.addArrangedSubview(label)
            }
            KTripTheme.shared.applyTheme(toLabel: name, type: .instruction)
            if let color = transit.line.color {
                name.backgroundColor = color

                name.textColor = color.constrastTextColor()
            }

            cell.partsStackView.addArrangedSubview(imageView)
            cell.partsStackView.addArrangedSubview(name)
        }
        }else if let transit = route.steps.first as? KStepGroup{
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            let name = UILabel()
            imageView.addConstraint(NSLayoutConstraint(item: imageView,
                                                       attribute: .height,
                                                       relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                                       multiplier: 1, constant: 25))
            
            imageView.addConstraint(NSLayoutConstraint(item: imageView,
                                                       attribute: .height,
                                                       relatedBy: .equal, toItem: imageView, attribute: .width,
                                                       multiplier: 1, constant: 0))
            name.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[name(>=18)]", options: .alignAllCenterX, metrics: nil, views: ["name":name]))
            name.textAlignment = .center
            name.text = transit.instruction.string
            imageView.image = KTripTheme.shared.imageFor(travelMode: transit.travelMode)
            imageView.setContentHuggingPriority(UILayoutPriority.priority(1000.0), for: .horizontal)
            name.setContentHuggingPriority(UILayoutPriority.priority(1000.0), for: .horizontal)
            cell.partsStackView.addArrangedSubview(imageView)
            cell.partsStackView.addArrangedSubview(name)
        }

        let view = UIView()
        view.setContentHuggingPriority(UILayoutPriority.priority(990.0), for: .horizontal)
        cell.partsStackView.addArrangedSubview(view)

        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.showPlannedTrip(searchController.plannedTrip!,mode: .showSingleTransitWithBackNavigation, index: indexPath)
    }
}

open class SingleTransitDatasource: TransitsDatasource
{
    let route : KRoute

    public init(with route: KRoute) {
        self.route = route
        super.init(with: [route])
    }

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return route.steps.count
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section > 0 {
            if let stepGroup = route.steps[indexPath.row] as? KStepGroup {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TransitGroupStep", for: indexPath) as! SingleModeStepCell

                KTripTheme.shared.applyTheme(toLabel: cell.distanceLabel, type: .distance)
                KTripTheme.shared.applyTheme(toLabel: cell.instructionLabel, type: .instruction)

                cell.distanceLabel.text = distanceFormatter.string(fromDistance: CLLocationDistance(stepGroup.distance))
                cell.instructionImage.image = KTripTheme.shared.imageFor(travelMode: stepGroup.travelMode)
                cell.instructionLabel.text = KOTPLocalization.localizable("TravelMode.\(stepGroup.travelMode.rawValue.lowercased())")
                return cell
            }
            else if let transit = route.steps[indexPath.row] as? KTransitStep {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TransitCell", for: indexPath) as! TransitCell

                KTripTheme.shared.applyTheme(toLabel: cell.startLabel, type: .date)
                KTripTheme.shared.applyTheme(toLabel: cell.endLabel, type: .date)

                cell.startLabel.text = timeFormatter.string(from: transit.startTime)
                cell.endLabel.text = timeFormatter.string(from: transit.endTime)

                cell.startOfLine.text = transit.from.name
                cell.endOfLine.text = transit.to.name
                cell.headsign.text = transit.headsign
                cell.lineName.text = transit.line.shortName
                KTripTheme.shared.applyTheme(toLabel: cell.startOfLine, type: .instruction)
                KTripTheme.shared.applyTheme(toLabel: cell.endOfLine, type: .instruction)
                KTripTheme.shared.applyTheme(toLabel: cell.headsign, type: .instruction)
                KTripTheme.shared.applyTheme(toLabel: cell.lineName, type: .instruction)
                if let color = transit.line.color {
                    cell.lineName.backgroundColor = color

                    cell.lineName.textColor = color.constrastTextColor()
                }

                if let icon = transit.line.lineIcon {
                    cell.lineIcon.setImage(media: icon, placeholderImage: KTripTheme.shared.imageFor(vehicleType: transit.vehicle))
                }
                else {
                    cell.lineIcon.image = KTripTheme.shared.imageFor(vehicleType: transit.vehicle)
                }
                
                return cell
            }
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 0)
        {
            searchController.updateUIState(.allVisible)
        }
        else {
            searchController.zoomMap(onComplexStep: route.steps[indexPath.row])
        }
    }
}
