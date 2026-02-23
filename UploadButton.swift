//
//  UploadButton.swift
//  RenalCalculi
//
//  Created by SAIL on 24/11/25.
//

import SwiftUI
struct UploadButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title).bold()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .foregroundColor(.white)
        .background(Color.teal)
        .cornerRadius(12)
    }
}
