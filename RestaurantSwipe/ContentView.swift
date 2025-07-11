import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var favoritesStore: FavoritesStore
    @EnvironmentObject var restaurantService: RestaurantService
    
    @State private var selectedTab = 0
    @State private var searchRadius: Double = 5.0 // Default 5 miles
    @State private var showingLocationAlert = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Swipe View
            VStack {
                if locationManager.isLocationAvailable {
                    VStack(spacing: 20) {
                        RadiusSelectorView(radius: $searchRadius) {
                            fetchRestaurants()
                        }
                        
                        CardStackView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding()
                } else {
                    LocationPermissionView()
                }
            }
            .tabItem {
                Image(systemName: "heart.circle")
                Text("Discover")
            }
            .tag(0)
            
            // Favorites View
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .tag(1)
        }
        .onAppear {
            setupLocation()
        }
        .alert("Location Required", isPresented: $showingLocationAlert) {
            Button("Settings") {
                openSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable location access in Settings to discover nearby restaurants.")
        }
    }
    
    private func setupLocation() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestLocationPermission()
        } else if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
            showingLocationAlert = true
        } else if locationManager.isLocationAvailable {
            fetchRestaurants()
        }
    }
    
    private func fetchRestaurants() {
        guard let location = locationManager.location else { return }
        restaurantService.fetchRestaurants(near: location, radiusInMiles: searchRadius)
    }
    
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

struct LocationPermissionView: View {
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Location Access Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("RestaurantSwipe needs your location to find nearby restaurants within your selected radius.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Enable Location") {
                locationManager.requestLocationPermission()
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(FavoritesStore())
        .environmentObject(RestaurantService())
}
