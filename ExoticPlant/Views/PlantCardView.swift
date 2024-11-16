//
//  PlantCardView.swift
//  ExoticPlant
//
//  Created by Juan Chung on 2024-11-08.
//

import SwiftUI

struct PlantCardView: View {
    let plant: ExoticPlant
    let index: Int
    let currentIndex: Int
    let dragOffset: CGFloat
    let totalCount: Int  // Add this to handle wrapping
    
    var body: some View {
        let isCurrentIndex = currentIndex == index
        let opacity = isCurrentIndex ? 1.0 : 0.5
        let scale: CGFloat = isCurrentIndex ? 1.0 : 0.85
        
        // Calculate wrapped offset for infinite scrolling
        let wrappedOffset = calculateWrappedOffset()
        let rotationAngle = isCurrentIndex ? 0.0 : (wrappedOffset < 0 ? -0.05 : 0.05)
        
        ZStack(alignment: .bottom) {
            if let imageData = Data(base64Encoded: plant.image ?? ""),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 450)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 10)
            } else {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 300, height: 450)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    )
            }
        }
        .opacity(opacity)
        .scaleEffect(scale)
        .offset(x: wrappedOffset + dragOffset)
        .rotation3DEffect(
            .degrees(Double(dragOffset / 20)),
            axis: (x: 0, y: 1, z: 0)
        )
        .rotation3DEffect(
            .degrees(Double(rotationAngle * 180)),
            axis: (x: 0, y: 1, z: 0)
        )
    }
    
    private func calculateWrappedOffset() -> CGFloat {
        guard totalCount > 0 else { return 0 }
        
        // Calculate the direct offset
        let directOffset = CGFloat(index - currentIndex) * 320
        
        // Calculate wrapped offsets
        let rightWrappedOffset = directOffset - CGFloat(totalCount) * 320
        let leftWrappedOffset = directOffset + CGFloat(totalCount) * 320
        
        // Choose the offset that results in the shortest distance
        let possibleOffsets = [directOffset, rightWrappedOffset, leftWrappedOffset]
        return possibleOffsets.min(by: { abs($0) < abs($1) }) ?? directOffset
    }
}

//#Preview {
//    NavigationStack {
//        PlantCardView(
//            plant: ExoticPlant(id: 1, name: "Sample Plant", description: "Sample Description", countries: "Sample Country", image: nil),
//            index: 0,
//            currentIndex: 0,
//            dragOffset: 0
//        )
//    }
//}
