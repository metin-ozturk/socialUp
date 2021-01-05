import UIKit
import MapKit

class WhereVC: UIViewController, CreateEventProtocol {

    var event = Event()
    
    private let titleHeight : CGFloat = 80
    private let upperMargin : CGFloat = 20
    
    private let rowHeight : CGFloat = 50
    
    @IBOutlet private weak var pageTitleLabel: UILabel!
    
    @IBOutlet private weak var searchBar: UISearchBar!
    
    @IBOutlet private weak var mapView: MapView!
    @IBOutlet private weak var searchTableView: UITableView!
    @IBOutlet private weak var searchTableViewRowHeightConstraint: NSLayoutConstraint!
    
    private let reuseIdentifier = "SearchLocationTableView"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        mapView.delegate = self
        searchBar.delegate = self
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set Favorite (Or Past) Event's Annotation
        if event.locationLongitude != nil && event.locationLatitude != nil
        && event.locationSelectionStatus == .aboutToBeConfirmed {
            
            if mapView.mapKitView.annotations.count > 1 {
                let annotation = mapView.currentCoordinate?.longitude == mapView.mapKitView.annotations[1].coordinate.longitude &&
                    mapView.currentCoordinate?.latitude == mapView.mapKitView.annotations[1].coordinate.latitude ?
                        mapView.mapKitView.annotations[0] : mapView.mapKitView.annotations[1]
                
                // Clear previously created annotations if they exist and deselect them.
                
                mapView.mapKitView.deselectAnnotation(annotation, animated: false)
                mapView.mapKitView.removeAnnotation(annotation)
                
                
            }
            
            let lat = Double(event.locationLatitude!)!
            let long = Double(event.locationLongitude!)!
            
            mapView.addAnnotations(title: event.locationName!, subtitle: event.locationDescription!, coordinate: CLLocationCoordinate2D(latitude: lat , longitude: long ))
            
            event.locationName = nil
            event.locationDescription = nil
            event.locationLatitude = nil
            event.locationLongitude = nil
            event.locationAddress = nil
            
            searchBar.isUserInteractionEnabled = false
            searchBar.text = ""

        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let touch = touches.first
        
        switch touch!.view?.tag {
        case mapView.tag:
            searchBar.resignFirstResponder()
        default:
            return
        }
    }

}

extension WhereVC : MapViewDelegate {
    func manageSearchBarInteractability(isInteractive: Bool) {
        searchBar.isUserInteractionEnabled = isInteractive
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    
    func updateLocationInfo(locationName: String?, locationDescription: String?, locationLatitude: String?, locationLongitude: String?) {
        event.locationName = locationName
        event.locationDescription = locationDescription
        event.locationLatitude = locationLatitude
        event.locationLongitude = locationLongitude
        event.locationSelectionStatus = mapView.locationSelectionStatus
    }
    

    func newSearchResults() {
        if searchBar.text?.count == 0 {
            searchTableViewRowHeightConstraint.constant = 0
        }
        else if mapView.mapItemArray.count > 6 {
            searchTableViewRowHeightConstraint.constant = rowHeight * 6
        } else {
            searchTableViewRowHeightConstraint.constant = rowHeight * CGFloat(mapView.mapItemArray.count)
        }
        searchTableView.reloadData()
    }
    
    
}

extension WhereVC : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        mapView.searchInMap(searchedText: searchText)
    }
    
}


extension WhereVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text?.count == 0 {
            return 0
        }
        return mapView.mapItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }
        
        let mapItem = mapView.mapItemArray[indexPath.row] as MKMapItem
        
        cell?.textLabel?.text = mapItem.placemark.name
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell?.textLabel?.textColor = .darkGray
        
        cell?.detailTextLabel?.text = mapItem.placemark.title
        if let textCount = cell?.detailTextLabel?.text?.count, textCount >= 100 {
            cell?.detailTextLabel?.text = String((cell?.detailTextLabel?.text?.prefix(100))!) + "..."
        }
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 8)
        cell?.detailTextLabel?.numberOfLines = 0
        cell?.detailTextLabel?.lineBreakMode = .byWordWrapping
        
        cell?.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mapItem = mapView.mapItemArray[indexPath.row]
        
        mapView.addAnnotations(title: mapItem.placemark.name ?? "", subtitle: mapItem.placemark.title ?? "", coordinate: mapItem.placemark.coordinate)
        mapView.mapItemArray.removeAll()
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
}

    
