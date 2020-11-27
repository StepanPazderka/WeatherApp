//
//  ContentView.swift
//  WeatherApp
//
//  Created by Steve on 26/11/2020.
//

import SwiftUI
import Foundation

struct ContentView: View {
    
    
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear{
//                let url = URL(string: "https://api.letsbuildthatapp.com/jsondecodable/course")
                let weatherTemp = WeatherManager().weather(for: "kladno")
                print(weatherTemp ?? "No Data")
            }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
