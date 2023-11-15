//
//  TimestampView.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/16/23.
//

import SwiftUI

// Centered formatted date label for MessageScreen
struct TimestampView: View {
    var date: Date
    
    var body: some View {
        HStack {
            Spacer()
            Text(date.longFormattedString)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            Spacer()
        }
    }
}
