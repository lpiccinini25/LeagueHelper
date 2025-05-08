//
//  CircleImage.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/7/25.
//

import SwiftUI

struct CircleImage: View {
    let Icon: UIImage
    var body: some View {
        Image(uiImage: Icon)
            .resizable()                    // Make the image resizable
            .aspectRatio(contentMode: .fill) // Fill the circle frame
            .frame(width: 200, height: 200)  // Set a desired size
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
            .shadow(radius: 7)
    }
}
