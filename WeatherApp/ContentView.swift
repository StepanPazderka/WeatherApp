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
    @State var city: String = ""
    
    var body: some View {
        VStack {
            Text("\(self.weatherManager.currentLocationTemp)")
            .fontWeight(.bold)
            .font(.largeTitle)
            .padding()
            .onAppear{
                weatherManager.weather(for: city)
            }
            TextField("Pick city to show", text: $city, onCommit: {
                weatherManager.weather(for: city)
            })
            .padding()
            .background(Color.gray)
            .cornerRadius(5.0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(weatherManager: WeatherManager())
    }
}
