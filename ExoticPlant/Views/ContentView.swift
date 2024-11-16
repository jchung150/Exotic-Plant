//
//  ContentView.swift
//  ExoticPlant
//
//  Created by Kyoungran Park on 2024-11-05.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExoticPlantViewModel()
    @State private var isAddingNewPlant = false
    @State private var currentIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    // Add computed property to ensure safe index
    private var safeCurrentIndex: Int {
        min(max(0, currentIndex), max(0, viewModel.plants.count - 1))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                if viewModel.plants.isEmpty {
                    // Show placeholder when no plants
                    Text("No plants available")
                        .foregroundColor(.gray)
                } else {
                    VStack(spacing: 10) {
                        // Cards Container
                        ZStack {
                            ForEach(viewModel.plants.indices, id: \.self) { index in
                                let plant = viewModel.plants[index]
                                PlantCardView(
                                    plant: plant,
                                    index: index,
                                    currentIndex: safeCurrentIndex,
                                    dragOffset: dragOffset,
                                    totalCount: viewModel.plants.count
                                )
                            }
                        }
                        .frame(height: 500)
                        .gesture(
                            DragGesture()
                                .updating($dragOffset) { value, state, _ in
                                    state = value.translation.width
                                }
                                .onEnded { value in
                                    let threshold: CGFloat = 50
                                    withAnimation(.spring()) {
                                        if value.translation.width > threshold {
                                            currentIndex = currentIndex == 0
                                                ? viewModel.plants.count - 1
                                                : currentIndex - 1
                                        } else if value.translation.width < -threshold {
                                            currentIndex = currentIndex == viewModel.plants.count - 1
                                                ? 0
                                                : currentIndex + 1
                                        }
                                    }
                                }
                        )
                        
                        // Current Plant Info
                        if safeCurrentIndex < viewModel.plants.count {
                            let currentPlant = viewModel.plants[safeCurrentIndex]
                            VStack(spacing: 15) {
                                Text(currentPlant.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                if let description = currentPlant.description {
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(3)
                                        .padding(.horizontal)
                                }
                                
                                NavigationLink(destination: DetailView(plant: currentPlant, viewModel: viewModel)) {
                                    Text("View Details")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 200)
                                        .padding()
                                        .background(Color("ButtonColor"))
                                        .cornerRadius(15)
                                        .shadow(radius: 2)
                                }
                            }
                            .padding(.bottom)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Exotic Plants")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAddingNewPlant = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color("ButtonColor"))
                    }
                }
            }
            .sheet(isPresented: $isAddingNewPlant) {
                AddPlantView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchPlants()
            }
            .onChange(of: viewModel.plants) { _, newValue in
                withAnimation {
                    if currentIndex >= newValue.count {
                        currentIndex = max(0, newValue.count - 1)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
