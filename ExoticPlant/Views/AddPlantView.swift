//
//  AddPlantView.swift
//  ExoticPlant
//
//  Created by Kyoungran Park on 2024-11-05.
//

import SwiftUI

struct AddPlantView: View {
    @ObservedObject var viewModel: ExoticPlantViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var description = ""
    @State private var countries = ""
    @State private var selectedImage: UIImage? = nil
    @State private var base64Image: String? = nil
    @State private var isShowingImagePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero Image Section
                    ZStack(alignment: .bottom) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
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
                                Text("Add Photo")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                        }
                        .padding(.bottom, 20)
                    }
                    
                    VStack(spacing: 15) {
                        // Name Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Plant Name")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            TextEditor(text: $name)
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
                                .frame(minHeight: 70)
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
                                .frame(minHeight: 50)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        // Add Button
                        Button(action: addPlant) {
                            Text("Add Plant")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("ButtonColor"))
                                .cornerRadius(15)
                                .shadow(radius: 2)
                        }
                        .padding(.horizontal, 15)
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 10)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Add New Plant")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Image"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func addPlant() {
        guard !name.isEmpty else {
            alertMessage = "Please enter a plant name."
            showAlert = true
            return
        }
        
        guard let selectedImage = selectedImage else {
            alertMessage = "Please select an image."
            showAlert = true
            return
        }
        
        // Resize and validate the image
        if let resizedImage = resizeImageIfNeeded(image: selectedImage, maxWidth: 300),
           let imageData = resizedImage.jpegData(compressionQuality: 0.8) {
            base64Image = imageData.base64EncodedString()
        } else {
            alertMessage = "Image width must not exceed 300px."
            showAlert = true
            return
        }
        
        // Create a new plant
        let newPlant = ExoticPlant(id: 0, name: name, description: description, countries: countries, image: base64Image)
        viewModel.addPlant(newPlant)
        presentationMode.wrappedValue.dismiss()
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

struct AddPlantView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlantView(viewModel: ExoticPlantViewModel())
    }
}
