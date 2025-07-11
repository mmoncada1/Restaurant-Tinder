import SwiftUI

@main
struct RestaurantSwipeApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var favoritesStore = FavoritesStore()
    @StateObject private var restaurantService = RestaurantService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(favoritesStore)
                .environmentObject(restaurantService)
        }
    }
}
