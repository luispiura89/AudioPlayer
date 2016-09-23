//
//  HttpManager.swift
//  AudioPlayer
//
//  Created by Luis Francisco Piura Mejia on 24/6/16.
//  Copyright © 2016 Luis Francisco Piura Mejia. All rights reserved.
//

import UIKit

enum EndPointCall : String {
    case artists = "artists.php"
    case songs = "songs.php"
}

class HttpManager: NSObject {
    static let rootURL = "http://werkpal.com/api/"
    static let apiVersion = "api"
    static var offlineMode = false
    
    static func parseData (data : NSData) -> AnyObject! {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
        } catch {
            
        }
        
        return nil
    }
    
    static func findAll(endPoint : EndPointCall, endPointparams : String? = "", params : [String : String ]? = nil, downloadAll: Bool? = false, completionBlock : (records : NSDictionary?, error : NSError?) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            
            //let endPointparams = (endPointparams != nil ? "/" + endPointparams! : "")
            
            var paramsStr = ""
            
            if let params = params {
                for (key, value) in params {
                    paramsStr += "\(key)=\(value)&"
                }
            }
            
            let urlString = rootURL +  endPoint.rawValue + (paramsStr == "" ? "" : "?\(paramsStr)")
            print(urlString)
            
            let url = NSURL(string: urlString)!
            
            let session = NSURLSession.sharedSession()
            let request = NSURLRequest(URL: url)
            
            let dataTask = session.dataTaskWithRequest(request) { (data : NSData?, response : NSURLResponse?, error : NSError?) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    if let error = error {
                        completionBlock(records: nil, error: error)
                        return
                    }
                    
                    if let response = response as? NSHTTPURLResponse {
                        
                        if response.statusCode == 404 {
                            let error = NSError(domain: "Not found", code: response.statusCode, userInfo: ["message" : "algo"])
                            completionBlock(records: nil, error: error)
                            return
                        }
                    }
                    if let data = data {
                        if let inData = parseData(data) as? NSDictionary {
                            completionBlock(records: inData, error: nil)
                            return
                        }
                    }
                    completionBlock(records: nil, error: error)
                })
                
            }
            dataTask.resume()
        }
    }
    
    static func findAllByUrl(urlString: String, completionBlock : (records : NSDictionary?, error : NSError?) -> Void) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            


            
            //let urlString = rootURL + apiVersion + "/" +  endPoint.rawValue +  endPointparams + "?" + paramsStr + "api_key=" + apiKey
            
            let url = NSURL(string: urlString)!
            
            let session = NSURLSession.sharedSession()
            let request = NSURLRequest(URL: url)
            
            let dataTask = session.dataTaskWithRequest(request) { (data : NSData?, response : NSURLResponse?, error : NSError?) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    if let error = error {
                        completionBlock(records: nil, error: error)
                        return
                    }
                    
                    if let response = response as? NSHTTPURLResponse {
                        
                        if response.statusCode == 404 {
                            let error = NSError(domain: "Not found", code: response.statusCode, userInfo: ["message" : "algo"])
                            completionBlock(records: nil, error: error)
                            return
                        }
                    }
                    if let data = data {
                        if let inData = parseData(data) as? NSDictionary {
                            completionBlock(records: inData, error: nil)
                            return
                        }
                    }
                    completionBlock(records: nil, error: error)
                })
                
            }
            dataTask.resume()
        }
    }
}
