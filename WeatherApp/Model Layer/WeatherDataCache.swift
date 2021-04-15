//
//  WeatherDataCache.swift
//  WeatherApp
//
//  Created by Štěpán Pazderka on 13.04.2021.
//

import Foundation
import Database
import RealmSwift
import RxSwift
import MapKit

enum CacheError: Error {
    case entryDoesntExists
}

class WeatherDataCache {
    static let instance = WeatherDataCache()
    var counter = 1
    private var cache: [WeatherDataAPIEntity] = [WeatherDataAPIEntity]()
    let realmDbSyn: Database = RealmDatabaseImpl(databaseSchemaVersion: 1)
    let disposeBag = DisposeBag()
    
    fileprivate func fetchCacheFromUserdefaults() {
        if let encodedWeatherDataArray = UserDefaults.standard.object(forKey: "cache") as? Data {
            if let decoded = try? JSONDecoder().decode([WeatherDataAPIEntity].self, from: encodedWeatherDataArray) {
                cache = decoded
            }
            counter += 1
            print("cache array was created and loaded \(cache.count): \(cache)")
            print("COUNTER: \(counter)")
            withUnsafePointer(to: self) {
                print($0)
            }
        }
    }

    init() {
        fetchCacheFromUserdefaults()
    }

    public func add(_ e: WeatherDataAPIEntity) {
        let latitudePredicate = NSPredicate(format: "latitude == %f", e.coord!.lat as Double)
        let longitudePredicate = NSPredicate(format: "longitude == %f", e.coord!.lon as Double)
        let compoundPredicate = NSCompoundPredicate(type: .and , subpredicates: [latitudePredicate, longitudePredicate])
        
        // Check if such coordinates have been fetched already
        realmDbSyn.getFirst(WeatherDataDBEntity.self, predicate: compoundPredicate).asSingle().subscribe(onSuccess: { entry in
            print(entry)
            self.realmDbSyn.delete(entry).subscribe().dispose()
        }).dispose()
        
        let newDBentry = WeatherDataDBEntity(from: e)
        realmDbSyn.add(newDBentry).subscribe(onCompleted: {
            print(newDBentry)
        }).dispose()
    }
    
    public func load(by coordinates: CLLocationCoordinate2D) -> WeatherDataDBEntity? {
        var returnValue: WeatherDataDBEntity?
        let latitudePredicate = NSPredicate(format: "latitude == %f", coordinates.latitude as Double)
        let longitudePredicate = NSPredicate(format: "longitude == %f", coordinates.longitude as Double)
        let compoundPredicate = NSCompoundPredicate(type: .and , subpredicates: [latitudePredicate, longitudePredicate])
        realmDbSyn.getFirst(WeatherDataDBEntity.self, predicate: compoundPredicate).subscribe(onNext: { entity in
            returnValue = entity
        }).dispose()
        return returnValue
    }

    private func delete(_ e: WeatherDataAPIEntity) {
        realmDbSyn.delete(WeatherDataDBEntity(from: e)).subscribe().dispose()
        UserDefaults.standard.removeObject(forKey: "cache")
        let foundIndex = cache.firstIndex(where: { existingRecord in
            return existingRecord == e
        })
        cache.remove(at: foundIndex!)
        if let weatherDataArray = try? JSONEncoder().encode(cache) {
            UserDefaults.standard.set(weatherDataArray, forKey: "cache")
        }
    }
    
    func getAll() -> Observable<[WeatherDataDBEntity]> {
        var arrayOfPosts: Observable<Results<WeatherDataDBEntity>>
        arrayOfPosts = realmDbSyn.getAll(WeatherDataDBEntity.self)
        return arrayOfPosts.map { Array($0) }
    }
    
    func removeDuplicates() {
        var array = [WeatherDataDBEntity]()
        
        self.getAll().subscribe(onNext: { records in
            array = records
            array.removeDuplicates()
        }).disposed(by: disposeBag)
    }
}
