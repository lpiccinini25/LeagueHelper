//
//  CircleImage.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/7/25.
//

import SwiftUI

struct CircleImage: View {
    let Icon: UIImage
    let width: CGFloat
    let height: CGFloat
    var body: some View {
        Image(uiImage: Icon)
            .resizable()                    // Make the image resizable
            .aspectRatio(contentMode: .fill) // Fill the circle frame
            .frame(width: width, height: height)  // Set a desired size
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
            .shadow(radius: 7)
    }
}
