//
//  ContentView.swift
//  PasskeyPOC
//
//  Created by Tibor Felföldy on 2025-01-13.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @Environment(\.authorizationController) private var authorizationController
    
    @State var userID: String = ""
    @State var challenge: String = ""
    
    var body: some View {
        VStack {
            
            TextField("userID", text: $userID)
            
            TextField("challenge", text: $challenge)
            
            Button("create passkey") {
                let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "felfoldy.github.io")
                
                let challengeData = challenge.data(using: .utf8)!
                let userIDData = userID.data(using: .utf8)!
                
                let request = platformProvider.createCredentialRegistrationRequest(
                    challenge: challengeData,
                    name: "Some Name",
                    userID: userIDData
                )
                
                performRequest(request: request)
            }
        }
        .padding()
    }
    
    func performRequest(request: ASAuthorizationRequest) {
        Task {
            do {
                let result = try await authorizationController.performRequest(request)
                
                print(result)
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    ContentView()
}
