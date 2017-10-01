//
//  ProcessPath.swift
//  TravelGo.dev
//
//  Created by Nguyen Trung Huan on 1/10/17.
//  Copyright © 2017 Nguyen Trung Huan. All rights reserved.
//
//USAGE//
//ProcessPath.getSteps(req: request) { result in
//    print("\n\n\n")
//    for i in 0..<result.count{
//        print("\nStep ", i)
//        print(ProcessPath.getPins(step: result[i]))
//    }
//}

import Foundation
import Alamofire
import CoreLocation

class TGPathProcessor {
    static func getAllPins(req: String, callback: @escaping ([CLLocation]) -> Void) {
        ProcessPath.getSteps(req: req) { (result) in
            var allPins : [CLLocation] = []
            for i in 0..<result.count{
                allPins.append(contentsOf: ProcessPath.getPins(step: result[i]))
            }
            callback(allPins)
        }
    }
    
    static func getSteps(req : String, callback: @escaping ([[String: Any]]) -> Void){
        Alamofire.request(req).responseJSON { response in
            if let array = response.result.value as? [Any] {
                print("Got an array with \(array.count) objects")
            } else if let dictionary = response.result.value as? [String: AnyObject] {
                let responses : [[String: Any]] = dictionary["routes"] as! [[String : Any]]
                let response : [String:Any] = responses[0]
                let legs : [[String:Any]] = response["legs"] as! [[String : Any]]
                let steps : [[String:Any]] = legs[0]["steps"] as! [[String : Any]]
                callback(steps)
            }
        }
    }
    
    static func getPins(step: [String:Any]) -> [CLLocation] {
        let startLocation : [String:Any] = step["start_location"] as! [String:Any]
        let startLat : Double = (startLocation["lat"] as! NSNumber).doubleValue
        let startLng : Double = (startLocation["lng"] as! NSNumber).doubleValue
        let endLocation : [String:Any] = step["end_location"] as! [String:Any]
        let endLat : Double = (endLocation["lat"] as! NSNumber).doubleValue
        let endLng : Double = (endLocation["lng"] as! NSNumber).doubleValue
        return getPins(startLat: startLat, startLng: startLng, endLat: endLat, endLng: endLng)
    }
    
    static func getPins(startLat : Double, startLng : Double, endLat : Double, endLng : Double) -> [CLLocation] {
        let startCoordinate = CLLocation(latitude: startLat, longitude: startLng)
        let endCoordinate = CLLocation(latitude: endLat, longitude: endLng)
        let distance = startCoordinate.distance(from: endCoordinate) // result is in meters
        let noOfSteps = Int (distance / 100)
        
        var pins: [CLLocation] = []
        
        if (noOfSteps > 0) {
            for i in 0...(noOfSteps) {
                pins.append(CLLocation(latitude: startLat + (endLat - startLat) / Double(noOfSteps) * Double(i), longitude: startLng + (endLng - startLng) / Double(noOfSteps) * Double(i)))
            }
        }
        else {
            pins.append(CLLocation(latitude: startLat, longitude: startLng))
            pins.append(CLLocation(latitude: endLat, longitude: endLng))
        }
        print ("Start: (", startLat, ", ", startLng, "); End: (", endLat, ", ", endLng, ")")
        print (noOfSteps + 1, " STEPS IN TOTAL for ", distance, " meters\n")
        return pins
    }
}
