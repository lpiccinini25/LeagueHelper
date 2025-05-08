//
//  MatchDetail.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/7/25.
//

import SwiftUI
import UIKit

func fetchChampionIcon(from urlString: String,
                      completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    URLSession.shared.dataTask(with: url) { data, _, error in
        guard let data = data,
              let image = UIImage(data: data),
              error == nil
        else {
            completion(nil)
            return
        }
        DispatchQueue.main.async {
            completion(image)
        }
    }.resume()
}

struct MatchDetail: View {
    @EnvironmentObject var goalService: LeagueHelperGoal
    
    @State private var champIcon: UIImage? = nil
    var match: Match
    
    var body: some View {
        
        VStack {
            ScrollView {
                if let champIcon = champIcon {
                    CircleImage(Icon: champIcon)
                } else {
                    ProgressView()
                        .frame(width: 100, height: 100)
                }
            }
            .onAppear {
                let urlString = "https://ddragon.leagueoflegends.com/cdn/14.24.1/img/champion/\(match.champion).png"
                fetchChampionIcon(from: urlString) { image in
                    self.champIcon = image
                }
            }
            .padding()
        }
    }
}

