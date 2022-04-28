//
//  BackgroundImageMoveAndScale.swift
//  iOSImageCropperSwiftUI
//
//  Created by Леонид on 28.04.2022.
//

import SwiftUI

struct BackgroundImageMoveAndScale: View {
    
    @Environment(\.dismiss) var presentationMode
    
    @State private var isShowingCamera = false
    @State private var isShowingImagePicker = false
    var imageType: ImageType
    
    @Binding var croppedImage: UIImage?
    @State private var inputImage: UIImage?
    @State private var profileImage: Image?
    @State private var currentAmount: CGFloat = 0
    @State private var finalAmount: CGFloat = 1
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var inputW: CGFloat = 0
    @State private var inputH: CGFloat = 0
    @State private var profileW: CGFloat = 0.0
    @State private var profileH: CGFloat = 0.0
    @State private var iAspect: CGFloat = 0.0
    @State private var horizontalOffset: CGFloat = 0.0
    @State private var verticalOffset: CGFloat = 0.0
    @State private var maskYEdgeDefalt: CGFloat = UIScreen.main.bounds.height / 2.8
    @State private var maskYSize: CGFloat = UIScreen.main.bounds.width > 320.0 ? 230.0 : 200.0
    let uAspect = UIScreen.main.bounds.width / UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            ZStack {
                Color.black.opacity(0.8)
                if profileImage != nil {
                    profileImage?
                        .resizable()
                        .scaleEffect(finalAmount + currentAmount)
                        .scaledToFill()
                        .aspectRatio(contentMode: .fit)
                        .offset(x: self.currentPosition.width, y: self.currentPosition.height)
                }
                VStack(spacing: 0) {
                    Color.black.opacity(0.7)
                    Color.clear
                        .frame(height: maskYSize)
                        .border(Color.white)
                    Color.black.opacity(0.7)
                }
            }
            VStack {
                HStack {
                    Button {
                        presentationMode()
                    } label: {
                        Image(systemName: "multiply")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    .padding(.top, 50)
                    Spacer()
                    Text("Select photo area")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(.top, 50)
                    Spacer()
                }
                
                Spacer()
                HStack{
                    Button(
                        action: {
                            self.save()
                            presentationMode()
                        })
                    {
                        Text("Save photo")
                            .font(.title2)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.all, 15)
                        
                    }
                    .opacity((profileImage != nil) ? 1.0 : 0.2)
                    .disabled((profileImage != nil) ? false: true)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.bottom, 5)
                }
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
        .gesture(
            MagnificationGesture()
                .onChanged { amount in
                    self.currentAmount = amount - 1
                }
                .onEnded { amount in
                    self.finalAmount += self.currentAmount
                    self.currentAmount = 0
                    repositionImage()
                }
        )
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                }
                .onEnded { value in
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                    self.newPosition = self.currentPosition
                    repositionImage()
                }
        )
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded({
                    resetImageOriginAndScale()
                })
        )
        .sheet(isPresented: $isShowingCamera, onDismiss: loadImage) {
#if targetEnvironment(simulator)
#else
            CameraPicker(selectedImage: $inputImage, sourceType: .camera)
#endif
            
        }
        .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
        .onAppear {
            if imageType == .camera {
                isShowingCamera = true
            } else {
                isShowingImagePicker = true
            }
        }
    }
    
    private func loadImage() {
        if inputImage == nil {
            presentationMode()
        }
        guard let inputImage = inputImage else { return }
        let w = inputImage.size.width
        let h = inputImage.size.height
        profileImage = Image(uiImage: inputImage)
        
        iAspect = w / h
        
        if iAspect >= uAspect { ///If inputImage bigger than userScreen
            profileW = UIScreen.main.bounds.width
            profileH = profileW / iAspect ///fit height for a width
        } else { ///If inputImage smaller than userScreen
            profileH = UIScreen.main.bounds.height
            profileW = profileH * iAspect ///fit width for a height
        }
        inputW = profileW
        inputH = profileH
        
        resetImageOriginAndScale()
    }
    private func resetImageOriginAndScale() {
        withAnimation(.easeInOut){
            if iAspect >= uAspect { ///If inputImage bigger than userScreen
                profileW = UIScreen.main.bounds.width
                profileH = profileW / iAspect ///fit height for a width
            } else { ///If inputImage smaller than userScreen
                profileH = UIScreen.main.bounds.height
                profileW = profileH * iAspect ///fit width for a height
                ///profileW = UIScreen.main.bounds.width
                //                profileH = profileW / iAspect
            }
            currentAmount = 0
            finalAmount = 1
            currentPosition = .zero
            newPosition = .zero
        }
    }
    
    private func repositionImage() {
        
        
        if iAspect > uAspect { ///if image after zooming become bigger than screen
            profileW = UIScreen.main.bounds.width * finalAmount /// increase width on fAmount
            profileH = profileW / iAspect ///fit height for a width
        } else { ///if image after zooming become smaller than screen
            profileH = UIScreen.main.bounds.height * finalAmount /// increase height on fAmount
            profileW = profileH * iAspect ///fit width for a height
        }
        
        horizontalOffset = (profileW - UIScreen.main.bounds.width ) / 2
        verticalOffset = (profileH - maskYSize) / 2
        
        
        ///Keep the user from zooming too far in. Adjust as required by the individual project.
        if finalAmount > 4.0 {
            withAnimation{
                finalAmount = 4.0
            }
        }
        if currentPosition.width > horizontalOffset {
            withAnimation(.easeInOut) {
                newPosition = CGSize(width: horizontalOffset, height: newPosition.height)
                currentPosition = CGSize(width: horizontalOffset, height: currentPosition.height)
            }
        }
        if currentPosition.width < ( horizontalOffset * -1) {
            withAnimation(.easeInOut) {
                newPosition = CGSize(width: ( horizontalOffset * -1), height: newPosition.height)
                currentPosition = CGSize(width: ( horizontalOffset * -1), height: currentPosition.height)
            }
        }
        if currentPosition.height >= verticalOffset {
            withAnimation(.easeInOut) {
                newPosition = CGSize(width: newPosition.width, height: verticalOffset)
                currentPosition = CGSize(width: currentPosition.width, height: verticalOffset)
            }
        }
        if currentPosition.height <= ( verticalOffset * -1) {
            withAnimation(.easeInOut) {
                newPosition = CGSize(width: newPosition.width, height: ( verticalOffset * -1))
                currentPosition = CGSize(width: currentPosition.width, height: ( verticalOffset * -1))
            }
        }
        if finalAmount != 1.0 {
            if profileW <= UIScreen.main.bounds.width && iAspect >= uAspect {
                resetImageOriginAndScale()
            }
            if profileH <= UIScreen.main.bounds.height && iAspect <= uAspect {
                resetImageOriginAndScale()
            }
        }
    }
    
    private func save() {
        let scale = (inputImage?.size.width)! / profileW
        
        let xPos = ( ( ( profileW - UIScreen.main.bounds.width ) / 2 ) + ( currentPosition.width * -1 ) ) * scale
        let yPos = ( ( ( profileH - maskYSize ) / 2 ) + ( currentPosition.height * -1 ) ) * scale
        
        let height = maskYSize * scale
        let width = UIScreen.main.bounds.width * scale
        
        croppedImage = ImageCropper(image: inputImage!, croppedTo: CGRect(x: xPos, y: yPos, width: width, height: height))
        
        //DEBUG MATH
        print("Input: w \(inputW) h \(inputH)")
        print("Mask: w \(UIScreen.main.bounds.width) h \(maskYSize)")
        print("Profile: w \(profileW) h \(profileH)")
        print("UScreen: w \(UIScreen.main.bounds.width) h \(UIScreen.main.bounds.height)")
        print("Amount: current \(currentAmount) final \(finalAmount)")
        print("AspectRatio: iAspect \(iAspect) UAspect \(uAspect)")
        print("Curent Pos: \(currentPosition.debugDescription)")
        print("PosXY: X \(xPos) Y\(yPos)")
        print("ImageWH: W \(inputImage!.size.width) Y \(inputImage!.size.height)")
        print("Scale: \(scale)")
        print("New Position: \(newPosition.debugDescription)")
        print("Mask Y offset: \(UIScreen.main.bounds.height / 3)")
        print("verticalOffset \(verticalOffset)")
    }
}
