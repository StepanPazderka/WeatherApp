//
//  ContentView.swift
//  WeatherApp
//
//  Created by Steve on 26/11/2020.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @ObservedObject var weatherManager: WeatherManager = WeatherManager()
    @State var city: String = "prague"
    
    var body: some View {
        TextField("Pick city to show", text: $city, onEditingChanged: { (changed) in
            weatherManager.weather(for: city)
        })
        Text("\(self.weatherManager.currentLocationTemp)")
        .padding()
        .onAppear{
            DispatchQueue.main.async {
                weatherManager.weather(for: city)
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(weatherManager: WeatherManager())
    }
}
