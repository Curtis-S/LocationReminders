//
//  MasterViewController.swift
//  LocationReminders
//
//  Created by curtis scott on 12/09/2019.
//  Copyright © 2019 CurtisScott. All rights reserved.
//

import UIKit
import MapKit

class LocationNotesController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var locationReminders = [LocationNotifacation]()
    
    var locationManager = CLLocationManager()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        loadAllGeotifications()
       
        
  
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = locationReminders[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
        if segue.identifier == "addReminder" {
            let controller = segue.destination as! UINavigationController
                let addReminderVc = controller.topViewController as! AddReminderController
            addReminderVc.addReminderDelegate = self
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationReminders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = locationReminders[indexPath.row]
        cell.textLabel?.text = object.note
        cell.detailTextLabel?.text = object.address
        return cell
    }


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let reminder = locationReminders.remove(at: indexPath.row)
            remove(reminder)
            print("removed reminder")
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    



}

extension LocationNotesController {
    
    
    func add(_ geotification: LocationNotifacation) {
        locationReminders.append(geotification)
    
        NotificationsCount()
    }
    
    func remove(_ geotification: LocationNotifacation) {
        stopMonitoring(geotification: geotification)
        NotificationsCount()
        saveAllGeotifications()
        
        loadAllGeotifications()
        
    }
    
    func NotificationsCount() {
// cannot monitor more then 20 regions
        navigationItem.rightBarButtonItem?.isEnabled = (locationReminders.count < 20)
    }
    
    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        locationReminders.removeAll()
        let Notifications = LocationNotifacation.allNotifications()
        Notifications.forEach { add($0) }
        
        print(Notifications)
    
    }
    
    func saveAllGeotifications() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(locationReminders)
            UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems)
        } catch {
            print("error encoding geotifications")
        }
    }
    
    
    func region(with locationNotification: LocationNotifacation) -> CLCircularRegion {
        // 1
        let region = CLCircularRegion(center: locationNotification.coordinate,
                                      radius: locationNotification.radius,
                                      identifier: locationNotification.identifier)
        // 2
        region.notifyOnEntry = (locationNotification.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    func startMonitoring(geotification: LocationNotifacation) {
        // 1
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
       showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            let message = """
      Your geotification is saved but will only be activated once you grant
      Geotify permission to access the device location.
      """
           showAlert(withTitle:"Warning", message: message)
        }
        // 3
     
        let fenceRegion = region(with: geotification)
        // 4
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    
    
    func stopMonitoring(geotification: LocationNotifacation) {
        for region in locationManager.monitoredRegions {
                print(region)
          
            guard let circularRegion = region as? CLCircularRegion,
                circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    func removeAllRegions(){
        for region in locationManager.monitoredRegions {
            print(region)
            locationManager.stopMonitoring(for: region)
        }
        
        for region in locationManager.monitoredRegions {
            print(region)
            locationManager.stopMonitoring(for: region)
        }
    }
    
}


extension LocationNotesController: AddReminderDelegate {
    
    
    func addGeotificationViewController(_ controller: AddReminderController, coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: LocationNotifacation.EventType, address: String) {
        controller.dismiss(animated: true, completion: nil)
        
        // 1
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geotification = LocationNotifacation(coordinate: coordinate, radius: clampedRadius,
                                          identifier: identifier, note: note, eventType: eventType,address:address)
         add(geotification)
        // 2
        startMonitoring(geotification: geotification)
        saveAllGeotifications()
        self.tableView.reloadData()
    }
    
    
    
    
}

extension LocationNotesController:CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    
}

