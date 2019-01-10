//
//  Swift42.swift
//  Krake
//
//  Created by Patrick on 20/09/18.
//  Copyright © 2018 Laser Group srl. All rights reserved.
//

import Foundation
import MapKit

#if swift(>=4.2)

public typealias KMapPointForCoordinate = MKMapPoint
public typealias KLayoutConstraintAxis = NSLayoutConstraint.Axis
public typealias KViewContentMode = UIView.ContentMode
public typealias KLayoutFormatOptions = NSLayoutConstraint.FormatOptions
public typealias KLayoutAttribute = NSLayoutConstraint.Attribute
public typealias KLayoutRelation = NSLayoutConstraint.Relation
public typealias KAttributedStringKey = NSAttributedString.Key
public typealias KApplicationOpenURLOptionsKey = UIApplication.OpenURLOptionsKey
public typealias KControlState = UIControl.State
public typealias KControlEvent = UIControl.Event
public typealias KWindowLevel = UIWindow.Level
public typealias KBarButtonItemStyle = UIBarButtonItem.Style
public typealias KBarButtonSystemStyle = UIBarButtonItem.SystemItem
public typealias KFontTextStyle = UIFont.TextStyle
public typealias KWebViewNavigationType = UIWebView.NavigationType
public typealias KApplicationState = UIApplication.State
public typealias KApplicationLaunchOptionsKey = UIApplication.LaunchOptionsKey
public typealias KAnnotationViewDragState = MKAnnotationView.DragState
public typealias KGestureRecognizerState = UIGestureRecognizer.State
public typealias KImageRenderingMode = UIImage.RenderingMode
public typealias KLocalSearchRequest = MKLocalSearch.Request
public typealias KPageViewControllerNavigationDirection = UIPageViewController.NavigationDirection
public typealias KSwipeGestureRecognizerDirection = UISwipeGestureRecognizer.Direction
public typealias KViewAnimationOptions = UIView.AnimationOptions

public let KMapRectNull = MKMapRect.null
@available(iOS 10.0, *)
public let KCollectionViewFlowLayoutAutomaticSize = UICollectionViewFlowLayout.automaticSize
public let KWindowLevelStatusBar = UIWindow.Level.statusBar
public let KKeyboardDidShowNotification = UIResponder.keyboardDidShowNotification
public let KKeyboardDidHideNotification = UIResponder.keyboardDidHideNotification
public let KKeyboardFrameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
public let KApplicationWillResignActive = UIApplication.willResignActiveNotification
public let KApplicationWillEnterForeground = UIApplication.willEnterForegroundNotification
public let KApplicationDidEnterBackground = UIApplication.didEnterBackgroundNotification
public let KTableViewAutomaticDimension = UITableView.automaticDimension
public let KLayoutFittingCompressedSize = UIView.layoutFittingCompressedSize
public let KImagePickerControllerReferenceURL = UIImagePickerController.InfoKey.referenceURL
public let KAccessibilityIsReduceTransparencyEnabled = UIAccessibility.isReduceTransparencyEnabled
public let KBackgroundTaskInvalid = UIBackgroundTaskIdentifier.invalid

#else

public func KMapPointForCoordinate(_ coordinate: CLLocationCoordinate2D) -> MKMapPoint
{
return MKMapPointForCoordinate(coordinate)
}
public typealias KLayoutConstraintAxis = UILayoutConstraintAxis
public typealias KViewContentMode = UIViewContentMode
public typealias KLayoutFormatOptions = NSLayoutFormatOptions
public typealias KLayoutAttribute = NSLayoutAttribute
public typealias KLayoutRelation = NSLayoutRelation
public typealias KAttributedStringKey = NSAttributedStringKey
public typealias KApplicationOpenURLOptionsKey = UIApplicationOpenURLOptionsKey
public typealias KControlState = UIControlState
public typealias KControlEvent = UIControlEvents
public typealias KWindowLevel = UIWindowLevel
public typealias KBarButtonItemStyle = UIBarButtonItemStyle
public typealias KBarButtonSystemStyle = UIBarButtonSystemItem
public typealias KFontTextStyle = UIFontTextStyle
public typealias KWebViewNavigationType = UIWebViewNavigationType
public typealias KApplicationState = UIApplicationState
public typealias KApplicationLaunchOptionsKey = UIApplicationLaunchOptionsKey
public typealias KAnnotationViewDragState = MKAnnotationViewDragState
public typealias KGestureRecognizerState = UIGestureRecognizerState
public typealias KImageRenderingMode = UIImageRenderingMode
public typealias KLocalSearchRequest = MKLocalSearchRequest
public typealias KPageViewControllerNavigationDirection = UIPageViewControllerNavigationDirection
public typealias KSwipeGestureRecognizerDirection = UISwipeGestureRecognizerDirection
public typealias KViewAnimationOptions = UIViewAnimationOptions

public let KMapRectNull = MKMapRectNull
@available(iOS 10.0, *)
public let KCollectionViewFlowLayoutAutomaticSize = UICollectionViewFlowLayoutAutomaticSize
public let KWindowLevelStatusBar = UIWindowLevelStatusBar
public let KKeyboardDidShowNotification = NSNotification.Name.UIKeyboardDidShow
public let KKeyboardDidHideNotification = NSNotification.Name.UIKeyboardDidHide
public let KKeyboardFrameEndUserInfoKey = UIKeyboardFrameEndUserInfoKey
public let KApplicationWillResignActive = NSNotification.Name.UIApplicationWillResignActive
public let KApplicationWillEnterForeground = NSNotification.Name.UIApplicationWillEnterForeground
public let KApplicationDidEnterBackground = NSNotification.Name.UIApplicationDidEnterBackground
public let KTableViewAutomaticDimension = UITableViewAutomaticDimension
public let KLayoutFittingCompressedSize = UILayoutFittingCompressedSize
public let KImagePickerControllerReferenceURL = UIImagePickerControllerReferenceURL
public let KAccessibilityIsReduceTransparencyEnabled = UIAccessibilityIsReduceTransparencyEnabled()
public let KBackgroundTaskInvalid = UIBackgroundTaskInvalid

#endif
