//
//  WeatherDataDbEntity.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 13.04.2021.
//

import Foundation
import MapKit
import RealmSwift

class WeatherDataDBEntity: Object, WeatherDataEntity {
    
    @objc dynamic var id: String? = String("0")
    @objc dynamic var temp: Float = 0.0
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
//    @objc dynamic var coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @objc dynamic var date: Date = Date()
    @objc dynamic var flag: String = String()
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func getID() {
        self.id = String(latitude + longitude)
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    init(from entity: WeatherDataAPIEntity) {
        super.init()
        self.temp = entity.temp
        self.latitude = entity.coordinates.latitude
        self.longitude = entity.coordinates.longitude
        self.date = entity.date
        self.flag = entity.flag
        getID()
    }
    
    init(from entity: WeatherDataEntity) {
        super.init()
        self.temp = entity.temp
        self.latitude = entity.coordinates.latitude
        self.longitude = entity.coordinates.longitude
        self.date = entity.date
        self.flag = entity.flag
        getID()
    }
    
    required init() {
        super.init()
//        fatalError("init() has not been implemented")
    }
}
