//
//  RiderViewController.swift
//  Uber
//
//  Created by Mohab Mohamed's on 7/31/19.
//  Copyright © 2019 mohabmohamed. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callUberButton: UIButton!
    
    var locationManager = CLLocationManager()
    var driverOnHisWay = false
    var riderLocation = CLLocationCoordinate2D()
    
    var driverLocation = CLLocationCoordinate2D()
    
    var requestMade = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let userEmail = Auth.auth().currentUser?.email{
            
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: userEmail).observe(.childAdded) { (snapshot) in
                self.requestMade = true
                self.callUberButton.setTitle("Cancel your request", for: .normal)
                Database.database().reference().child("RideRequests").removeAllObservers()
                
                if let rideRequestDictionary = snapshot.value as? [String:AnyObject]{
                    if let driverLat = rideRequestDictionary["driverlat"] as? Double {
                        if let driverLong = rideRequestDictionary["driverlong"] as? Double{
                            
                        self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLong)
                        self.driverOnHisWay = true
                        self.displayRiderAndDriver()
                            if let email = Auth.auth().currentUser?.email{
                                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged) { (snapshot) in
                                    if let rideRequestDictionary = snapshot.value as? [String:AnyObject]{
                                        if let driverLat = rideRequestDictionary["driverlat"] as? Double {
                                            if let driverLong = rideRequestDictionary["driverlong"] as? Double{
                                                
                                                self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLong)
                                                self.driverOnHisWay = true
                                                self.displayRiderAndDriver()
                                                
                                            }
                                        }
                                    }
                                }
                            }
                            
                    }
                    }
                }
                    
            }
            
        }
        
        
    }
    
    func displayRiderAndDriver(){
        
        let driverCLLocation = CLLocation(latitude:driverLocation.latitude, longitude: driverLocation.longitude)
        
        let riderCLLocation = CLLocation(latitude:riderLocation.latitude, longitude: riderLocation.longitude)
        
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        
        let roundedDistance = round(distance * 100 ) / 100
        
        callUberButton.setTitle("Your Uber Driver is \(roundedDistance)KM away.", for: .normal)
        map.removeAnnotations(map.annotations)
        
        
        let latDelta = abs(driverLocation.latitude - riderLocation.latitude) * 2 + 0.005
        let longDelta = abs(driverLocation.longitude - riderLocation.longitude) * 2 + 0.005
        
        let region = MKCoordinateRegion(center: riderLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta))
        
        map.setRegion(region, animated: true)
        
        let riderAnnot = MKPointAnnotation()
        riderAnnot.coordinate = riderLocation
        riderAnnot.title = "Your Location"
        map.addAnnotation(riderAnnot)
        
        let driverAnnot = MKPointAnnotation()
        driverAnnot.coordinate = driverLocation
        driverAnnot.title = "Your Driver's Location"
        map.addAnnotation(driverAnnot)
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = manager.location?.coordinate {
            
            let locate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            let riderRegion = MKCoordinateRegion(center: locate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            riderLocation = locate
            
            if requestMade {
                displayRiderAndDriver()
             
            }else{
                map.setRegion(riderRegion, animated: true)
                map.removeAnnotations(map.annotations)
                
                let riderMarker = MKPointAnnotation()
                riderMarker.coordinate = locate
                riderMarker.title = "Your Location"
                map.addAnnotation(riderMarker)
            }
            
           
        }
    }
    
    @IBAction func callUberPressed(_ sender: Any) {
        if !driverOnHisWay{
        if let userEmail = Auth.auth().currentUser?.email{
        
            if requestMade {
                
                requestMade = false
                
                callUberButton.setTitle("Call Uber", for: .normal)
                
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: userEmail).observe(.childAdded) { (snapshot) in
                snapshot.ref.removeValue()
                Database.database().reference().child("RideRequests").removeAllObservers()
                }
                
                
                
            }else{
                
                let requestDictionary : [String : Any] = ["email": userEmail , "lat" : riderLocation.latitude , "lon" : riderLocation.longitude]
                
                Database.database().reference().child("RideRequests").childByAutoId().setValue(requestDictionary)
                
                requestMade = true
                
                callUberButton.setTitle("Cancel your request", for: .normal)
                
            }
            
       
            }
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
}
