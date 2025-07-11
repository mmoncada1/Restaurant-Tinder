import Foundation

struct APIConfiguration {
    // MARK: - Yelp API Configuration
    
    /// Your Yelp Fusion API Key
    /// Get one at: https://www.yelp.com/developers/v3/manage_app
    static let yelpAPIKey = "YOUR_YELP_API_KEY_HERE"
    
    /// Yelp API Base URL
    static let yelpBaseURL = "https://api.yelp.com/v3/businesses/search"
    
    // MARK: - Configuration Validation
    
    static var isYelpConfigured: Bool {
        return !yelpAPIKey.contains("YOUR_YELP_API_KEY_HERE") && !yelpAPIKey.isEmpty
    }
    
    // MARK: - Future API Configurations
    
    /// Google Places API Key (for future use)
    static let googlePlacesAPIKey = "YOUR_GOOGLE_PLACES_API_KEY_HERE"
    
    /// Apple Maps API configuration (if needed)
    static let appleMapsEnabled = true
}

// MARK: - Usage Instructions
/*
 To set up live API data:
 
 1. Yelp API Setup:
    - Create a Yelp developer account at https://www.yelp.com/developers
    - Create a new app to get your API key
    - Replace "YOUR_YELP_API_KEY_HERE" with your actual key
    - Update RestaurantService.swift to use live data instead of mock data
 
 2. Security Best Practices:
    - Never commit real API keys to version control
    - Use environment variables or secure storage in production
    - Consider using a backend service to proxy API calls
 
 3. Rate Limiting:
    - Yelp API has rate limits (5000 requests/day for free tier)
    - Implement proper caching and request throttling
    - Monitor API usage in production
 */
