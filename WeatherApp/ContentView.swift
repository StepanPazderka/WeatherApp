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
    @ObservedObject var weatherService: WeatherService = WeatherService()
    
    @State var city: String = ""
    @State var country: String = ""
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Map(coordinateRegion: $weatherService.MapViewCoordinates, interactionModes: .all, showsUserLocation: true)
                    .onChange(of: weatherService.MapViewCoordinates) { coord in
                        weatherService.calculateTemperatureForCurrentLocation(currentCoordinates: weatherService.MapViewCoordinates, completion: nil)
                    }
                    .onAppear() {
//                        weatherService.getWeatherInLoop()
                    }
                    
                VStack {
                    Spacer()
                    HStack(alignment: .center) {
                        Text("\(self.weatherService.currentLocationTemp) ")
                            .fontWeight(.bold)
                            .frame(height: .leastNormalMagnitude, alignment: .trailing)
                            .padding()
                            .onAppear{
                                weatherService.getWeatherBy(city: city)
                            }
                          .minimumScaleFactor(0.8)
//                        Text(weatherService.country)
//                            .frame(width: 50, height: .leastNormalMagnitude, alignment: .leading)
//                            .padding()
//                            .shadow(color: Color.black, radius: 55)
                    }
//                    .frame(width: 350, height: 50, alignment: .center)
                    .shadow(color: Color.black, radius: 55)
                    .font(.system(size: 50))
                    .padding(.bottom, 10)
                    TextField("Pick city to show", text: $city, onCommit: {
                        weatherService.getWeatherBy(city: city)
                    })
                    .padding()
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .foregroundColor(Color.black)
                    .cornerRadius(15.0)
                    .shadow(radius: 25)
                    .keyboardResponsive()
                    Button(action: {
                        weatherService.getWeatherBy(latitude: weatherService.MapViewCoordinates.center.latitude, longitude: weatherService.MapViewCoordinates.center.longitude, completion: nil)
                    }) {
                        Text("Make record")
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: proxy.safeAreaInsets.bottom+50, trailing: 20))
            }
            .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(weatherService: WeatherService())
    }
}
