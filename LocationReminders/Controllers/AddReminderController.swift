//
//  AddReminderController.swift
//  LocationReminders
//
//  Created by curtis scott on 12/09/2019.
//  Copyright © 2019 CurtisScott. All rights reserved.
//

import UIKit
import MapKit

protocol AddReminderDelegate:class {
    func addGeotificationViewController(
        _ controller: AddReminderController, coordinate: CLLocationCoordinate2D,
        radius: Double, identifier: String, note: String, eventType: LocationNotifacation.EventType, address:String)
}

class AddReminderController: UITableViewController {

    @IBOutlet weak var enteringLeavingControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var userReminderTextField: UITextView!
    @IBOutlet weak var addLocationButton: UIButton!
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil 
    
    weak var addReminderDelegate :AddReminderDelegate?
    
    
    @IBOutlet weak var locationTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setUpSerchBar()
        mapView.zoomToUserLocation()

    }
    
    
    @IBAction func cancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveReminder(_ sender: Any) {
       
        guard let placemark = selectedPin else {
            print("no placeamrk")
            showAlert(withTitle: "not location", message: "please search for a location before trying to save a note ")
            return
        }
        let coordinate = placemark.coordinate
        let radius :Double = 50
        let identifier = NSUUID().uuidString
        let note = userReminderTextField.text!
        let eventType: LocationNotifacation.EventType = (enteringLeavingControl.selectedSegmentIndex == 0) ? .onEntry : .onExit
        let address = AddressFormatter.parseAddress(selectedItem: placemark)
        if let delegate = addReminderDelegate {
            delegate.addGeotificationViewController(self, coordinate: coordinate, radius: radius, identifier: identifier, note: note, eventType: eventType, address: address)
        } else {
            print("no delegate")
        }
        
    }
    
    func setUpSerchBar(){
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "test") as! LocationResultsController
        
        locationSearchTable.mapView = mapView
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        locationSearchTable.handleMapSearchDelegate = self
        
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
    }
    
    
}

extension AddReminderController: HandleMapSearch{
    
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        
        print("\(placemark.coordinate.latitude) \(placemark.coordinate.longitude)")
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        self.locationTextLabel.text = "\(placemark.name ?? "cannot") \(placemark.locality ?? "cannot vain info")"
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
            
            
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
}
    
    
    



