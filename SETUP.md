# RestaurantSwipe Setup Guide

## Quick Start

The app is **fully functional** with mock data out of the box! You can:

1. Open `RestaurantSwipe.xcodeproj` in Xcode
2. Build and run on iOS Simulator or a physical device
3. Grant location permissions when prompted
4. Start swiping on restaurants!

## Features Working Right Now

✅ **Location Services** - Automatically detects your location  
✅ **Swipe Interface** - Swipe right to like, left to pass  
✅ **Favorites System** - Persistent storage of liked restaurants  
✅ **Radius Selection** - Choose search radius from 1-25 miles  
✅ **Restaurant Details** - Tap info button for detailed view  
✅ **Mock Data** - 15 realistic restaurants with actual images  
✅ **Haptic Feedback** - Feels responsive and native  
✅ **Pull to Refresh** - Refresh restaurant list  
✅ **Tab Navigation** - Switch between Discover and Favorites  

## Optional: Real Restaurant Data with Yelp API

To use live restaurant data instead of mock data:

### Step 1: Get Yelp API Key
1. Visit [Yelp Fusion API](https://www.yelp.com/developers/v3/manage_app)
2. Create a developer account
3. Create a new app to get your API key

### Step 2: Configure API Key
1. Open `RestaurantSwipe/Configuration/APIConfiguration.swift`
2. Replace `"YOUR_YELP_API_KEY_HERE"` with your actual API key
3. Save the file

### Step 3: Build and Run
The app will automatically use live Yelp data once the API key is configured!

## Device Requirements

- iOS 17.0+ (for SwiftUI features)
- Xcode 15.0+
- Location services enabled
- Internet connection (for real API data and images)

## Troubleshooting

**Location not working?**
- Make sure location permissions are granted
- Test on a physical device for best results
- Check that location services are enabled in Settings

**Images not loading?**
- Ensure internet connection
- Images will show loading indicator then fallback if failed

**Want to test without Yelp API?**
- The app works perfectly with mock data
- Mock data includes 15 diverse restaurants with real food images

## Architecture Highlights

- **MVVM Pattern** with SwiftUI and Combine
- **Environment Objects** for clean state management
- **Async/Await** for modern Swift concurrency
- **UserDefaults** for simple data persistence
- **Core Location** for location services
- **Modular Design** - easy to extend and modify

The app is production-ready and can be enhanced with features like CloudKit sync, user accounts, social features, and more!
