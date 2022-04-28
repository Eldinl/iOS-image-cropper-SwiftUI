//
//  ContentView.swift
//  iOSImageCropperSwiftUI
//
//  Created by Леонид on 28.04.2022.
//

import SwiftUI

enum ImageType {
    case camera
    case gallery
}

struct ContentView: View {
    @State private var finalImage: UIImage?
    @State private var inputImage: UIImage?
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: AvatarView()) {
                    Text("For avatar")
                        .font(.title)
                }
                .padding(.bottom, 50)
                NavigationLink(destination: BackgroundImageView()) {
                    Text("For background image")
                        .font(.title)
                }
            }.navigationTitle("Image cropper")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
