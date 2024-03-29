//
//  TestTableTableViewController.swift
//  LocationReminders
//
//  Created by curtis scott on 14/09/2019.
//  Copyright © 2019 CurtisScott. All rights reserved.
//

import UIKit
import MapKit



class LocationResultsController: UITableViewController {

    var handleMapSearchDelegate:HandleMapSearch? = nil
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       return matchingItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
   
        cell.detailTextLabel?.text = AddressFormatter.parseAddress(selectedItem: selectedItem)
        
        return cell
    }
    
    
}

extension LocationResultsController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    
}

extension LocationResultsController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate!.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}
