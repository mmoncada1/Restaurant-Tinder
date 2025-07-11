import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesStore: FavoritesStore
    @State private var showingDeleteConfirmation = false
    @State private var selectedRestaurant: Restaurant?
    
    var body: some View {
        NavigationView {
            Group {
                if favoritesStore.favorites.isEmpty {
                    EmptyFavoritesView()
                } else {
                    List {
                        ForEach(favoritesStore.favorites) { restaurant in
                            FavoriteRestaurantRow(restaurant: restaurant)
                                .swipeActions(edge: .trailing) {
                                    Button("Remove", role: .destructive) {
                                        selectedRestaurant = restaurant
                                        showingDeleteConfirmation = true
                                    }
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !favoritesStore.favorites.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Clear All Favorites", role: .destructive) {
                                showingDeleteConfirmation = true
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("Remove from Favorites", isPresented: $showingDeleteConfirmation) {
                if let restaurant = selectedRestaurant {
                    Button("Remove", role: .destructive) {
                        favoritesStore.removeFromFavorites(restaurant)
                        selectedRestaurant = nil
                    }
                } else {
                    Button("Clear All", role: .destructive) {
                        favoritesStore.clearAllFavorites()
                    }
                }
                Button("Cancel", role: .cancel) {
                    selectedRestaurant = nil
                }
            } message: {
                if selectedRestaurant != nil {
                    Text("Are you sure you want to remove this restaurant from your favorites?")
                } else {
                    Text("Are you sure you want to remove all restaurants from your favorites?")
                }
            }
        }
    }
}

struct FavoriteRestaurantRow: View {
    let restaurant: Restaurant
    @State private var showingDetail = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Restaurant image
            AsyncImage(url: URL(string: restaurant.imageURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Restaurant info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(restaurant.categoriesString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    // Rating
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    // Distance
                    Text(restaurant.formattedDistance)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 8) {
                Button(action: {
                    showingDetail = true
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
                
                if let urlString = restaurant.url, let url = URL(string: urlString) {
                    Button(action: {
                        UIApplication.shared.open(url)
                    }) {
                        Image(systemName: "safari")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            RestaurantDetailView(restaurant: restaurant)
        }
    }
}

struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start swiping right on restaurants you like to build your favorites list!")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    FavoritesView()
        .environmentObject(FavoritesStore())
}
