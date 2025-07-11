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
        
        // For MVP, we'll use mock data. Replace this with actual API call later.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadMockData(near: location, radiusInMiles: radiusInMiles)
        }
        
        // Uncomment below to use real Yelp API
        // fetchFromYelpAPI(near: location, radiusInMiles: radiusInMiles, cuisine: cuisine)
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
            ("Tony's Little Star Pizza", ["Pizza", "Italian"], 4.3, "https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Pizza"),
            ("Golden Dragon", ["Chinese", "Asian"], 4.1, "https://via.placeholder.com/300x200/FFD93D/FFFFFF?text=Chinese"),
            ("Sushi Zen", ["Japanese", "Sushi"], 4.7, "https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Sushi"),
            ("La Taqueria", ["Mexican", "Tacos"], 4.5, "https://via.placeholder.com/300x200/A8E6CF/FFFFFF?text=Tacos"),
            ("Blue Bottle Coffee", ["Coffee", "Cafe"], 4.2, "https://via.placeholder.com/300x200/87CEEB/FFFFFF?text=Coffee"),
            ("The French Laundry", ["French", "Fine Dining"], 4.9, "https://via.placeholder.com/300x200/DDA0DD/FFFFFF?text=French"),
            ("Shake Shack", ["Burgers", "American"], 4.0, "https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Burgers"),
            ("Chipotle", ["Mexican", "Fast Casual"], 3.8, "https://via.placeholder.com/300x200/F4A460/FFFFFF?text=Chipotle"),
            ("In-N-Out Burger", ["Burgers", "American"], 4.4, "https://via.placeholder.com/300x200/FF69B4/FFFFFF?text=In-N-Out"),
            ("Panda Express", ["Chinese", "Fast Food"], 3.6, "https://via.placeholder.com/300x200/32CD32/FFFFFF?text=Panda"),
        ]
        
        let radiusInMeters = radiusInMiles * 1609.34 // Convert miles to meters
        
        return mockData.enumerated().map { index, data in
            let (name, categories, rating, imageURL) = data
            
            // Generate random distance within radius
            let randomDistance = Double.random(in: 100...radiusInMeters)
            
            // Generate random address
            let streetNumbers = ["123", "456", "789", "321", "654", "987"]
            let streetNames = ["Main St", "Oak Ave", "Pine St", "Cedar Blvd", "Elm Dr", "Maple Way"]
            let randomAddress = "\(streetNumbers.randomElement()!) \(streetNames.randomElement()!), San Francisco, CA"
            
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
                        self.error = error.localizedDescription
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
