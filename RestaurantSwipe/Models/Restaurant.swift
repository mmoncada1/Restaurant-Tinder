import Foundation

struct Restaurant: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageURL: String?
    let rating: Double
    let distanceMeters: Double
    let categories: [String]
    let address: String
    let url: String?
    
    // Computed property to convert distance to miles
    var distanceMiles: Double {
        return distanceMeters * 0.000621371 // Convert meters to miles
    }
    
    // Formatted distance string
    var formattedDistance: String {
        let miles = distanceMiles
        if miles < 0.1 {
            return "< 0.1 mi"
        } else if miles < 1.0 {
            return String(format: "%.1f mi", miles)
        } else {
            return String(format: "%.1f mi", miles)
        }
    }
    
    // Formatted categories string
    var categoriesString: String {
        return categories.joined(separator: ", ")
    }
    
    // Sample data for previews and testing
    static let sample = Restaurant(
        id: "sample-1",
        name: "Sample Restaurant",
        imageURL: "https://via.placeholder.com/300x200",
        rating: 4.5,
        distanceMeters: 805, // ~0.5 miles
        categories: ["Italian", "Pizza"],
        address: "123 Main St, San Francisco, CA",
        url: "https://example.com"
    )
    
    static let sampleArray: [Restaurant] = [
        Restaurant(
            id: "sample-1",
            name: "Mama's Italian Kitchen",
            imageURL: "https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Italian",
            rating: 4.5,
            distanceMeters: 805,
            categories: ["Italian", "Pizza"],
            address: "123 Main St, San Francisco, CA",
            url: "https://example.com"
        ),
        Restaurant(
            id: "sample-2",
            name: "Sushi Paradise",
            imageURL: "https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Sushi",
            rating: 4.8,
            distanceMeters: 1207,
            categories: ["Japanese", "Sushi"],
            address: "456 Oak Ave, San Francisco, CA",
            url: "https://example.com"
        ),
        Restaurant(
            id: "sample-3",
            name: "Burger Palace",
            imageURL: "https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Burgers",
            rating: 4.2,
            distanceMeters: 1609,
            categories: ["American", "Burgers"],
            address: "789 Pine St, San Francisco, CA",
            url: "https://example.com"
        )
    ]
}
