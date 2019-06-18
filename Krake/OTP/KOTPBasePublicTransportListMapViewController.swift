//
//  KOTPBasePublicTransportListMapViewController.swift
//  Krake
//
//  Created by Marco Zanino on 12/04/2017.
//  Copyright © 2017 Laser Group srl. All rights reserved.
//

import UIKit
import MapKit

open class KOTPBasePublicTransportListMapViewController<EntityType>: UIViewController, KExtendedMapViewDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet internal weak var mapView: KExtendedMapView!
    @IBOutlet internal weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    @IBOutlet internal weak var tableViewTopIndicator: UIView!
    @IBOutlet internal weak var tableViewContainer: UIView!
    @IBOutlet internal weak var tableViewContainerTop: NSLayoutConstraint?
    @IBOutlet internal weak var tableViewPanGestureRecognizer: UIPanGestureRecognizer!

    public var items: [EntityType]?

    internal lazy var minimumTableViewContainerHeight: CGFloat = 0
    internal let tableViewCellIdentifier = "cell"
    internal var isTableViewPanningDisabled: Bool = false
    internal var minimumTableViewTopDistanceFromParent: CGFloat = 0

    private weak var tableViewContainerHiddenConstraint: NSLayoutConstraint?
    private var lastVerticalTranslationValue: CGFloat = 0.0

    // MARK: - View controller lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mapView.delegate = self
        
        // Applico le impostazioni alla table view di modo che le celle definiscano
        // da sole la loro altezza.
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = KTableViewAutomaticDimension
        // Customizzo l'indicatore della table view.
        tableViewTopIndicator.backgroundColor = .lightGray
        tableViewTopIndicator.layer.cornerRadius = 2.0
        tableViewTopIndicator.clipsToBounds = true
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(
            alongsideTransition: { (_) in
                if UIDevice.current.userInterfaceIdiom == .pad || size.height > size.width {
                    self.prepareTableViewForFirstUsage(using: self.items, animated: true)
                }
        },
            completion: nil)
    }

    // MARK: - Table view visibility

    internal func prepareTableViewForFirstUsage(using items: [Any]?, animated isAnimated: Bool) {
        if (items?.isEmpty ?? true) {
            self.hideTableView(animated: isAnimated)
        } else {
            self.resetTableViewVisibility(animated: isAnimated)
        }
    }

    internal func hideTableView(animated isAnimated: Bool) {
        guard let tableViewContainerTop = tableViewContainerTop, !isTableViewPanningDisabled && tableView.bounds.height != 0 else {
            return
        }

        UIView.animate(withDuration: isAnimated ? 0.2 : 0.0) {
            tableViewContainerTop.constant = self.view.bounds.height
            let tableViewHiddenConstraint = self.tableViewContainer.heightAnchor.constraint(equalToConstant: 0)
            self.tableViewContainer.addConstraint(tableViewHiddenConstraint)
            self.view.layoutIfNeeded()
            self.tableViewContainerHiddenConstraint = tableViewHiddenConstraint
        }
    }

    internal func resetTableViewVisibility(animated isAnimated: Bool, force: Bool = false) {
        guard let tableViewContainerTop = tableViewContainerTop, !isTableViewPanningDisabled else { return }
        // Verifico che non vi sia il constraint per la table view nascosta.
        if let tableViewContainerHiddenConstraint = tableViewContainerHiddenConstraint {
            tableViewContainer.removeConstraint(tableViewContainerHiddenConstraint)
        }
        var calculatedMinumum : CGFloat = 24.0 + tableView.estimatedRowHeight
        if #available(iOS 11.0, *) {
            calculatedMinumum = calculatedMinumum + self.view.safeAreaInsets.bottom
        }

        minimumTableViewContainerHeight = max(minimumTableViewContainerHeight, calculatedMinumum)

        let initialHeightValue =
            items?.isEmpty ?? true ? 0 : minimumTableViewContainerHeight

        if tableViewContainer.bounds.height < initialHeightValue || (force && tableViewContainer.bounds.height != initialHeightValue) {
            let newContainerTopConstant =
                view.bounds.height - topLayoutGuide.length - initialHeightValue
            UIView.animate(withDuration: isAnimated ? 0.2 : 0.0) {
                tableViewContainerTop.constant = newContainerTopConstant
                self.view.layoutIfNeeded()
            }
        }
    }

    //MARK: - KExtendedMapViewDelegate

    open func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            mapView.showAnnotations([annotation], animated: true)
        }
    }

    open func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let view =
            mapView.dequeueReusableAnnotationViewWithAnnotation(annotation) ?? KAnnotationView(annotation: annotation)
        view.canShowCallout = true
        view.addNavigationButton()
        return view
    }

    open func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if !(view.annotation is UserSelectedPoint) &&
            control.tag == KAnnotationView.CalloutNavigationButtonTag
        {
            KExtendedMapView.defaultOpenAnnotation?(view.annotation, self)
        }
    }

    open func extendedMapView(_ mapView: KExtendedMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl, fromViewController: UIViewController) -> Bool {
        return true
    }

    // MARK: - Table view data source & delegate

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifier, for: indexPath)
        // Verifico se questa è la prima cella, in tal caso sarà quella che
        // determinerà l'altezza minima della table view.
        if indexPath.row == 0 {
            // Calcolo la height della cella appena creata e l'altezza minima
            // che dovrebbe avere il container della table view sulla base di
            // tale cella.
            let autoLayoutSize = cell.systemLayoutSizeFitting(KLayoutFittingCompressedSize)
            let desiredMinimumTableViewContainerHeight = autoLayoutSize.height + 24.0
            // Verifico se l'altezza minima debba essere aggiornata.
            if minimumTableViewContainerHeight < desiredMinimumTableViewContainerHeight {
                // Aggiorno l'altezza minima del container della table view.
                minimumTableViewContainerHeight = desiredMinimumTableViewContainerHeight
                // Aggiorno l'altezza della table view di modo che la prima
                // cella sia visibile.
                resetTableViewVisibility(animated: true)
            }
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    // MARK: - Table view panning

    @IBAction func userPannedTableView(_ sender: UIPanGestureRecognizer) {
        guard !isTableViewPanningDisabled else { return }

        switch sender.state {
        case .changed:
            // Calcolo il delta della traslazione. Un delta positivo indicherebbe
            // che la table view si sta allontanando dal punto d'origine del padre, uno
            // negativo che si sta avvicinando.
            let verticalTranslation =
                sender.translation(in: sender.view?.superview).y
            let verticalTranslationDelta =
                verticalTranslation - lastVerticalTranslationValue
            let velocity = abs(sender.velocity(in: sender.view?.superview).y)
            lastVerticalTranslationValue = verticalTranslation

            translateTableView(by: verticalTranslationDelta,
                               at: velocity)
        case .ended:
            let verticalTranslation =
                sender.translation(in: sender.view?.superview).y
            let velocity = sender.velocity(in: sender.view?.superview).y

            finishTableViewTranslation(verticalTranslation, at: velocity)
            lastVerticalTranslationValue = 0
        default:
            lastVerticalTranslationValue = 0
        }
    }

    private func translateTableView(by verticalTranslation: CGFloat, at velocity: CGFloat) {
        guard let tableViewContainerTop = tableViewContainerTop, verticalTranslation != 0 else {
            return
        }
        // Calcolo la durata dell'animazione basandomi sullo spostamento e la
        // velocità della traslazione.
        var animationDuration = 0.0
        // Calcolo il valore finale della costante del constraint per il top
        // del contenitore della table view.
        let tableViewContainerTopConstant: CGFloat
        // Verifico la direzione della traslazione. Un valore positivo indicherebbe
        // che la table view si sta allontanando dal punto d'origine del padre, uno
        // negativo che si sta avvicinando.
        if verticalTranslation > 0 {
            // Verifico che il contenuto della scroll view sia a zero prima
            // di procedere con il resize.
            if tableView.contentOffset.y == 0 {
                if velocity >= UIScreen.main.bounds.height * 2 {
                    tableViewContainerTopConstant =
                        tableViewContainerTop.constant +
                        tableViewContainer.bounds.height - minimumTableViewContainerHeight

                    animationDuration = 0.25
                } else {
                    // Verifico che l'altezza minima della table view sia rispettata
                    // prima di procedere con il resize tramite il valore di traslazione.
                    if tableViewContainer.bounds.height - verticalTranslation > minimumTableViewContainerHeight {
                        tableViewContainerTopConstant =
                            tableViewContainerTop.constant + verticalTranslation
                    } else {
                        tableViewContainerTopConstant =
                            tableViewContainerTop.constant +
                            tableViewContainer.bounds.height - minimumTableViewContainerHeight
                    }
                }
            } else {
                tableViewContainerTopConstant = minimumTableViewTopDistanceFromParent
            }
        } else {
            if velocity >= UIScreen.main.bounds.height * 2 {
                tableViewContainerTopConstant = minimumTableViewTopDistanceFromParent
                animationDuration = 0.25
            } else {
                tableViewContainerTopConstant =
                    max(tableViewContainerTop.constant + verticalTranslation, minimumTableViewTopDistanceFromParent)
            }
        }

        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            options: [ .curveEaseOut ],
            animations: {
                tableViewContainerTop.constant = tableViewContainerTopConstant

                if animationDuration != 0.0 {
                    self.view.layoutIfNeeded()
                }
        },
            completion: { (_) in
                if tableViewContainerTopConstant == self.minimumTableViewTopDistanceFromParent &&
                    self.tableView.contentSize.height > self.tableView.bounds.height {

                    self.tableView.isScrollEnabled = true
                }
        })
    }

    private func finishTableViewTranslation(_ translation: CGFloat, at velocity: CGFloat) {
        // Calcolo la durata dell'animazione basandomi sullo spostamento e la
        // velocità della traslazione.
        let animationDuration = velocity != 0 ? Double(translation / velocity) : 0.0
        let tableViewContainerFrame = tableViewContainerAvailableFrame()
        let tableViewContainerVerticalMiddle = tableViewContainerFrame.midY
        let tableViewContainerTopConstant: CGFloat
        if tableViewContainer.frame.origin.y > tableViewContainerVerticalMiddle {
            NSLog("Top %f", tableViewContainerTop!.constant)
            NSLog("bounds %f", tableViewContainer.bounds.height)
            NSLog("Min %f", minimumTableViewContainerHeight)

            tableViewContainerTopConstant =
                tableViewContainerTop!.constant +
                tableViewContainer.bounds.height - minimumTableViewContainerHeight

            NSLog("Tot %f", tableViewContainerTopConstant)
        } else {
            tableViewContainerTopConstant = minimumTableViewTopDistanceFromParent
        }
        UIView.animate(
            withDuration: min(animationDuration, 0.25),
            delay: 0.0,
            options: [ .curveEaseOut ],
            animations: {
                self.tableViewContainerTop!.constant = tableViewContainerTopConstant

                if animationDuration != 0.0 {
                    self.view.layoutIfNeeded()
                }
        },
            completion: { (_) in
                if tableViewContainerTopConstant == self.minimumTableViewTopDistanceFromParent &&
                    self.tableView.contentSize.height > self.tableView.bounds.height {

                    self.tableView.isScrollEnabled = true
                }
        })
    }

    internal func tableViewContainerAvailableFrame() -> CGRect {
        fatalError("You must implement this method in your subclass.")
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isTableViewPanningDisabled else {
            return
        }

        let newContentY = scrollView.contentOffset.y
        // Verifico l'avanzamento dello scroll da parte dell'utente.
        if newContentY <= 0 {
            // Disabilito lo scroll della table view.
            scrollView.isScrollEnabled = false
        }
    }
    
}
