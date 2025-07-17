import SwiftUI

struct RestaurantCardView: View {
    let restaurant: Restaurant
    @State private var dragOffset = CGSize.zero
    @State private var rotationAngle: Double = 0
    @State private var showingDetail = false
    
    private let swipeThreshold: CGFloat = 150
    
    var body: some View {
        ZStack {
            // Main card
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 0) {
                // Restaurant Image
                AsyncImage(url: URL(string: restaurant.imageURL ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("Image unavailable")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            )
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.5)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(height: 200)
                .clipped()
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                        .path(in: CGRect(x: 0, y: 0, width: 1000, height: 200))
                )
                
                // Restaurant Info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(restaurant.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .lineLimit(2)
                            
                            Text(restaurant.categoriesString)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingDetail = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    HStack {
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        // Distance
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text(restaurant.formattedDistance)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Text(restaurant.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding()
            }
            
            // Swipe Indicators
            if abs(dragOffset.width) > 50 {
                VStack {
                    if dragOffset.width > 0 {
                        // Right swipe - Like
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                            .opacity(min(Double(dragOffset.width / swipeThreshold), 1.0))
                    } else {
                        // Left swipe - Pass
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                            .opacity(min(Double(-dragOffset.width / swipeThreshold), 1.0))
                    }
                    Spacer()
                }
                .padding(.top, 40)
            }
        }
        .offset(dragOffset)
        .rotationEffect(.degrees(rotationAngle))
        .scaleEffect(1 - abs(dragOffset.width) / 1000)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation
                    rotationAngle = Double(gesture.translation.width / 20)
                }
                .onEnded { gesture in
                    handleSwipeEnd(gesture: gesture)
                }
        )
        .sheet(isPresented: $showingDetail) {
            RestaurantDetailView(restaurant: restaurant)
        }
    }
    
    private func handleSwipeEnd(gesture: DragGesture.Value) {
        let swipeDistance = gesture.translation.width
        
        if abs(swipeDistance) > swipeThreshold {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Complete the swipe
            let finalOffset: CGFloat = swipeDistance > 0 ? 1000 : -1000
            
            withAnimation(.easeOut(duration: 0.3)) {
                dragOffset.width = finalOffset
                rotationAngle = Double(finalOffset / 20)
            }
            
            // Notify parent about the swipe
            if swipeDistance > 0 {
                NotificationCenter.default.post(name: .restaurantLiked, object: restaurant)
            } else {
                NotificationCenter.default.post(name: .restaurantPassed, object: restaurant)
            }
            
        } else {
            // Snap back
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                dragOffset = .zero
                rotationAngle = 0
            }
        }
    }
}

// Notification names for card swipe events
extension Notification.Name {
    static let restaurantLiked = Notification.Name("restaurantLiked")
    static let restaurantPassed = Notification.Name("restaurantPassed")
}

#Preview {
    RestaurantCardView(restaurant: Restaurant.sample)
        .frame(width: 320, height: 400)
        .padding()
}
