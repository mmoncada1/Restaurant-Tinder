import Foundation
import Combine

class FavoritesStore: ObservableObject {
    @Published var favorites: [Restaurant] = []
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "SavedFavorites"
    
    init() {
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    func addToFavorites(_ restaurant: Restaurant) {
        // Check if restaurant is already in favorites
        guard !favorites.contains(where: { $0.id == restaurant.id }) else {
            return
        }
        
        favorites.append(restaurant)
        saveFavorites()
    }
    
    func removeFromFavorites(_ restaurant: Restaurant) {
        favorites.removeAll { $0.id == restaurant.id }
        saveFavorites()
    }
    
    func isFavorite(_ restaurant: Restaurant) -> Bool {
        return favorites.contains { $0.id == restaurant.id }
    }
    
    func toggleFavorite(_ restaurant: Restaurant) {
        if isFavorite(restaurant) {
            removeFromFavorites(restaurant)
        } else {
            addToFavorites(restaurant)
        }
    }
    
    func clearAllFavorites() {
        favorites.removeAll()
        saveFavorites()
    }
    
    // MARK: - Private Methods
    
    private func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favorites)
            userDefaults.set(data, forKey: favoritesKey)
        } catch {
            print("Failed to save favorites: \(error.localizedDescription)")
        }
    }
    
    private func loadFavorites() {
        guard let data = userDefaults.data(forKey: favoritesKey) else {
            return
        }
        
        do {
            favorites = try JSONDecoder().decode([Restaurant].self, from: data)
        } catch {
            print("Failed to load favorites: \(error.localizedDescription)")
            favorites = []
        }
    }
}
