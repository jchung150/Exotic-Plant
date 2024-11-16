//
//  NetworkManager.swift
//  ExoticPlant
//
//  Created by Kyoungran Park on 2024-11-05.
//
import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
//    private let baseURL = "http://localhost:5285/api/Plants"  // Replace with Ngrok or production URL as needed
    private let baseURL = "https://exotic-plants-addxbmdedadgfnac.canadacentral-01.azurewebsites.net/api/Plants"

    private init() {}

    func fetchPlants() -> AnyPublisher<[ExoticPlant], Error> {
        guard let url = URL(string: baseURL) else { fatalError("Invalid URL") }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [ExoticPlant].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func addPlant(_ plant: ExoticPlant) -> AnyPublisher<ExoticPlant, Error> {
        guard let url = URL(string: baseURL) else { fatalError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(plant)

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: ExoticPlant.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func updatePlant(_ plant: ExoticPlant) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)/\(plant.id)") else { fatalError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(plant)

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in () }
            .receive(on: DispatchQueue.main)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func deletePlant(id: Int) -> AnyPublisher<Void, Error> {
        guard let url = URL(string: "\(baseURL)/\(id)") else { fatalError("Invalid URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { _ in () }
            .receive(on: DispatchQueue.main)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
