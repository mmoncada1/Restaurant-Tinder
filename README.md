# RestaurantSwipe - "Tinder for Restaurants"

A SwiftUI iOS app that helps users discover nearby restaurants through an intuitive swipe interface.

## Features

✅ **Core MVP Features:**
- Location-based restaurant discovery
- Swipe interface (left = skip, right = save to favorites)
- Configurable search radius (1-25 miles)
- Persistent favorites list
- Restaurant details with ratings, distance, and categories
- Location permission handling

🌱 **Additional Features:**
- Modern, responsive UI with smooth animations
- Tab-based navigation
- Detailed restaurant view with maps integration
- External links to Yelp and Apple Maps
- Mock data for testing (easily replaceable with live API)

## Project Structure

```
RestaurantSwipe/
├── Models/
│   └── Restaurant.swift          # Data model for restaurants
├── Managers/
│   ├── LocationManager.swift     # Core Location wrapper
│   ├── RestaurantService.swift   # API service (currently mock data)
│   └── FavoritesStore.swift     # UserDefaults persistence
├── Views/
│   ├── ContentView.swift        # Main tab view
│   ├── RadiusSelectorView.swift # Search radius control
│   ├── CardStackView.swift      # Swipeable card stack
│   ├── RestaurantCardView.swift # Individual restaurant card
│   ├── FavoritesView.swift      # Favorites list
│   └── RestaurantDetailView.swift # Detailed restaurant view
└── Assets.xcassets/             # App icons and assets
```

## Architecture

**MVVM Pattern with Combine:**
- `@StateObject` and `@EnvironmentObject` for state management
- Reactive updates using `@Published` properties
- Clean separation of concerns

**Data Flow:**
1. `LocationManager` → provides user coordinates
2. `RestaurantService` → fetches restaurants from API
3. `CardStackView` → displays swipeable cards
4. `FavoritesStore` → persists liked restaurants

## Setup Instructions

### 1. Requirements
- Xcode 15.0+
- iOS 17.0+ target
- Swift 5.9+

### 2. Installation
1. Open `RestaurantSwipe.xcodeproj` in Xcode
2. Select your development team in project settings
3. Build and run on a physical device (location services required)

### 3. Yelp API Integration (Optional)
To use live restaurant data instead of mock data:

1. Get a Yelp Fusion API key from [Yelp Developers](https://www.yelp.com/developers)
2. Open `RestaurantService.swift`
3. Replace `"YOUR_YELP_API_KEY_HERE"` with your actual API key
4. Uncomment the Yelp API call in `fetchRestaurants()` method
5. Comment out the mock data call

### 4. Testing on Device
The app requires location services and works best on a physical device. The simulator can be used with location simulation.

## Key Components

### Location Services
- Requests "When In Use" location permission
- Handles all authorization states gracefully
- Provides user-friendly permission prompts

### Swipe Mechanics
- Gesture-driven card interactions
- Visual feedback during swipes
- Configurable swipe threshold (150pt)
- Smooth animations and haptic feedback

### Data Persistence
- UserDefaults-based favorites storage
- JSON encoding/decoding for Restaurant objects
- Easy migration path to Core Data + CloudKit

### Restaurant Discovery
- Mock data service with realistic restaurant information
- Ready-to-use Yelp API integration
- Configurable search radius and filters

## Customization

### Adding Real API Data
The `RestaurantService` is structured to easily swap mock data for real API calls. Currently supports Yelp Fusion API but can be adapted for other services.

### UI Theming
All colors and styles use SwiftUI's adaptive system colors and can be easily customized through the Assets catalog.

### Enhanced Features
The architecture supports easy addition of:
- User authentication
- Cloud sync (CloudKit)
- Social features
- Advanced filtering
- Maps integration
- Push notifications

## Screenshots

*Note: Add screenshots here when running the app*

## Future Enhancements

- [ ] Real-time restaurant data via Yelp/Google Places API
- [ ] CloudKit integration for cross-device sync
- [ ] Advanced filters (price, cuisine, ratings)
- [ ] Social features (share favorites, friend recommendations)
- [ ] Machine learning for personalized recommendations
- [ ] Offline mode with cached data
- [ ] Apple Watch companion app

## License

This project is open source and available under the MIT License.
