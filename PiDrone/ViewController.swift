  //
//  ViewController.swift
//  PiDrone
//
//  Created by Andrew Ke on 4/7/15.
//  Copyright (c) 2015 Andrew Ke. All rights reserved.
//
//Ryan Chen
//Test
import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var GPSLabel: UILabel!
    @IBOutlet weak var cameraShutterButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var connectionLabel: UIButton!
    @IBOutlet weak var dataTextField: UITextView!
    @IBOutlet weak var serverSpeedLabel: UILabel!
    @IBOutlet weak var armingButton: UIButton!
    @IBOutlet weak var flightModeLabel: UIButton!
    @IBOutlet weak var modePickerView: UIView!
    @IBOutlet weak var videoStreamer: UIWebView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var safeModeLabel: UILabel!
    @IBOutlet weak var homeButton: UIButton!
    
    var model:WebModel = WebModel()
    var droneMarker = MKPointAnnotation()
    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        roundView(self.GPSLabel)
        roundView(self.cameraShutterButton)
        roundView(self.videoButton)
        roundView(connectionLabel)
        roundView(dataTextField)
        roundView(serverSpeedLabel)
        roundView(armingButton)
        roundView(homeButton)
        
        var url = NSURL (string: "https://news.google.com/")
        if(model.safe == false){
            self.safeModeLabel.hidden = true
            url = NSURL (string: "http://\(model.ipadress):8080/stream_simple.html")
        }
        let requestObj = NSURLRequest(URL: url!)
        //self.videoStreamer.scrollView.setZoomScale(2.0, animated: false)
        videoStreamer.loadRequest(requestObj);
        
        let location = CLLocationCoordinate2D(
            latitude: model.lat,
            longitude: model.long
        )
        // 2
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        droneMarker = MKPointAnnotation()
        droneMarker.coordinate = CLLocationCoordinate2DMake(model.lat, model.long)
        droneMarker.title = "drone"
        mapView.addAnnotation(droneMarker)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        println("HELLO!")
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView.canShowCallout = true
        }
        else {
            anView.annotation = annotation
        }
        
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        if(annotation.title! == "drone"){
            println("changing!")
            anView.image = UIImage(named:"miniquad.png")
        }else{
            //user dot
            return nil
        }
        
        return anView
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        //println("Hello!")
        //mapView.setCenterCoordinate(userLocation.coordinate, animated: true);
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView!, fullyRendered: Bool) {
        println("Done!")
    }
    
    @IBAction func centerAtHome() {
        if(model.GPS == "FIX" || model.safe == true){
            mapView.setCenterCoordinate(mapView.userLocation.location.coordinate, animated: true)
        }else{
            println("NO GPS, can't center on location")
        }
    }
    
    
    @IBAction func switchDisplay(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            self.videoStreamer.hidden = false
            self.mapView.hidden = true
        case 1:
            self.videoStreamer.hidden = true
            self.mapView.hidden = false
        default:
            fatalError("Invalid Selection")
        }
    }
    
    func roundView(view:UIView){
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
    }
    
    func update() {
        model.update()
        self.dataTextField.text = "Altitude: \(model.altitude) m \n Speed: \(model.speed) m/s \n \n Yaw \(model.yaw)° \n Pitch \(model.pitch)° \n Roll \(model.roll)° \n"
        self.flightModeLabel.setTitle(model.vehicleMode, forState: .Normal)
        self.armingButton.setTitle(model.armed, forState: .Normal)
        self.GPSLabel.text = "GPS: \(model.GPS)"
        self.serverSpeedLabel.text = "\(model.serverSpeed) ms"
        if(model.serverStatus){
            self.connectionLabel.setTitle("\(model.ipadress) Connected", forState: .Normal)
        }else{
            self.connectionLabel.setTitle("\(model.ipadress) Disconnected", forState: .Normal)
        }
        
        droneMarker.coordinate = CLLocationCoordinate2DMake(model.lat, model.long)
        println("\(model.lat), \(model.long) ")
        //self.mapView.removeAnnotation(droneMarker)
        //self.mapView.addAnnotation(droneMarker)
    }
    
    @IBAction func changeMode() {
        self.modePickerView.hidden = false
    }
    

    @IBAction func selectMode(sender: UIButton) {
        self.modePickerView.hidden = true
        model.setFlightMode(sender.currentTitle!)
        //self.flightModeLabel.setTitle(sender.currentTitle, forState: .Normal)
    }
    
    @IBAction func arm() {
        if self.armingButton.currentTitle == "ARM"{
            model.arm()
        }else{
            model.disarm()
        }
    }
    
    @IBAction func takePicture() {
        model.takePicture()
    }


}

