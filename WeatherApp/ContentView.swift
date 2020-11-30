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
    @ObservedObject var weatherManager: WeatherManager = WeatherManager()
    @State var city: String = ""
    
    var body: some View {
        ZStack {
//            Map(coordinateRegion:$weatherManager.coord, interactionModes = .all, showsUserLocation: true)
            Map(coordinateRegion: $weatherManager.coord, interactionModes: .all, showsUserLocation: true)
            
            VStack {
                Spacer()
                Text("\(self.weatherManager.currentLocationTemp)")
                .fontWeight(.bold)
                .font(.largeTitle)
                .padding()
                    .shadow(color: Color.black, radius: 55)
                .onAppear{
                    weatherManager.weather(for: city)
                }
                TextField("Pick city to show", text: $city, onCommit: {
                    weatherManager.weather(for: city)
                })
                .padding()
                .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                .foregroundColor(Color.black)
                .cornerRadius(15.0)
                .keyboardResponsive()
            }
            .padding(.bottom, 100)
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(weatherManager: WeatherManager())
    }
}
