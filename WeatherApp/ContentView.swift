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
    
    var body: some View {
        Text("\(self.weatherManager.currentLocationTemp)")
        .padding()
        .onAppear{
            DispatchQueue.main.async {
                weatherManager.weather(for: "prague")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(weatherManager: WeatherManager())
    }
}
