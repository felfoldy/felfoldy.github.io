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
    @State var userName: String = ""
    
    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
        relyingPartyIdentifier: "felfoldy.github.io"
    )
    
    var body: some View {
        Form {
            Section("Create") {
                TextField("user name", text: $userName)
                
                TextField("userID", text: $userID)
                
                TextField("challenge", text: $challenge)
                
                Button("create passkey") {
                    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "felfoldy.github.io")
                    
                    let challengeData = challenge.data(using: .utf8)!
                    let userIDData = userID.data(using: .utf8)!
                    
                    let request = platformProvider.createCredentialRegistrationRequest(
                        challenge: challengeData,
                        name: userName,
                        userID: userIDData
                    )
                    
                    perform(request: request)
                }
            }
            
            Section("Assert") {
                TextField("challenge", text: $challenge)
                
                Button("assert passkey") {
                    let challengeData = challenge.data(using: .utf8)!
                    
                    let request = platformProvider.createCredentialAssertionRequest(challenge: challengeData)
                    
                    perform(request: request)
                }
            }
        }
        .textFieldStyle(.roundedBorder)
    }
    
    func perform(request: ASAuthorizationRequest) {
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
