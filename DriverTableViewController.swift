//
//  DriverTableViewController.swift
//  Uber
//
//  Created by Mohab Mohamed's on 8/1/19.
//  Copyright © 2019 mohabmohamed. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit



class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var rideRequests : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            
            if let requestDictionary = snapshot.value as? [String:AnyObject]{
                if let latdriver = requestDictionary["driverlat"] as? Double {
                    
                }else{
                    self.rideRequests.append(snapshot)
                    self.tableView.reloadData()
                }
                
            }
          
            
        }
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }

        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinates = manager.location?.coordinate {
            driverLocation = coordinates
        }
    }

    // MARK: - Table view data source

  
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rideRequests.count
    }
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
        
        
    }
    
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)

        // Configure the cell...
        let snapshot = rideRequests[indexPath.row]
        
        if let requestDictionary = snapshot.value as? [String:AnyObject]{
            
            if let email = requestDictionary["email"] as? String {
                
                
                if let lat = requestDictionary["lat"] as? Double {
                    if let long = requestDictionary["lon"] as? Double{
                        
                        
                        let driverCLoc = CLLocation(latitude: driverLocation.latitude , longitude: driverLocation.longitude)
                        
                        let riderCLoc = CLLocation(latitude: lat , longitude: long)
                        
                        let distance = driverCLoc.distance(from: riderCLoc) / 1000
                        
                        let roundedDistance = round(distance * 100 ) / 100
                        
                        
                        
                        
                        cell.textLabel?.text = "\(email) - \(roundedDistance)KM away."
                        
                        
                    }
                }
                
            
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let snapshot = rideRequests[indexPath.row]
        
        performSegue(withIdentifier: "acceptRequestSegue", sender: snapshot)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let requestVC = segue.destination as? RequestViewController{
            
            if let snapshot = sender as? DataSnapshot {
                
                if let requestDictionary = snapshot.value as? [String:AnyObject]{
                    
                    if let email = requestDictionary["email"] as? String {
                        
                        
                        if let lat = requestDictionary["lat"] as? Double {
                            if let long = requestDictionary["lon"] as? Double{
                                requestVC.emailRequest = email
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                requestVC.locationRequest = location
                                requestVC.locationDriver = driverLocation
                                
                            }
                        }
                    }
                }
                
            }
        }
    }

}
