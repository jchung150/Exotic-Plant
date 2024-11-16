//
//  DetailView.swift
//  ExoticPlant
//
//  Created by Kyoungran Park on 2024-11-05.
//

import SwiftUI
import Combine

struct DetailView: View {
    @State var plant: ExoticPlant
    @ObservedObject var viewModel: ExoticPlantViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // State variables for handling optional values
    @State private var description: String
    @State private var countries: String
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var showAlert = false
    @State private var showDeleteConfirmation = false
    @State private var alertMessage = ""
    @State private var isDeleting = false

    
    // Initialize state variables with plant data
    init(plant: ExoticPlant, viewModel: ExoticPlantViewModel) {
        self._plant = State(initialValue: plant)
        self._description = State(initialValue: plant.description ?? "")
        self._countries = State(initialValue: plant.countries ?? "")
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Hero Image Section
                ZStack(alignment: .bottom) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                    } else if let base64String = plant.image,
                              let imageData = Data(base64Encoded: base64String),
                              let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.3))
                            .frame(height: 300)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Change Photo")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                    }
                    .padding(.bottom, 20)
                }
                
                VStack(spacing: 10) {
                    // Name Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Plant Name")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextEditor(text: $plant.name)
                            .font(.title2)
                            .frame(minHeight: 40)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Description Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextEditor(text: $description)
                            .font(.title2)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Origin Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Origin")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextEditor(text: $countries)
                            .font(.title2)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Save Button
                    Button(action: savePlant) {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("ButtonColor"))
                            .cornerRadius(15)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal, 15)
                    
                    // Delete Button
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("Delete Plant")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.red)
                            .cornerRadius(15)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal, 15)
                    .disabled(isDeleting)
                }
                .padding(.vertical)
                .padding(.horizontal, 10)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Image"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
        .alert("Delete Plant", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                performDelete()  // Call actual delete here
            }
            .disabled(isDeleting)
        } message: {
            Text("Are you sure you want to delete this plant? This action cannot be undone.")
        }
    }
    
    private func savePlant() {
        // Update plant with edited values
        plant.description = description
        plant.countries = countries
        
        if let selectedImage = selectedImage {
            if let resizedImage = resizeImageIfNeeded(image: selectedImage, maxWidth: 300),
               let imageData = resizedImage.jpegData(compressionQuality: 0.8) {
                plant.image = imageData.base64EncodedString()
            } else {
                alertMessage = "Image width must not exceed 300px."
                showAlert = true
                return
            }
        }
        
        viewModel.updatePlant(plant)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func performDelete() {
        if let index = viewModel.plants.firstIndex(where: { $0.id == plant.id }) {
            viewModel.deletePlant(at: IndexSet([index]))
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func resizeImageIfNeeded(image: UIImage, maxWidth: CGFloat) -> UIImage? {
        if image.size.width > maxWidth {
            let scale = maxWidth / image.size.width
            let newHeight = image.size.height * scale
            UIGraphicsBeginImageContext(CGSize(width: maxWidth, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: maxWidth, height: newHeight))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedImage
        }
        return image
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePlant = ExoticPlant(id: 1, name: "Sample Plant", description: "Sample Description", countries: "Sample Country", image: nil)
        DetailView(plant: samplePlant, viewModel: ExoticPlantViewModel())
    }
}
