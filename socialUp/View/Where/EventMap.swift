////
////  EventMapFragment.swift
////  socialUp
////
////  Created by Metin Öztürk on 29.11.2019.
////  Copyright © 2019 Metin Ozturk. All rights reserved.
////
//
//import UIKit
//import MapKit
//
//protocol EventMapDelegate : class {
//    func onLocationSelectionCompleted(locationName: String, locationDescription: String,
//                                     locationLatitude: String, locationLongitude: String)
//    func onLocationSelectionCanceled()
//}
//
//class EventMap: UIView {
//    weak var delegate : EventMapDelegate?
//    
//    var event : Event?
//    
//    private let mapView: MapView = {
//        let map = MapView(frame: .zero)
//        map.translatesAutoresizingMaskIntoConstraints = false
//        return map
//    }()
//
//    private let confirmLocationButton : UIButton = {
//        let button = UIButton(frame: .zero)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(named: "tick"), for: UIControl.State.normal)
//        button.addTarget(self, action: #selector(confirmLocationButtonTapped(_:)), for: UIControl.Event.touchUpInside)
//        return button
//    }()
//
//    private let cancelLocationButton : UIButton = {
//        let button = UIButton(frame: .zero)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(named: "cancel"), for: UIControl.State.normal)
//        button.addTarget(self, action: #selector(cancelLocationButtonTapped(_:)), for: UIControl.Event.touchUpInside)
//        return button
//    }()
//
//    private let confirmOrCancelLocationLabel : UILabel = {
//        let label = UILabel(frame: .zero)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Confirm Location?"
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 10)
//        label.backgroundColor = .clear
//        return label
//    }()
//
//
//    private let addAnnotationDetailShadedBackground : UIView = {
//        let view = UIView(frame: .zero)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = UIColor.lightGray
//        view.alpha = 0.8
//        view.tag = 2
//        return view
//    }()
//
//    private let addAnnotationDetail : AddAnnotationDetail = {
//        let view = AddAnnotationDetail(frame: .zero)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        translatesAutoresizingMaskIntoConstraints = false
//        mapView.delegateOfMapView = self
//        addAnnotationDetail.delegateOfAddAnnotationDetail = self
//        
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setMapKitView() {
//        addSubview(mapView)
//        NSLayoutConstraint.activate([
//            NSLayoutConstraint(item: mapView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: mapView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
//        ])
//    }
//    
//    private func setAddAnnotationDetailAndShadedBackground() {
//        
//        addSubview(addAnnotationDetailShadedBackground)
//        NSLayoutConstraint.activate([
//            NSLayoutConstraint(item: addAnnotationDetailShadedBackground, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: addAnnotationDetailShadedBackground, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: addAnnotationDetailShadedBackground, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: addAnnotationDetailShadedBackground, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
//        ])
//        
//        
//        addSubview(addAnnotationDetail)
//        NSLayoutConstraint.activate([
//            NSLayoutConstraint(item: addAnnotationDetail, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 0.1, constant: 0),
//            NSLayoutConstraint(item: addAnnotationDetail, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 0.9, constant: 0),
//            NSLayoutConstraint(item: addAnnotationDetail, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.2, constant: 0),
//            NSLayoutConstraint(item: addAnnotationDetail, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 0.9, constant: 0)
//        ])
//    }
//    
//    
//    private func setConfirmCancelLocation() {
//        addSubview(confirmOrCancelLocationLabel)
//        addSubview(confirmLocationButton)
//        addSubview(cancelLocationButton)
//        
//        
//        NSLayoutConstraint.activate([
//            NSLayoutConstraint(item: confirmOrCancelLocationLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
//            NSLayoutConstraint(item: confirmOrCancelLocationLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 30),
//            NSLayoutConstraint(item: confirmOrCancelLocationLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100),
//            NSLayoutConstraint(item: confirmOrCancelLocationLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
//        ])
//        
//        NSLayoutConstraint.activate([
//            NSLayoutConstraint(item: confirmLocationButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: -10),
//            NSLayoutConstraint(item: confirmLocationButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 40),
//            NSLayoutConstraint(item: confirmLocationButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20),
//            NSLayoutConstraint(item: confirmLocationButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
//        ])
//        
//        NSLayoutConstraint.activate([
//            NSLayoutConstraint(item: cancelLocationButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 10),
//            NSLayoutConstraint(item: cancelLocationButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 40),
//            NSLayoutConstraint(item: cancelLocationButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20),
//            NSLayoutConstraint(item: cancelLocationButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
//        ])
//        
//        confirmLocationButton.isHidden = true
//        confirmOrCancelLocationLabel.isHidden = true
//        cancelLocationButton.isHidden = true
//    }
//    
//    @objc private func confirmLocationButtonTapped(_ sender: UIButton) {
//        let annotation = mapView.currentCoordinate?.longitude == mapView.mapKitView.annotations[1].coordinate.longitude &&
//            mapView.currentCoordinate?.latitude == mapView.mapKitView.annotations[1].coordinate.latitude ?
//                mapView.mapKitView.annotations[0] : mapView.mapKitView.annotations[1]
//        mapView.mapKitView.selectAnnotation(annotation, animated: true)
//        
//        let view = mapView.mapKitView.view(for: annotation) as! MKMarkerAnnotationView
//        view.markerTintColor = UIColor(red: 0, green: 0.8, blue: 0, alpha: 0.8)
//        
//        confirmLocationButton.isHidden = true
//        cancelLocationButton.isHidden = true
//        confirmOrCancelLocationLabel.isHidden = true
//        
//        let latitudeString = String(annotation.coordinate.latitude)
//        let longitudeString = String(annotation.coordinate.longitude)
//        let annotationTitle = annotation.title as? String
//        let annotationSubtitle = annotation.subtitle as? String
//        
//        delegate?.onLocationSelectionCompleted(locationName: annotationTitle ?? "", locationDescription: annotationSubtitle ?? "", locationLatitude: latitudeString, locationLongitude : longitudeString)
//        
//    }
//    
//    @objc private func cancelLocationButtonTapped(_ sender: UIButton) {
//        mapView.mapKitView.removeAnnotations(mapView.mapKitView.annotations)
//        confirmLocationButton.isHidden = true
//        cancelLocationButton.isHidden = true
//        confirmOrCancelLocationLabel.isHidden = true
//        mapView.isUserInteractionEnabled = true
//        
//        delegate?.onLocationSelectionCanceled()
//    }
//}
//
//extension EventMap : MapViewDelegate {
//    func newSearchResults() {
//        if searchBarAtNavBar.text?.count == 0 {
//            rowHeightConstraint.constant = 0
//        }
//        else if mapView.mapItemArray.count > 6 {
//            rowHeightConstraint.constant = rowHeight * 6
//        } else {
//            rowHeightConstraint.constant = rowHeight * CGFloat(mapView.mapItemArray.count)
//        }
//        searchTableView.reloadData()
//    }
//    
//    func presentAddAnnotationPopUp(coordinate: CLLocationCoordinate2D) {
//        setAddAnnotationDetailAndShadedBackground()
//        addAnnotationDetail.annotationLatitudeTextField.text = String(coordinate.latitude)
//        addAnnotationDetail.annotationLongitudeTextField.text = String(coordinate.longitude)
//    }
//    
//}
//
//extension EventMap : AddAnnotationDetailDelegate {
//    
//    func removeAddAnnotationDetailAndShadedBackgroundFromSuperview() {
//        addAnnotationDetail.removeFromSuperview()
//        addAnnotationDetailShadedBackground.removeFromSuperview()
//    }
//    
//    func retrieveAnnotationInformation(title: String, subtitle: String, coordinates: CLLocationCoordinate2D) {
//        mapView.addAnnotations(title: title, subtitle: subtitle, coordinate: coordinates)
//        mapView.zoomToLatestLocation(with: coordinates)
//        
//        event.locationDescription = subtitle
//        event.locationName = title
//        event.locationLatitude = String(coordinates.latitude)
//        event.locationLongitude = String(coordinates.longitude)
//        
//        delegate?.updateEventInformation(withEvent: event)
//        
//        
//        confirmLocationButton.isHidden = false
//        cancelLocationButton.isHidden = false
//        confirmOrCancelLocationLabel.isHidden = false
//        mapView.isUserInteractionEnabled = false
//        searchBarAtNavBar.isUserInteractionEnabled = false
//        searchBarAtNavBar.text = ""
//    }
//    
//    
//}
