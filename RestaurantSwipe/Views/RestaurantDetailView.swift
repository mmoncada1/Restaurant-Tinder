import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @EnvironmentObject var favoritesStore: FavoritesStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to SF
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header image
                    AsyncImage(url: URL(string: restaurant.imageURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(height: 250)
                    .clipped()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Restaurant name and rating
                        VStack(alignment: .leading, spacing: 8) {
                            Text(restaurant.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack {
                                // Rating stars
                                HStack(spacing: 2) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: index < Int(restaurant.rating) ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                            .font(.subheadline)
                                    }
                                }
                                
                                Text(String(format: "%.1f", restaurant.rating))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                // Favorite button
                                Button(action: {
                                    favoritesStore.toggleFavorite(restaurant)
                                }) {
                                    Image(systemName: favoritesStore.isFavorite(restaurant) ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(favoritesStore.isFavorite(restaurant) ? .red : .gray)
                                }
                            }
                        }
                        
                        // Categories
                        if !restaurant.categories.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cuisine")
                                    .font(.headline)
                                
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 100), spacing: 8)
                                ], spacing: 8) {
                                    ForEach(restaurant.categories, id: \.self) { category in
                                        Text(category)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        
                        // Location info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location")
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(restaurant.address)
                                        .font(.subheadline)
                                    Text(restaurant.formattedDistance + " away")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        
                        // Mini map (placeholder for now)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Map")
                                .font(.headline)
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 150)
                                .overlay(
                                    VStack {
                                        Image(systemName: "map")
                                            .font(.system(size: 40))
                                            .foregroundColor(.gray)
                                        Text("Map view coming soon")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                )
                        }
                        
                        // Action buttons
                        VStack(spacing: 12) {
                            if let urlString = restaurant.url, let url = URL(string: urlString) {
                                Button(action: {
                                    UIApplication.shared.open(url)
                                }) {
                                    HStack {
                                        Image(systemName: "safari")
                                        Text("View on Yelp")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            
                            // Directions button (placeholder)
                            Button(action: {
                                // This would open Apple Maps with directions
                                let address = restaurant.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                if let url = URL(string: "http://maps.apple.com/?q=\(address)") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "car")
                                    Text("Get Directions")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RestaurantDetailView(restaurant: Restaurant.sample)
        .environmentObject(FavoritesStore())
}
