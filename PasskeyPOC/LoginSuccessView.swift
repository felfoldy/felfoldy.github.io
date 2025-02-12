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
            
            Text("Login successful")
                .font(.largeTitle)
            
            Text("user id: \(userID)")
        }
    }
}

#Preview {
    LoginSuccessView(userID: "user id")
}
