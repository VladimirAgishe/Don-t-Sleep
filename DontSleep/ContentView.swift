//
//  ContentView.swift
//  DontSleep
//
//  Created by Vladimir Agishev on 09.11.2021.
//

import SwiftUI
import MapKit
import AVFoundation
import CoreLocation
import AudioToolbox




func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D?) -> CLLocationDistance {
    var from = CLLocation(latitude: from.latitude, longitude: from.longitude)
    var to = CLLocation(latitude: to!.latitude ?? 0.0, longitude: to?.longitude ?? 0.0)
        return from.distance(from: to)
    }

func goFirst() {
    if let window = UIApplication.shared.windows.first {
        window.rootViewController = UIHostingController(rootView: ContentView())
        window.makeKeyAndVisible()
    }
}
let systemSoundID: SystemSoundID = 1016
var PointToGo: String? = ""
var Coordinates:CLLocationCoordinate2D?
var Centered = true
struct ContentView: View {
    
    @ObservedObject private var locationManager = LocationManager()
    @State private var NameOfThepoint: String = ""
    @State private var SomethingInSearch: Bool = false
    @State var shouldHide = true
    @State private var NameOfThePlace: String? = ""
    
    var body: some View {
       
        let coordinate = self.locationManager.location != nil
            ? self.locationManager.location!.coordinate :
            CLLocationCoordinate2D()
        
        
        ZStack(alignment: .top) {
            
            MapView().ignoresSafeArea(.all)
            VStack{
                
                TextField("", text: $NameOfThepoint, onEditingChanged: {_ in MapView().searchInMap(name: NameOfThepoint) { (value) in
                    NameOfThePlace = value?.title
                    Coordinates = value?.coordinate
                    SomethingInSearch = true
                    PointToGo = NameOfThePlace
                    shouldHide = false
                    
                    
                }
                    
                })
                
                    .frame(width: 350.0, height: 40.0)
                    .background(Color.white)
                    .cornerRadius(12.0)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.black)
                    
                    
                
                
                
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {
                        Centered = true
                        
                        
                                    }) {
                                        Image(systemName: "location.circle.fill")
                                            .resizable(resizingMode: .tile)
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(Color.black, Color.white)



                                    }
                                   .frame(width: 50.0, height: 50.0)
                                    
                                    
                }.frame(width: UIScreen.main.bounds.size.width/1.1, height: 50)
                       
                
                GroupBox{
                    VStack{
                        Text(NameOfThePlace ?? "")
                        
                        
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hue: 1.0, saturation: 0.07, brightness: 0.346))
                        
                        Button(action: {
                            func goHome() {
                                if let window = UIApplication.shared.windows.first {
                                    window.rootViewController = UIHostingController(rootView: AppHome())
                                    window.makeKeyAndVisible()
                                }
                            }
                            goHome()
                        }) {
                            
                            Text("Wake me up")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)/*@END_MENU_TOKEN@*/
                        }
                        
                        .frame(width: 340.0, height: 50.0)
                        .background(Color.green)
                        
                        .cornerRadius(10)
                        
                    }
                    
                }
                .opacity(shouldHide ? 0 : 1)
                .groupBoxStyle(TransparentGroupBox())
                
            }
            }
        
        }
        
    
}


struct AppHome: View {
    @ObservedObject var locationManager = LocationManager()
    @State var Distant:Int = 0
    @State var shouldHide = true
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func alarm(coords: CLLocationCoordinate2D?, selfcoords:CLLocationCoordinate2D) -> Int{
                        
         return Int(distance(from: selfcoords, to:  coords))
        

    }
    
    
    
    var body: some View {
        
        
        
        VStack {
            
            Spacer()
            Text(PointToGo ?? "Error, please reload the app")
                .font(.title)
                .fontWeight(.bold)
                .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xLarge/*@END_MENU_TOKEN@*/)
            Spacer()
            Text("Meters to point: \(String(Distant))")
                .font(.title)
                .fontWeight(.bold)
                .dynamicTypeSize(/*@START_MENU_TOKEN@*/.xLarge/*@END_MENU_TOKEN@*/)
                .onReceive(timer) { input in
                    var coordinate = self.locationManager.location != nil
                                            ? self.locationManager.location!.coordinate :
                                            CLLocationCoordinate2D()
                    
                    Distant = alarm(coords: Coordinates, selfcoords: coordinate)
                    print(coordinate)
                    if Distant <= 500{
                        AudioServicesPlaySystemSound(systemSoundID)
                        shouldHide = false
                        timer.upstream.connect().cancel()
                        
                    }
                            
                 }
            
           Spacer()
            Button(action: {
                goFirst()
                AudioServicesDisposeSystemSoundID(systemSoundID)
            }) {
                
                Text("STOP")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)/*@END_MENU_TOKEN@*/
                        }
                        
                        .frame(width: 340.0, height: 100.0)
                        .background(Color.red)
                                    
                        .cornerRadius(10)
                        .opacity(shouldHide ? 0 : 1)
                        
            Spacer()
        }
        
       
        
    }
}


struct TransparentGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .frame(maxWidth: 700)
            
            .padding(.vertical, 20.0)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .overlay(configuration.label.padding([.top, .leading], 10.0), alignment: .topLeading).padding(.all)
        
    }
}


struct MapView: UIViewRepresentable {
    
    @ObservedObject private var locationManager = LocationManager()
    var Regionset = false
    
    func makeUIView(context: Context) -> MKMapView {
        
        let coordinate = self.locationManager.location != nil
            ? self.locationManager.location!.coordinate :
            CLLocationCoordinate2D()

        let mapView = MKMapView()
        mapView.delegate = context.coordinator
       
        var region = MKCoordinateRegion(center: coordinate, latitudinalMeters:1000, longitudinalMeters:1000)
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
        
        return mapView
        
    }
    func updateRegion() -> MKMapView{

        let coordinate = self.locationManager.location != nil
           ? self.locationManager.location!.coordinate :
           CLLocationCoordinate2D()

        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters:10000, longitudinalMeters:10000)
        let mapView = MKMapView()
        mapView.setRegion(region, animated: true)
        return mapView

    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        let coordinate = self.locationManager.location != nil
            ? self.locationManager.location!.coordinate :
            CLLocationCoordinate2D()
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters:10000, longitudinalMeters:10000)
        if (Double(coordinate.latitude) != 0.0) && Centered{
            uiView.setRegion(region, animated: true)
            Centered = false
            
        }
        
        
        }
    
    func searchInMap(name : String, completion: @escaping ((MKPlacemark?) -> Void)){
        let mapView = MKMapView()
        
        var value:MKPlacemark?
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = name
        searchRequest.region = mapView.region
        
        let search = MKLocalSearch(request: searchRequest)
        
        
        
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            
            
            
            value = response.mapItems.first?.placemark
            completion(value)

        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate{
        var parent: MapView
        
      
        
        init(_ parent:MapView){
            self.parent = parent
        }
        
   
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 13 Pro")
            
    }
}

