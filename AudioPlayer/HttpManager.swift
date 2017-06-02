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
    
    static func parseData (_ data : Data) -> Any! {
        do {
            return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        } catch {
            
        }
        
        return nil
    }
    
    static func findAll(_ endPoint : EndPointCall, endPointparams : String? = "", params : [String : String ]? = nil, downloadAll: Bool? = false, completionBlock : @escaping (_ records : NSDictionary?, _ error : NSError?) -> Void) {
        
        //DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
        DispatchQueue.global(qos: .default).async {
            
            //let endPointparams = (endPointparams != nil ? "/" + endPointparams! : "")
            
            var paramsStr = ""
            
            if let params = params {
                for (key, value) in params {
                    paramsStr += "\(key)=\(value)&"
                }
            }
            
            let urlString = rootURL +  endPoint.rawValue + (paramsStr == "" ? "" : "?\(paramsStr)")
            print(urlString)
            
            let url = URL(string: urlString)!
            
            let session = URLSession.shared
            let request = URLRequest(url: url)
            
            let dataTask = session.dataTask(with: request, completionHandler: { (data : Data?, response : URLResponse?, error : NSError?) in
                
                DispatchQueue.main.async(execute: {
                    if let error = error {
                        completionBlock(nil, error)
                        return
                    }
                    
                    if let response = response as? HTTPURLResponse {
                        
                        if response.statusCode == 404 {
                            let error = NSError(domain: "Not found", code: response.statusCode, userInfo: ["message" : "algo"])
                            completionBlock(nil, error)
                            return
                        }
                    }
                    if let data = data {
                        if let inData = parseData(data) as? NSDictionary {
                            completionBlock(inData, nil)
                            return
                        }
                    }
                    completionBlock(nil, error)
                })
                
            } as! (Data?, URLResponse?, Error?) -> Void) 
            dataTask.resume()
        }
    }
    
    static func findAllByUrl(_ urlString: String, completionBlock : @escaping (_ records : NSDictionary?, _ error : NSError?) -> Void) {
        
        //DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
        DispatchQueue.global(qos: .default).async {    
            


            
            //let urlString = rootURL + apiVersion + "/" +  endPoint.rawValue +  endPointparams + "?" + paramsStr + "api_key=" + apiKey
            
            let url = URL(string: urlString)!
            
            let session = URLSession.shared
            let request = URLRequest(url: url)
            
            let dataTask = session.dataTask(with: request, completionHandler: { (data : Data?, response : URLResponse?, error : NSError?) in
                
                DispatchQueue.main.async(execute: {
                    if let error = error {
                        completionBlock(nil, error)
                        return
                    }
                    
                    if let response = response as? HTTPURLResponse {
                        
                        if response.statusCode == 404 {
                            let error = NSError(domain: "Not found", code: response.statusCode, userInfo: ["message" : "algo"])
                            completionBlock(nil, error)
                            return
                        }
                    }
                    if let data = data {
                        if let inData = parseData(data) as? NSDictionary {
                            completionBlock(inData, nil)
                            return
                        }
                    }
                    completionBlock(nil, error)
                })
                
            } as! (Data?, URLResponse?, Error?) -> Void) 
            dataTask.resume()
        }
    }
}
