import SwiftUI

struct RadiusSelectorView: View {
    @Binding var radius: Double
    let onRadiusChange: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.blue)
                        
                        Text("Search Radius: \(Int(radius)) mi")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("1 mi")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("25 mi")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $radius, in: 1...25, step: 1) {
                        Text("Radius")
                    } minimumValueLabel: {
                        Image(systemName: "location.circle")
                            .foregroundColor(.blue)
                    } maximumValueLabel: {
                        Image(systemName: "location.circle")
                            .foregroundColor(.blue)
                    }
                    .onChange(of: radius) { oldValue, newValue in
                        // Add a small delay to prevent too many API calls while dragging
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onRadiusChange()
                        }
                    }
                    
                    // Quick selection buttons
                    HStack(spacing: 8) {
                        ForEach([1, 3, 5, 10, 15, 25], id: \.self) { distance in
                            Button("\(distance) mi") {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    radius = Double(distance)
                                    onRadiusChange()
                                }
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(radius == Double(distance) ? Color.blue : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(radius == Double(distance) ? .white : .primary)
                        }
                    }
                }
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    RadiusSelectorView(radius: .constant(5.0)) {
        print("Radius changed")
    }
    .padding()
}
