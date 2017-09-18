//
//  ViewController.swift
//  MultipleLocationRoutes
//
//  Created by Invision on 18/09/2017.
//  Copyright © 2017 Invision. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import CoreLocation

struct Location {
    
    
    var lat = 0.0
    var lng = 0.0
    var name = ""
}

public let map_key = "AIzaSyAkWdc5coLNIHLaP7hZHT7MzdL62f6a8yI"

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var mapView: GMSMapView!
 
    
    
    let karachi = Location(lat: 24.8615, lng: 67.0099 , name : "karachi")
    let multan = Location(lat: 30.1984, lng: 71.4687 , name : "multan")
    let islamabad = Location(lat: 33.7294, lng: 73.0931 , name : "islamabad")
    var totalRoute =  [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalRoute.append(karachi)
        totalRoute.append(multan)
        totalRoute.append(islamabad)
        
        totalRoute.sort(by: sortingDistance)
        
        
        let camera = GMSCameraPosition.camera(withLatitude: karachi.lat, longitude: karachi.lng, zoom: 6)
        
        mapView.camera =  camera
        
        addMarkersToDestinations()
        
        generateTrip()
        
        
    }
    
    private func addMarkersToDestinations(){
        
        for route in totalRoute{
            
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: route.lat, longitude: route.lng)
            marker.title = route.name
            marker.map = mapView
        }
        
    }
    
    func drawPath(currentLocation : Location , destinationLoc : Location)
    {
        _ = "\(currentLocation.lat),\(currentLocation.lng)"
        _ = "\(destinationLoc.lat),\(destinationLoc.lng)"
        
        
        //        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(map_key)"
        //
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLocation.name)&destination=\(destinationLoc.name)&mode=driving&key=\(map_key)"
        
        
        Alamofire.request(url).responseJSON { response in
       
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            print(json)
            
            self.mapView.isMyLocationEnabled = true
            let routeOverviewPolyline = routes[0]["overview_polyline"].dictionary
            let points = routeOverviewPolyline?["points"]?.stringValue
            let path = GMSMutablePath(fromEncodedPath: points!)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5.0
            polyline.map = self.mapView
            
        }
    }
    

    func distanceBetweenTwoLocations(src:Location,dest:Location) -> Double{
        
        let source : CLLocation = CLLocation(latitude: src.lat , longitude: src.lng)
        let destination : CLLocation = CLLocation(latitude: dest.lat, longitude: dest.lng)
        let distanceMeters = source.distance(from: destination)
        let distanceKM = distanceMeters / 1000
        let roundedTwoDigit = distanceKM.rounded()
        return roundedTwoDigit
        
    }
    
    func sortingDistance(dist1 : Location , dist2 : Location)->Bool{
        
        return distanceBetweenTwoLocations(src: karachi, dest:dist1 ) < distanceBetweenTwoLocations(src: karachi, dest:dist2 )
        
    }
    
    private func generateTrip(){
        
        for i in 0..<totalRoute.count-1{
            
            drawPath(currentLocation: totalRoute[i], destinationLoc: totalRoute[i+1])
            
        }
        
    }
    
}


