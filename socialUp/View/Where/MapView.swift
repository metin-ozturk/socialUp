//
//  MapView.swift
//  SocialUp
//
//  Created by Metin Öztürk
//  Copyright © 2019 Metin Ozturk. All rights reserved.
//

import UIKit
import MapKit

protocol MapViewDelegate : class {
    func newSearchResults()
    func updateLocationInfo(locationName: String?, locationDescription: String?,
                     locationLatitude : String?, locationLongitude: String?)
    func manageSearchBarInteractability(isInteractive: Bool)
}

extension MapViewDelegate {
    func newSearchResults() {}
    func updateLocationInfo(locationName: String?, locationDescription: String?,
                            locationLatitude : String?, locationLongitude: String?) {}
    func manageSearchBarInteractability(isInteractive: Bool) {}
}

enum LocationSelectionStatus {
    case notSelected
    case settingNameAndDescription
    case aboutToBeConfirmed
    case confirmed
}

class MapView : UIView {
    
    weak var delegate : MapViewDelegate?
    
    private let locationManager = CLLocationManager()
    var currentCoordinate : CLLocationCoordinate2D?
    
    var locationSelectionStatus : LocationSelectionStatus = .notSelected {
        didSet {
            switch (locationSelectionStatus) {
            case .notSelected:
                setConfirmInterfaceVisibility(showingConfirmInterface: false)
                mapKitView.isUserInteractionEnabled = true
            case .settingNameAndDescription:
                setConfirmInterfaceVisibility(showingConfirmInterface: false)
                mapKitView.isUserInteractionEnabled = false
            case .aboutToBeConfirmed:
                setConfirmInterfaceVisibility(showingConfirmInterface: true)
                mapKitView.isUserInteractionEnabled = false
            case .confirmed:
                setConfirmInterfaceVisibility(showingConfirmInterface: false)
                mapKitView.isUserInteractionEnabled = false
            }
            delegate?.manageSearchBarInteractability(isInteractive: mapKitView.isUserInteractionEnabled)
        }
    }
    
    private let reuseIdentifier = "MapKitAnnotation"
    
    @IBOutlet weak var mapKitView: MKMapView!
    
    @IBOutlet weak var addAnnotationDetail: AddAnnotationDetail!
    
    @IBOutlet weak var addAnnotationDetailBlurredBackground: UIVisualEffectView!
    
    
    @IBOutlet weak var confirmLocationButton: UIButton!
    @IBOutlet weak var cancelLocationButton: UIButton!
    @IBOutlet weak var confirmOrCancelLocationLabel: UILabel!
    
    private var longPressGesture : UILongPressGestureRecognizer!
    private var directionsArray = [MKDirections]()
    private var isShowingMapViewAtEventDetail = false
    
    var mapItemArray : [MKMapItem] = [] {
        didSet{
            delegate?.newSearchResults()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeNib()
        initializeMapView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeNib()
        initializeMapView()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func initializeMapView() {
        mapKitView.delegate = self
        mapKitView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: reuseIdentifier)
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        longPressGesture.minimumPressDuration = 1
        mapKitView.addGestureRecognizer(longPressGesture)
        
        addAnnotationDetailBlurredBackground.contentView.tag = ShadedBackgroundTag.allowsToDismissViewWhenTapped.rawValue
        
        configureLocationServices()
        
        addAnnotationDetail.delegateOfAddAnnotationDetail = self
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        
        switch touch!.view?.tag {
        case ShadedBackgroundTag.allowsToDismissViewWhenTapped.rawValue:
            displayOrHideViewsWithAnimation(views: [addAnnotationDetailBlurredBackground, addAnnotationDetail], display: false)
            // Remove the possible highlighted text in textfield
            addAnnotationDetail.annotationSubtitleTextField.resignFirstResponder()
            addAnnotationDetail.annotationTitleTextField.resignFirstResponder()
            
            locationSelectionStatus = .notSelected
        default:
            return
        }
    }

    
    @IBAction func confirmLocationButtonTapped(_ sender: UIButton) {
        locationSelectionStatus = .confirmed

        let annotation = currentCoordinate?.longitude == mapKitView.annotations[1].coordinate.longitude &&
            currentCoordinate?.latitude == mapKitView.annotations[1].coordinate.latitude ?
                mapKitView.annotations[0] : mapKitView.annotations[1]
        
        mapKitView.selectAnnotation(annotation, animated: true)
        
        let view = mapKitView.view(for: annotation) as! MKMarkerAnnotationView
        view.markerTintColor = UIColor(red: 0, green: 0.8, blue: 0, alpha: 0.8)
        
        let latitudeString = String(annotation.coordinate.latitude)
        let longitudeString = String(annotation.coordinate.longitude)
                
        
        delegate?.updateLocationInfo(locationName: annotation.title ?? "ERROR", locationDescription: annotation.subtitle ?? "ERROR", locationLatitude: latitudeString, locationLongitude: longitudeString)
    }
    
    @IBAction func cancelLocationButtonTapped(_ sender: UIButton) {
        locationSelectionStatus = .notSelected

        mapKitView.removeAnnotations(mapKitView.annotations)
    }
    
    func searchInMap(searchedText: String) {
        let latitudeRange = 0.2
        let longitudeRange = 0.2
        
        if searchedText.count == 0 {
            self.mapItemArray.removeAll()
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchedText
        
        request.region = MKCoordinateRegion(center: currentCoordinate!, latitudinalMeters: 10000, longitudinalMeters: 10000)
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let response = response else { return }
            
            self.mapItemArray.removeAll()
            var tempArray = [MKMapItem]()
            
            for item in response.mapItems {
                
                // Displays the results in range
                if abs(item.placemark.coordinate.latitude - self.currentCoordinate!.latitude) < latitudeRange && abs(item.placemark.coordinate.longitude - self.currentCoordinate!.longitude) < longitudeRange {
                    tempArray.append(item)
                }
            }
            self.mapItemArray.append(contentsOf: tempArray)
        })
    }
    

    
    private func configureLocationServices() {
        locationManager.delegate = self
        
        let locationAuthStatus = CLLocationManager.authorizationStatus()
        if  locationAuthStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if locationAuthStatus == .authorizedAlways || locationAuthStatus == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: locationManager)
        }
    }
    
    func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapKitView.setRegion(zoomRegion, animated: true)
    }
    
    private func beginLocationUpdates(locationManager: CLLocationManager) {
        mapKitView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapKitView)
        let coordinate = mapKitView.convert(location, toCoordinateFrom: mapKitView)
        
        addAnnotationDetail.annotationLatitudeValueLabel.text = String(coordinate.latitude)
        addAnnotationDetail.annotationLongitudeValueLabel.text = String(coordinate.longitude)
        
        self.displayOrHideViewsWithAnimation(views: [addAnnotationDetail,
        addAnnotationDetailBlurredBackground], display: true)
        
        locationSelectionStatus = .settingNameAndDescription
        
    }
    
    func setConfirmInterfaceVisibility(showingConfirmInterface: Bool) {
        confirmLocationButton.isHidden = !showingConfirmInterface
        cancelLocationButton.isHidden = !showingConfirmInterface
        confirmOrCancelLocationLabel.isHidden = !showingConfirmInterface
    }
    
    
    
}

