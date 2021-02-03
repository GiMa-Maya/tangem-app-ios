//
//  QRCodeView.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 28.08.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import EFQRCode
import UIKit

struct QRCodeView: View {
    let title: String
    let shareString: String
    @State var userBrightness: CGFloat = 0.5
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button("common_done") {
                presentationMode.wrappedValue.dismiss()
            }.padding()
            Spacer()
            VStack {
                VStack(alignment: .center, spacing: 8.0) {
                    HStack {
                        Text(title)
                            .font(Font.system(size: 30.0, weight: .bold, design: .default) )
                            .foregroundColor(Color.tangemTapGrayDark6)
                        Spacer()
                    }
                    Image(uiImage: self.getQrCodeImage(width: 300.0, height: 300.0))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.all, 20.0)
                    Text(shareString)
                        .font(Font.system(size: 13.0, weight: .regular, design: .default) )
                        .foregroundColor(Color.tangemTapGrayDark)
                        .multilineTextAlignment(.center)
                }
                .padding(.all, 20.0)
            }
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20.0)
                    .stroke(Color.tangemTapGrayDark, lineWidth: 1)
            )
            .padding(.horizontal, 12.0)
            Spacer()
        }
        .onAppear {
            self.userBrightness = UIScreen.main.brightness
            UIScreen.main.animateBrightness(from: UIScreen.main.brightness, to: 1.0)
        }
        .onWillDisappear {
            UIScreen.main.animateBrightness(from: UIScreen.main.brightness, to: self.userBrightness)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            UIScreen.main.animateBrightness(from: UIScreen.main.brightness, to: self.userBrightness)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            self.userBrightness = UIScreen.main.brightness
            UIScreen.main.animateBrightness(from: UIScreen.main.brightness, to: 1.0)
        }
        .navigationBarTitle("sdfasf")
    }
    
    
    private func getQrCodeImage(width: CGFloat, height: CGFloat) -> UIImage {
        if let cgImage =  EFQRCode.generate(content: shareString,
                                            size: EFIntSize(width: Int(width), height: Int(height))) {
            return UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
        } else {
            return UIImage.imageWithSize(width: width, height: height, filledWithColor: UIColor.tangemTapBgGray )
        }
    }
}


struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView(title: "Bitcoin Wallet",
                   shareString: "asdjfhaskjfwjb5khjv3kv3lb535345435cdgdcgdgjshdgjkewk345t3")
    }
}
