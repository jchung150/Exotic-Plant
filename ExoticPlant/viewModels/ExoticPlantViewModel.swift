//
//  ExoticPlantViewModel.swift
//  ExoticPlant
//
//  Created by Kyoungran Park on 2024-11-05.
//

import Foundation
import Combine

class ExoticPlantViewModel: ObservableObject {
    @Published var plants = [ExoticPlant]()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchPlants()
    }
    
    func fetchPlants() {
        NetworkManager.shared.fetchPlants()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching plants: \(error)")
                }
            }, receiveValue: { [weak self] plants in
                self?.plants = plants
            })
            .store(in: &cancellables)
    }
    
    func addPlant(_ plant: ExoticPlant) {
        NetworkManager.shared.addPlant(plant)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error adding plant: \(error)")
                }
            }, receiveValue: { [weak self] newPlant in
                self?.plants.append(newPlant)
            })
            .store(in: &cancellables)
    }
    
    func updatePlant(_ plant: ExoticPlant) {
        NetworkManager.shared.updatePlant(plant)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error updating plant: \(error)")
                }
            }, receiveValue: { [weak self] in
                self?.fetchPlants()
            })
            .store(in: &cancellables)
    }
    
    func deletePlant(at indexSet: IndexSet) {
        indexSet.forEach { index in
            let plant = plants[index]
            NetworkManager.shared.deletePlant(id: plant.id)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error deleting plant: \(error)")
                    }
                }, receiveValue: { [weak self] in
                    self?.plants.remove(at: index)
                })
                .store(in: &cancellables)
        }
    }
}
