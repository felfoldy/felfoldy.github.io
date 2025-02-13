//
//  LoginSuccessView.swift
//  PasskeyPOC
//
//  Created by Tibor Felföldy on 2025-02-11.
//

import SwiftUI

struct LoginSuccessView: View {
    let userID: String
    
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 160))
                .foregroundStyle(.green)
            
            Text("Login successful")
                .font(.largeTitle)
            
            Text("User ID:")
            Text(userID)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginSuccessView(userID: "user id")
}
