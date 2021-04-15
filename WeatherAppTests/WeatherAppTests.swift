//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Tom Novotny on 15.04.2021.
//

@testable import WeatherApp

import Combine
import RealmSwift
import XCTest

class WeatherAppTests: XCTestCase {
    
    let realm = try! Realm()
    var disposeBag = Set<AnyCancellable>()

    // This is called before every test
    override func setUp() {
        super.setUp()
        realm.beginWrite()
        realm.deleteAll()
        try! realm.commitWrite()
    }

    // This is called after every test
    override func tearDown() {
        super.tearDown()
        realm.beginWrite()
        realm.deleteAll()
        try! realm.commitWrite()
    }

    func testExample() throws {
        let observedData = realm.objects(WeatherDataDBEntity.self)
        let testEntityID = "1235"
        let testExpectation = XCTestExpectation(description: "Waiting for data")

        RealmPublishers.array(from: observedData)
            .filter { !$0.isEmpty }
            .sink(receiveCompletion: { _ in },
                  receiveValue: { data in
                    XCTAssertEqual(data.first?.id, testEntityID)
                    testExpectation.fulfill()
                  })
            .store(in: &disposeBag)

        let testData = WeatherDataDBEntity()
        testData.id = testEntityID
        try realm.write {
            realm.add(testData)
        }
        
        wait(for: [testExpectation], timeout: 10)
    }

}
