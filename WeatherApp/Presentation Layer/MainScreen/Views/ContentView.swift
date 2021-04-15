//
//  ContentView.swift
//  WeatherApp
//
//  Created by Steve on 26/11/2020.
//

import SwiftUI
import Foundation
import MapKit
import Swinject

struct ContentView: View {
    init(viewModel: ContentViewModel) {
        ContainerBuilder.buildContainer()
        ViewModel = container.resolve(ContentViewModel.self)!
    }
    
    @ObservedObject var ViewModel: ContentViewModel

    @State var city: String = ""
    @State var country: String = ""
    @State var showingAlert: Bool = false
    @State private var fontSize: CGFloat = 32
    

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Map(coordinateRegion: $ViewModel.MapViewCoords, interactionModes: .all, showsUserLocation: true)
                    .onChange(of: ViewModel.MapViewCoords) { _ in
                        ViewModel.mapViewChanged()
                    }
                VStack {
                    Spacer()
                    HStack(alignment: .center) {
                        Text("\(self.ViewModel.CurrentLocationTemperature)")
                            .kerning(0)
                            .tracking(1)
                            .fontWeight(.bold)
                            .padding()
                            .lineLimit(1)
                            .frame(width: 235, height: 40, alignment: Alignment.trailing)
                        Text("\(self.ViewModel.currentCountryFlag)")
                            .frame(width: 60, height: 40, alignment: Alignment.leading)
                        }
                    .shadow(color: Color.black, radius: 55)
                    .font(.system(size: 40))
                    .padding(.bottom, 10)
                    TextField("Pick city to show", text: $city, onCommit: {
                        ViewModel.getWeatherAt(city: city)
                    })
                    .modifier(ClearButton(text: $city))
                    .padding()
                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                    .foregroundColor(Color.black)
                    .cornerRadius(15.0)
                    .shadow(radius: 25)
                    .keyboardResponsive()
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: proxy.safeAreaInsets.bottom+50, trailing: 20))
                .alert(isPresented: $ViewModel.isAlertRaised) { () -> Alert in
                    Alert(title: Text(ViewModel.alertDescription))
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct ClearButton: ViewModifier {
    @Binding var text: String

    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content

            if !text.isEmpty {
                Button(action: {
                    self.text.removeAll()
                }) {
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
        ContentView(viewModel: container.resolve(ContentViewModel.self)!)
    }
}
