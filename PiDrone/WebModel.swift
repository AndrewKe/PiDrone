 //
//  WebModel.swift
//  PiDrone
//
//  Created by Andrew Ke on 4/9/15.
//  Copyright (c) 2015 Andrew Ke. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

class WebModel: NSObject{
    
    var safe = true
    
    var batteryVoltage = 0
    var GPS = "NO FIX"
    var signal = 100
    
    var yaw:Double = 0
    var pitch:Double = 0
    var roll:Double = 0
    
    var altitude:Double = 5
    var speed:Double = 5
    
    var lat:Double = 37.547438
    var long:Double = -122.301796
    
    var armed = "ARM"
    
    var vehicleMode = "STABILIZE"
    
    var serverStatus = true //true is Connected, False is not connected
    var serverSpeed: Int = 0
    
    var ipadress = "192.168.1.142"
    
    override init(){
        super.init()
        //takePicture()
    }
    
    //Make JSON request and update the stats accordingly
    func update(){
        var data = getJSON("http://\(ipadress):9090/JSON")
        if data != nil{
            let json = parseJSON(data!)
            yaw = json["yaw"]!
            pitch = json["pitch"]!
            roll = json["roll"]!
            
            altitude = json["alt"]!
            speed = json["groundspeed"]!
            
            speed = json["mode"]!
            
            lat = json["lat"]!
            long = json["lon"]!
            
            lat = 37.547438
            long = -122.301796
            
            //Decode integer to meaning of states (next three control flow things)
            if json["armed"]! == 0{
                armed = "ARM"
            }
            else{
                armed = "DISARM"
            }
            
            if json["gpsfix"]! > 2{
                GPS = "FIX"
            }
            else{
                GPS = "NO FIX"
            }
            
            switch json["mode"]!{
            case 0:
                vehicleMode = "AUTO"
            case 1:
                vehicleMode = "STABILIZE"
            case 2:
                vehicleMode = "LOITER"
            case 3:
                vehicleMode = "ALT_HOLD"
            default:
                fatalError("NON STANDARD FLIGHT MODE USED")
            }
        }
    }
    
    //Function to get JSON using url from Stack Overflow. Had to add optionals
    func getJSON(urlToRequest: String) -> NSData?{
        var url = NSURL(string: urlToRequest)
        var data:NSData? = nil
        let start = NSDate()
        println("Loading data ...")
        if !safe{
            data =  NSData(contentsOfURL: url!)
            print(" successful")
        }
        let end = NSDate();
        serverSpeed = Int(round(1000*end.timeIntervalSinceDate(start)))
        if data != nil{
            serverStatus = true
            return data
        }else{
            //println("Server down!")
            serverStatus = false
        }
        return nil
    }
    
    //parse json to dictionary. Changed type from NSDict to swift dict. Made the type of the returned Dictioanry explicit to prevent retreiving AnyObjects.
    func parseJSON(inputData: NSData) -> Dictionary<String, Double>{
        var error: NSError?
        let jsonDic = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Dictionary<String, Double>;
        
        return jsonDic
    }
    
    
    //helper function to make request to url, returning nothing
    func request(url: String){
        if serverStatus == true {
            //var url: NSURL = NSURL(string: url)!
            //NSData(contentsOfURL: url)
            let url = NSURL(string: url)
            let request = NSURLRequest(URL: url!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            }
        }
    }
    
    func takePicture(){
        let url = NSURL(string: "http://\(ipadress):8080/?action=snapshot")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            var picture = UIImage(data: data)
            UIImageWriteToSavedPhotosAlbum(picture, nil, nil, nil)
            println("Picture Downloaded")
        }
        /*let url = NSURL(string: "http://10.0.0.15:8080/?action=snapshot")
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        let picture = UIImage(data: data!)
        UIImageWriteToSavedPhotosAlbum(picture, nil, nil, nil)*/
    }
    
    func setFlightMode(mode: NSString){
        println("Flight mode changed to \(mode)")
        request("http://\(ipadress):9090/iChangeMode?mode=\(mode)")
    }
    
    //Arming and Disarming Functions
    func arm(){
        lat = 37
        long = -121
        println("Arming System")
        request("http://\(ipadress):9090/iArm")
    }
    
    func disarm(){
        println("Disarming System")
        request("http://\(ipadress):9090/iDisarm")
    }
}
