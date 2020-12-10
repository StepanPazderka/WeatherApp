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
    @ObservedObject var weatherDatabase = WeatherDatabase()
    @ObservedObject var locationManager = LocationManager()
    
    @State var city: String = ""
    @State var country: String = ""
    @State var showingAlert: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Map(coordinateRegion: $weatherDatabase.MapViewCoordinates, interactionModes: .all, showsUserLocation: true)
                    .onChange(of: weatherDatabase.MapViewCoordinates) { coord in
                        weatherDatabase.calculateTemperatureForCurrentLocation(currentCoordinates: weatherDatabase.MapViewCoordinates)
                    }
                VStack {
                    Spacer()
                    HStack(alignment: .center) {
                        Text("\(self.weatherDatabase.currentLocationTemp)")
                            .fontWeight(.bold)
                            .frame(height: .leastNormalMagnitude, alignment: .trailing)
                            .padding()
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
                        weatherDatabase.getWeatherBy(city: city)
                    })
                    .modifier(ClearButton(text: $city))
                    .padding()
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .foregroundColor(Color.black)
                    .cornerRadius(15.0)
                    .shadow(radius: 25)
                    .keyboardResponsive()
//                    Button(action: {
//                        weatherService.getWeatherBy(coordinates: CLLocationCoordinate2D(latitude: weatherService.MapViewCoordinates.center.latitude, longitude: weatherService.MapViewCoordinates.center.longitude), completion: nil)
//                    }) {
//                        Text("Make record")
//                    }
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: proxy.safeAreaInsets.bottom+50, trailing: 20))
                .alert(isPresented: $weatherDatabase.alertRaised) { () -> Alert in
                    Alert(title: Text("Cannot find \(weatherDatabase.chosenCity)"))
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct ClearButton: ViewModifier
{
    @Binding var text: String

    public func body(content: Content) -> some View
    {
        ZStack(alignment: .trailing)
        {
            content

            if !text.isEmpty
            {
                Button(action:
                {
                    self.text = ""
                })
                {
                    Image(systemName: "delete.left")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                }
                .padding(.trailing, 8)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