extension MapView : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {return}
        
        if currentCoordinate == nil {
            zoomToLatestLocation(with: latestLocation.coordinate)
        }
        
        currentCoordinate = latestLocation.coordinate
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }
}

extension MapView : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation) as! MKMarkerAnnotationView
        annotationView.animatesWhenAdded = true
        annotationView.titleVisibility = .visible
        annotationView.subtitleVisibility = .visible
        
        if (annotation.coordinate.latitude == currentCoordinate?.latitude && annotation.coordinate.longitude == currentCoordinate?.longitude) || currentCoordinate == nil {
            annotationView.markerTintColor = UIColor(red: 0, green: 0.4, blue: 0.6, alpha: 0.8)
            annotationView.glyphImage = UIImage(named: "wavingMan")
        } else {
            annotationView.markerTintColor = UIColor(red: 0.8, green: 0, blue: 0.1, alpha: 0.8)
            annotationView.glyphImage = UIImage(named: "map")
        }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
    
}

extension MapView : AddAnnotationDetailDelegate {
    func addAnnotations(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        locationSelectionStatus = .aboutToBeConfirmed

        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = coordinate
        
        mapKitView.addAnnotation(annotation)
        
        zoomToLatestLocation(with: coordinate)
    }

    
    func onConfirmAnnotationInfo(title: String, subtitle: String, coordinates: CLLocationCoordinate2D) {

        addAnnotations(title: title, subtitle: subtitle, coordinate: coordinates)
        
        displayOrHideViewsWithAnimation(views: [addAnnotationDetailBlurredBackground, addAnnotationDetail], display: false)
    }
    
}

// MARK: - MapView At Event Detail and Getting Locations

extension MapView {
    func addAnnotationForEventDetail(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        isShowingMapViewAtEventDetail = true
        mapKitView.annotations.forEach { (annotation) in
            mapKitView.deselectAnnotation(annotation, animated: false)
            mapKitView.removeAnnotation(annotation)
        }
        
        longPressGesture.isEnabled = false
        
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = coordinate
        
        mapKitView.addAnnotation(annotation)
        mapKitView.selectAnnotation(annotation, animated: true)
        
        zoomToLatestLocation(with: coordinate)
        getDirections(to: coordinate)
        
        isShowingMapViewAtEventDetail = false
    }
    
    private func getDirections(to coordinate: CLLocationCoordinate2D) {
        guard let request = createDirectionsRequest(to: coordinate) else { return }
        let directions = MKDirections(request: request)
        
        resetMapView(withNew: directions)
        
        directions.calculate { (response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let response = response,
                let route = response.routes.first else { return }
            
            self.mapKitView.addOverlay(route.polyline)
            self.mapKitView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            
        }
    }
    
    private func createDirectionsRequest(to coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let startingLocationCoordinate = locationManager.location?.coordinate else { return nil }
        let destinationCoordinate = coordinate
        let startingLocation = MKPlacemark(coordinate: startingLocationCoordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
                
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    func resetMapView(withNew directions: MKDirections) {
        mapKitView.removeOverlays(mapKitView.overlays)
        directionsArray.forEach { (direction) in
            direction.cancel()
        }
        directionsArray.removeAll()
        directionsArray.append(directions)
    }
}



