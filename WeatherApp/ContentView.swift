//
//  ContentView.swift
//  WeatherApp
//
//  Created by Steve on 26/11/2020.
//

import SwiftUI
import Foundation
import MapKit

struct ContentView: View {
    @ObservedObject var weatherManager: WeatherService = WeatherService()
    var weatherMap = WeatherMap()
    
    @State var coord: Int = 0
    @State var city: String = ""
    @State var country: String = ""
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Map(coordinateRegion: $weatherManager.coord, interactionModes: .all, showsUserLocation: true)
                    .onChange(of: weatherManager.coord, perform: { coord in
//                        let lat = weatherManager.coord.center.latitude
//                        let long = weatherManager.coord.center.longitude
//                        print("Latitude: \(lat)")
//                        print("Longitude: \(long)")
////
//                        weatherManager.getWeatherBy(longitude: long, latitude: lat)
//                        weatherManager.getCountryCodeBy(longitude: long, latitude: lat)
//                        weatherManager.getCountryCodeBy(longitude: long, latitude: lat)
                    })
                    .onAppear() {
//                        weatherManager.getWeatherBy(latitude: 90, longitude: 180)
                        weatherMap.addWeatherRecord(latitude: 90, longitude: 180, temperature: 15)
//                        print("Fetched record: \(newData!)")
                        print("Read from MAP: \(weatherMap.loadWeatherRecord(latitude: 90, longitude: 180))")
                    }
                VStack {
                    Spacer()
                    HStack(alignment: .center) {
                        Text("\(self.weatherManager.currentLocationTemp)")
                            .fontWeight(.bold)
                            .frame(height: .leastNormalMagnitude, alignment: .trailing)
                            .padding()
                            .onAppear{
                                weatherManager.getWeatherBy(city: city)
                            }
                            .allowsTightening(true)
                          .minimumScaleFactor(0.8)
                        Text(weatherManager.country)
                            .frame(width: 50, height: .leastNormalMagnitude, alignment: .leading)
                            .padding()
                            .shadow(color: Color.black, radius: 55)
                    }
//                    .frame(width: 350, height: 50, alignment: .center)
                    .shadow(color: Color.black, radius: 55)
                    .font(.system(size: 50))
                    .padding(.bottom, 10)
                    TextField("Pick city to show", text: $city, onCommit: {
                        weatherManager.getWeatherBy(city: city)
                    })
                    .padding()
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .foregroundColor(Color.black)
                    .cornerRadius(15.0)
                    .shadow(radius: 25)
                    .keyboardResponsive()
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: proxy.safeAreaInsets.bottom+50, trailing: 20))
            }
            .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(weatherManager: WeatherService())
    }
}

extension MKCoordinateRegion: Equatable
{
   public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool
   {
       if lhs.center.latitude != rhs.center.latitude || lhs.center.longitude != rhs.center.longitude
       {
           return false
       }
       if lhs.span.latitudeDelta != rhs.span.latitudeDelta || lhs.span.longitudeDelta != rhs.span.longitudeDelta
       {
           return false
       }
       return true
   }
}
