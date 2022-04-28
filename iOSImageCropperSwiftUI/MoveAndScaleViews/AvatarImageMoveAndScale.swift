//
//  AvatarImageMoveAndScale.swift
//  iOSImageCropperSwiftUI
//
//  Created by Леонид on 28.04.2022.
//

import SwiftUI

struct AvatarImageMoveAndScale: View {
    
    @Environment(\.dismiss) var presentationMode
    
    @State private var isShowingCamera = false
    @State private var isShowingImagePicker = false
    var imageType: ImageType
    
    @Binding var croppedImage: UIImage?
    
    @State private var inputImage: UIImage?
    @State private var inputW: CGFloat = 750.5556577
    @State private var inputH: CGFloat = 1336.5556577
    
    @State private var theAspectRatio: CGFloat = 0.0
    
    @State private var profileImage: Image?
    @State private var profileW: CGFloat = 0.0
    @State private var profileH: CGFloat = 0.0
    
    @State private var currentAmount: CGFloat = 0
    @State private var finalAmount: CGFloat = 1
    
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    
    @State private var horizontalOffset: CGFloat = 0.0
    @State private var verticalOffset: CGFloat = 0.0
    
    let inset: CGFloat = 0
    let screenAspect = UIScreen.main.bounds.width / UIScreen.main.bounds.height
    
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
            }
            Rectangle()
                .fill(Color.black).opacity(0.55)
                .mask(HoleShapeMask().fill(style: FillStyle(eoFill: true)))
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
                            //                            isShowingImagePicker = true
                            //                            self.save()
                            //                                presentationMode.wrappedValue.dismiss()
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
    
    private func HoleShapeMask() -> Path {
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let insetRect = CGRect(x: inset, y: inset, width: UIScreen.main.bounds.width - ( inset * 2 ), height: UIScreen.main.bounds.height - ( inset * 2 ))
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: insetRect))
        return shape
    }
    
    private func loadImage() {
        if inputImage == nil {
            presentationMode()
        }
        guard let inputImage = inputImage else { return }
        let w = inputImage.size.width
        let h = inputImage.size.height
        profileImage = Image(uiImage: inputImage)
        
        inputW = w
        inputH = h
        theAspectRatio = w / h
        
        resetImageOriginAndScale()
    }
    
    private func resetImageOriginAndScale() {
        withAnimation(.easeInOut){
            if theAspectRatio >= screenAspect {
                profileW = UIScreen.main.bounds.width
                profileH = profileW / theAspectRatio
            } else {
                profileH = UIScreen.main.bounds.height
                profileW = profileH * theAspectRatio
            }
            currentAmount = 0
            finalAmount = 1
            currentPosition = .zero
            newPosition = .zero
        }
    }
    
    
    private func repositionImage() {
        
        let w = UIScreen.main.bounds.width
        
        if theAspectRatio > screenAspect {
            profileW = UIScreen.main.bounds.width * finalAmount
            profileH = profileW / theAspectRatio
        } else {
            profileH = UIScreen.main.bounds.height * finalAmount
            profileW = profileH * theAspectRatio
        }
        
        horizontalOffset = (profileW - w ) / 2
        verticalOffset = ( profileH - w ) / 2
        
        if finalAmount > 6.0 {
            withAnimation{
                finalAmount = 6.0
            }
        }
        if finalAmount < 1.0 {
            withAnimation{
                finalAmount = 1.0
            }
        }
        
        if profileW >= UIScreen.main.bounds.width {
            
            if newPosition.width > horizontalOffset {
                withAnimation(.easeInOut) {
                    newPosition = CGSize(width: horizontalOffset + inset, height: newPosition.height)
                    currentPosition = CGSize(width: horizontalOffset + inset, height: currentPosition.height)
                }
            }
            
            if newPosition.width < ( horizontalOffset * -1) {
                withAnimation(.easeInOut){
                    newPosition = CGSize(width: ( horizontalOffset * -1) - inset, height: newPosition.height)
                    currentPosition = CGSize(width: ( horizontalOffset * -1 - inset), height: currentPosition.height)
                }
            }
        } else {
            
            withAnimation(.easeInOut) {
                newPosition = CGSize(width: 0, height: newPosition.height)
                currentPosition = CGSize(width: 0, height: newPosition.height)
            }
        }
        
        if profileH >= UIScreen.main.bounds.width {
            
            if newPosition.height > verticalOffset {
                withAnimation(.easeInOut){
                    newPosition = CGSize(width: newPosition.width, height: verticalOffset + inset)
                    currentPosition = CGSize(width: newPosition.width, height: verticalOffset + inset)
                }
            }
            
            if newPosition.height < ( verticalOffset * -1) {
                withAnimation(.easeInOut){
                    newPosition = CGSize(width: newPosition.width, height: ( verticalOffset * -1) - inset)
                    currentPosition = CGSize(width: newPosition.width, height: ( verticalOffset * -1) - inset)
                }
            }
        } else {
            
            withAnimation (.easeInOut){
                newPosition = CGSize(width: newPosition.width, height: 0)
                currentPosition = CGSize(width: newPosition.width, height: 0)
            }
        }
        if finalAmount != 1.0 {
            if profileW <= UIScreen.main.bounds.width && theAspectRatio > screenAspect {
                resetImageOriginAndScale()
            }
            if profileH <= UIScreen.main.bounds.height && theAspectRatio < screenAspect {
                resetImageOriginAndScale()
            }
        }
    }
    
    private func save() {

        let scale = (inputImage?.size.width)! / profileW

        let xPos = ( ( ( profileW - UIScreen.main.bounds.width ) / 2 ) + inset + ( currentPosition.width * -1 ) ) * scale
        let yPos = ( ( ( profileH - UIScreen.main.bounds.width ) / 2 ) + inset + ( currentPosition.height * -1 ) ) * scale
        let radius = ( UIScreen.main.bounds.width - inset * 2 ) * scale
        
        croppedImage = ImageCropper(image: inputImage!, croppedTo: CGRect(x: xPos, y: yPos, width: radius, height: radius))
        
        //Debug maths
        print("Input: w \(inputW) h \(inputH)")
        print("Profile: w \(profileW) h \(profileH)")
        print("X Origin: \( ( ( profileW - UIScreen.main.bounds.width - inset ) / 2 ) + ( currentPosition.width  * -1 ) )")
        print("Y Origin: \( ( ( profileH - UIScreen.main.bounds.width - inset) / 2 ) + ( currentPosition.height  * -1 ) )")

        print("Scale: \(scale)")
        print("Profile:\(profileW) + \(profileH)" )
        print("Curent Pos: \(currentPosition.debugDescription)")
        print("Radius: \(radius)")
        print("x:\(xPos), y:\(yPos)")
    }
}
