//
//  AvatarView.swift
//  iOSImageCropperSwiftUI
//
//  Created by Леонид on 28.04.2022.
//

import SwiftUI

struct AvatarView: View {
    @State private var finalImage: UIImage?
    @State private var inputImage: UIImage?
    
    @State private var showingAvatarOptions = false
    @State private var isImagePickerDisplay = false
    @State private var isCameraDisplay = false
    var body: some View {
        VStack {
            if finalImage != nil {
                Image(uiImage: finalImage!)
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            Button("Load avatar") {
                self.showingAvatarOptions = true
            }
            .font(.title)
            .padding(.top, 20)
        }
        .confirmationDialog("Select a new photo", isPresented: $showingAvatarOptions, titleVisibility: .hidden) {
            Button("Select from gallery") {
                self.isImagePickerDisplay = true
            }
            
            Button("Take a new photo") {
                self.isCameraDisplay = true
            }

        }
        .statusBar(hidden: isCameraDisplay)
        .fullScreenCover(isPresented: $isCameraDisplay) {
            AvatarImageMoveAndScale(imageType: .camera, croppedImage: $finalImage)
        }
        .statusBar(hidden: isImagePickerDisplay)
        .fullScreenCover(isPresented: $isImagePickerDisplay, onDismiss: loadImage) {
            AvatarImageMoveAndScale(imageType: .gallery, croppedImage: $finalImage)
        }
    }
    func loadImage() {
        guard let inputImage = inputImage else { return }
        finalImage = inputImage
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView()
    }
}
