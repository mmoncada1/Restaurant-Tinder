import Foundation
import CoreLocation
import Combine

class RestaurantService: ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration
    private let yelpAPIKey = APIConfiguration.yelpAPIKey
    private let baseURL = APIConfiguration.yelpBaseURL
    
    func fetchRestaurants(near location: CLLocation, radiusInMiles: Double, cuisine: String? = nil) {
        isLoading = true
        error = nil
        
        // Check if we should use real API or mock data
        if APIConfiguration.isYelpConfigured {
            fetchFromYelpAPI(near: location, radiusInMiles: radiusInMiles, cuisine: cuisine)
        } else {
            // For MVP, we'll use mock data. Replace this with actual API call later.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.loadMockData(near: location, radiusInMiles: radiusInMiles)
            }
        }
    }
    
    // MARK: - Mock Data (for testing)
    private func loadMockData(near location: CLLocation, radiusInMiles: Double) {
        let mockRestaurants = generateMockRestaurants(near: location, radiusInMiles: radiusInMiles)
        
        DispatchQueue.main.async {
            self.restaurants = mockRestaurants
            self.isLoading = false
        }
    }
    
    private func generateMockRestaurants(near location: CLLocation, radiusInMiles: Double) -> [Restaurant] {
        let mockData = [
            ("Tony's Little Star Pizza", ["Pizza", "Italian"], 4.3, "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300&h=200&fit=crop"),
            ("Golden Dragon", ["Chinese", "Asian"], 4.1, "https://images.unsplash.com/photo-1561758033-d89a9ad46330?w=300&h=200&fit=crop"),
            ("Sushi Zen", ["Japanese", "Sushi"], 4.7, "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=300&h=200&fit=crop"),
            ("La Taqueria", ["Mexican", "Tacos"], 4.5, "https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=300&h=200&fit=crop"),
            ("Blue Bottle Coffee", ["Coffee", "Cafe"], 4.2, "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=300&h=200&fit=crop"),
            ("The French Laundry", ["French", "Fine Dining"], 4.9, "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=300&h=200&fit=crop"),
            ("Shake Shack", ["Burgers", "American"], 4.0, "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&h=200&fit=crop"),
            ("Chipotle", ["Mexican", "Fast Casual"], 3.8, "https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=300&h=200&fit=crop"),
            ("In-N-Out Burger", ["Burgers", "American"], 4.4, "https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=300&h=200&fit=crop"),
            ("Panda Express", ["Chinese", "Fast Food"], 3.6, "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=300&h=200&fit=crop"),
            ("Starbucks", ["Coffee", "Cafe"], 3.9, "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=300&h=200&fit=crop"),
            ("Olive Garden", ["Italian", "Casual Dining"], 4.0, "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=300&h=200&fit=crop"),
            ("Subway", ["Sandwiches", "Fast Food"], 3.5, "https://images.unsplash.com/photo-1594109767111-c2146cb029d5?w=300&h=200&fit=crop"),
            ("McDonald's", ["Burgers", "Fast Food"], 3.4, "https://images.unsplash.com/photo-1596662496489-1d0abdc5c1e0?w=300&h=200&fit=crop"),
            ("Thai Palace", ["Thai", "Asian"], 4.6, "https://images.unsplash.com/photo-1559847844-d558cfc9d5c5?w=300&h=200&fit=crop"),
        ]
        
        let radiusInMeters = radiusInMiles * 1609.34 // Convert miles to meters
        
        // Generate more realistic addresses based on common US cities
        let cities = ["San Francisco, CA", "New York, NY", "Los Angeles, CA", "Chicago, IL", "Miami, FL", "Seattle, WA", "Austin, TX", "Portland, OR"]
        let streetNumbers = Array(100...9999).map { String($0) }
        let streetNames = ["Main St", "Oak Ave", "Pine St", "Cedar Blvd", "Elm Dr", "Maple Way", "First St", "Second Ave", "Broadway", "Market St", "Union St", "Valencia St"]
        
        return mockData.enumerated().map { index, data in
            let (name, categories, rating, imageURL) = data
            
            // Generate random distance within radius
            let randomDistance = Double.random(in: 100...radiusInMeters)
            
            // Generate random address
            let randomAddress = "\(streetNumbers.randomElement()!) \(streetNames.randomElement()!), \(cities.randomElement()!)"
            
            return Restaurant(
                id: "mock-\(index)",
                name: name,
                imageURL: imageURL,
                rating: rating,
                distanceMeters: randomDistance,
                categories: categories,
                address: randomAddress,
                url: "https://example.com/restaurant/\(index)"
            )
        }.shuffled()
    }
    
    // MARK: - Yelp API Integration (for future use)
    private func fetchFromYelpAPI(near location: CLLocation, radiusInMiles: Double, cuisine: String?) {
        guard APIConfiguration.isYelpConfigured else {
            print("Please configure your Yelp API key in APIConfiguration.swift")
            loadMockData(near: location, radiusInMiles: radiusInMiles)
            return
        }
        
        var urlComponents = URLComponents(string: baseURL)!
        
        let radiusInMeters = min(Int(radiusInMiles * 1609.34), 40000) // Yelp max radius is 40km
        
        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: String(location.coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(location.coordinate.longitude)),
            URLQueryItem(name: "radius", value: String(radiusInMeters)),
            URLQueryItem(name: "categories", value: cuisine ?? "restaurants"),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "sort_by", value: "distance")
        ]
        
        guard let url = urlComponents.url else {
            DispatchQueue.main.async {
                self.error = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: YelpResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Yelp API Error: \(error.localizedDescription)")
                        self.error = "Failed to load restaurants. Using offline data."
                        self.isLoading = false
                        // Fallback to mock data
                        self.loadMockData(near: location, radiusInMiles: radiusInMiles)
                    }
                },
                receiveValue: { response in
                    self.restaurants = response.businesses.map { business in
                        Restaurant(
                            id: business.id,
                            name: business.name,
                            imageURL: business.imageURL,
                            rating: business.rating,
                            distanceMeters: business.distance,
                            categories: business.categories.map { $0.title },
                            address: business.location.displayAddress.joined(separator: ", "),
                            url: business.url
                        )
                    }
                    self.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
}

// MARK: - Yelp API Response Models
private struct YelpResponse: Codable {
    let businesses: [YelpBusiness]
}

private struct YelpBusiness: Codable {
    let id: String
    let name: String
    let imageURL: String?
    let rating: Double
    let distance: Double
    let categories: [YelpCategory]
    let location: YelpLocation
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, rating, distance, categories, location, url
        case imageURL = "image_url"
    }
}

private struct YelpCategory: Codable {
    let title: String
}

private struct YelpLocation: Codable {
    let displayAddress: [String]
    
    enum CodingKeys: String, CodingKey {
        case displayAddress = "display_address"
    }
}
