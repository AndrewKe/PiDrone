//
//  Reachibility.swift
//  PiDrone
//
//  Created by Andrew Ke on 4/18/15.
//  Copyright (c) 2015 Andrew Ke. All rights reserved.
//

import Foundation
public class Reachability {
    
    class var serverAddress: String {       // computed type property
        return "http://10.0.0.15:8080"
    }
    
    class func isConnectedToNetwork()->Bool{
        
        var Status:Bool = false
        let url = NSURL(string: self.serverAddress)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "HEAD"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 1
        
        var response: NSURLResponse?
        
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: nil) as NSData?
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                Status = true
            }
        }
        
        return Status
    }
}