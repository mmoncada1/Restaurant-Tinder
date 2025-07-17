import SwiftUI

struct CardStackView: View {
    @EnvironmentObject var restaurantService: RestaurantService
    @EnvironmentObject var favoritesStore: FavoritesStore
    
    @State private var currentIndex = 0
    @State private var showingEndMessage = false
    
    private let maxVisibleCards = 3
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if restaurantService.isLoading {
                    LoadingView()
                } else if let error = restaurantService.error {
                    ErrorView(error: error) {
                        // Retry functionality - we can add this later
                    }
                } else if restaurantService.restaurants.isEmpty && !restaurantService.isLoading {
                    EmptyStateView()
                } else if currentIndex >= restaurantService.restaurants.count {
                    EndOfStackView {
                        resetStack()
                    }
                } else {
                    // Stack of cards
                    ForEach(visibleCardIndices, id: \.self) { index in
                        if index < restaurantService.restaurants.count {
                            RestaurantCardView(restaurant: restaurantService.restaurants[index])
                                .frame(width: geometry.size.width - 40, height: min(geometry.size.height - 100, 500))
                                .scaleEffect(scaleForCard(at: index))
                                .offset(y: offsetForCard(at: index))
                                .zIndex(Double(restaurantService.restaurants.count - index))
                                .opacity(index == currentIndex ? 1.0 : 0.8)
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 40) {
                        // Pass button
                        Button(action: passCurrentRestaurant) {
                            Image(systemName: "xmark")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.red)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        
                        Spacer()
                        
                        // Like button
                        Button(action: likeCurrentRestaurant) {
                            Image(systemName: "heart.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.green)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 40)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 20)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .restaurantLiked)) { notification in
            if let restaurant = notification.object as? Restaurant {
                favoritesStore.addToFavorites(restaurant)
                nextCard()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .restaurantPassed)) { _ in
            nextCard()
        }
    }
    
    private var visibleCardIndices: [Int] {
        let startIndex = currentIndex
        let endIndex = min(startIndex + maxVisibleCards, restaurantService.restaurants.count)
        return Array(startIndex..<endIndex)
    }
    
    private func scaleForCard(at index: Int) -> CGFloat {
        let cardPosition = index - currentIndex
        switch cardPosition {
        case 0:
            return 1.0
        case 1:
            return 0.95
        case 2:
            return 0.9
        default:
            return 0.85
        }
    }
    
    private func offsetForCard(at index: Int) -> CGFloat {
        let cardPosition = index - currentIndex
        return CGFloat(cardPosition * 10)
    }
    
    private func nextCard() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentIndex += 1
        }
    }
    
    private func likeCurrentRestaurant() {
        guard currentIndex < restaurantService.restaurants.count else { return }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        let restaurant = restaurantService.restaurants[currentIndex]
        favoritesStore.addToFavorites(restaurant)
        nextCard()
    }
    
    private func passCurrentRestaurant() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        nextCard()
    }
    
    private func resetStack() {
        currentIndex = 0
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Finding nearby restaurants...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Restaurants Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your search radius or check your location settings.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct ErrorView: View {
    let error: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(error)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
        }
        .padding()
    }
}

struct EndOfStackView: View {
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("You've seen all restaurants!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Check out your favorites or adjust your search radius to discover more.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Search Again") {
                onRestart()
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
        }
        .padding()
    }
}

#Preview {
    CardStackView()
        .environmentObject(RestaurantService())
        .environmentObject(FavoritesStore())
}
