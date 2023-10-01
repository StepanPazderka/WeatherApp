//
//  ContentView.swift
//  WeatherApp
//
//  Created by Steve on 26/11/2020.
//

import SwiftUI
import Foundation
import MapKit

struct MasterView: View {
    @ObservedObject var viewModel = MasterViewModel()
    
    @State var city: String = ""
    @State var country: String = ""
    
    @State private var fontSize: CGFloat = 32
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Map(coordinateRegion: $viewModel.MapViewCoordinates, interactionModes: .all, showsUserLocation: true)
                    .onChange(of: viewModel.MapViewCoordinates) { coord in
                        viewModel.approximateTemperatureForCurrentLocation(currentCoordinates: viewModel.MapViewCoordinates)
                        viewModel.getWeatherAtCurrentLocation()
                    }
                VStack {
                    Spacer()
                    HStack(alignment: .center) {
                        Text("\(self.viewModel.currentLocationTemp)")
                            .kerning(0)
                            .tracking(1)
                            .fontWeight(.bold)
                            .padding()
                            .lineLimit(1)
                            .frame(width: 235, height: 40, alignment: Alignment.trailing)
                        Text("\(self.viewModel.countryFlag)")
                            .frame(width: 60, height: 40, alignment: Alignment.leading)
                        }
                    .shadow(color: Color.black, radius: 55)
                    .font(.system(size: 40))
                    .padding(.bottom, 10)
                    TextField("Pick a city to show", text: $city, onCommit: {
                        viewModel.getWeatherAt(city: city)
                    })
                    .modifier(ClearButton(text: $city))
                    .padding()
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .foregroundColor(Color.black)
                    .cornerRadius(15.0)
                    .shadow(radius: 25)
                    .keyboardResponsive()
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: geometry.safeAreaInsets.bottom+50, trailing: 20))
                .alert(isPresented: $viewModel.alertRaised) { () -> Alert in
                    Alert(title: Text(viewModel.alertDescription))
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MasterView()
    }
}
