//
//  TGPlace.swift
//  Travel GO
//
//  Created by Nguyen Trung Huan on 1/10/17.
//  Copyright © 2017 Mai Anh Vu. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation

class TGPlace {
    var Location: CLLocation
    var IconUrl: String
    var Name: String
    var OpenNow: Bool
    var Rating: Double
    var Types: String
    var Vicinity: String
    
    //MARK: Initialisation
    init(location: CLLocation, icon: String, name: String, opennow: Bool,
         rating: Double, types: String, vicinity: String){
        self.Location = location
        self.IconUrl = icon
        self.Name = name
        self.OpenNow = opennow
        self.Rating = rating
        self.Types = types
        self.Vicinity = vicinity
    }
    
    static func Parse(req: String, callback: @escaping ([TGPlace]) -> Void) {
        Alamofire.request(req).responseJSON { response in
            if let array = response.result.value as? [Any] {
                print("Got an array with \(array.count) objects")
            } else if let dictionary = response.result.value as? [String: AnyObject] {
                let PlacesJson: [[String:Any]] = dictionary["results"] as! [[String : Any]]
                print (PlacesJson)
                print("\n\n\n\n\n\n")
                
                Parse(placesJson: PlacesJson)
            }
        }
    }
    
    static func Parse(placesJson: [[String:Any]]) -> [TGPlace] {
        var places: [TGPlace] = []
        for i in 0..<placesJson.count {
            places.append(Parse(json: placesJson[i]))
        }
        return places
    }
    static func Parse(json: [String:Any]) -> TGPlace {
        let geometry: [String:Any] = json["geometry"] as! [String:Any]
        let location: [String:Any] = geometry["location"] as! [String:Any]
        let latitude: Double = (location["lat"] as! NSNumber).doubleValue
        let longitude: Double = (location["lng"] as! NSNumber).doubleValue
        
        let Location = CLLocation(latitude: latitude, longitude: longitude)
        let Icon: String = json["icon"] as! String
        let Name: String = json["name"] as! String
        var OpenNow: Bool
        if (json["opening_hours"] != nil) {
            let openingHours: [String:Any] = json["opening_hours"] as! [String:Any]
            OpenNow = openingHours["open_now"] as! Bool
        } else {
            OpenNow = true
        }
        
        var Rating: Double
        if json["rating"] != nil {
            Rating = (json["rating"] as! NSNumber).doubleValue
        } else {
            Rating = 0
        }
        let Types: String = (json["types"] as! [String]).joined(separator: ";")
        let Vicinity: String = json["vicinity"] as! String
        
        let Place = TGPlace(location: Location, icon: Icon, name: Name, opennow: OpenNow,
                            rating: Rating, types: Types, vicinity: Vicinity)
        Place.DebugPrint()
        return Place
    }
    
    func DebugPrint() -> Void {
        print(Name, " is open? ", OpenNow, "\n")
        print("(", Location.coordinate.latitude, ", ", Location.coordinate.longitude, ")\n")
        print(Rating, "\n")
        print(Types, "\n")
        print(Vicinity, "\n")
        
    }
}

