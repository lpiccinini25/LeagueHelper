//
//  GoalRow.swift
//  LeagueHelper
//
//  Created by Luca Piccinini on 5/3/25.
//

import SwiftUI

struct GoalRow: View {
    
    var goal: Goal
    
    var body: some View {

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if goal.quantitative {
                    Text("\(goal.title) \(String(goal.quantity))")
                        .font(.headline)
                        .foregroundColor(.black)
                        .bold()
                    Spacer()
                } else {
                    Text("\(goal.title)")
                        .font(.headline)
                        .foregroundColor(.black)
                        .bold()
                    Spacer()
                }
            }
            HStack {
                Text("\(goal.successes)").foregroundColor(.green)
                + Text(" vs ")
                + Text("\(goal.fails)").foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.lightGray))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.vertical, 4)
    
    }
    
    
}
