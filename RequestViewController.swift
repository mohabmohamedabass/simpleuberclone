//
//  RequestViewController.swift
//  Uber
//
//  Created by Mohab Mohamed's on 8/2/19.
//  Copyright © 2019 mohabmohamed. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class RequestViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    var locationRequest = CLLocationCoordinate2D()
    var locationDriver = CLLocationCoordinate2D()
    var emailRequest = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let region = MKCoordinateRegion(center: locationRequest, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationRequest
        annotation.title = emailRequest
        map.addAnnotation(annotation)
    }
    

    @IBAction func acceptButton(_ sender: Any) {
        
        // update the request
        
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: emailRequest).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverlat":self.locationDriver.latitude, "driverlong":self.locationDriver.longitude])
            Database.database().reference().child("RideRequests").removeAllObservers()
        }
        
        
        // get directions to request
        
        let requestCLLocation = CLLocation(latitude: locationRequest.latitude, longitude: locationRequest.longitude)
        
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    let mapitem = MKMapItem(placemark: placemark)
                    mapitem.name = self.emailRequest
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapitem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    
}
