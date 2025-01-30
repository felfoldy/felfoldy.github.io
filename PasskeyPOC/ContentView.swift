//
//  ContentView.swift
//  PasskeyPOC
//
//  Created by Tibor Felföldy on 2025-01-13.
//

import SwiftUI
import AuthenticationServices
import LogTools
import SwiftPyConsole

let log = Logger()

struct ContentView: View {
    @Environment(\.authorizationController) private var authorizationController
    @State private var showConsole = false
    
    @State var userID: String = ""
    @State var challenge: String = ""
    @State var userName: String = ""
    
    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
        relyingPartyIdentifier: "felfoldy.github.io"
    )
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Create") {
                    TextField("user name", text: $userName)
                    
                    TextField("userID", text: $userID)
                    
                    TextField("challenge", text: $challenge)
                    
                    Button("create passkey") {
                        let challengeData = challenge.data(using: .utf8)!
                        let userIDData = userID.data(using: .utf8)!
                        
                        let request = platformProvider.createCredentialRegistrationRequest(
                            challenge: challengeData,
                            name: userName,
                            userID: userIDData
                        )
                        
                        log.info("Send create passkey request: \(request)")
                        
                        perform(request: request)
                    }
                }
                
                Section("Assert") {
                    TextField("challenge", text: $challenge)
                    
                    Button("assert passkey") {
                        let challengeData = challenge.data(using: .utf8)!
                        
                        let request = platformProvider.createCredentialAssertionRequest(challenge: challengeData)
                        log.info("Send assert passkey request: \(request)")
                        
                        perform(request: request)
                    }
                }
            }
            .textFieldStyle(.roundedBorder)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("", systemImage: "apple.terminal.fill") {
                        showConsole = true
                    }
                }
            }
            .sheet(isPresented: $showConsole) {
                NavigationStack {
                    PythonConsoleView()
                        .navigationTitle("Console")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    func perform(request: ASAuthorizationRequest) {
        Task {
            do {
                let result = try await authorizationController.performRequest(request)
                
                switch result {
                case .passkeyRegistration(let credential):
                    log.info("credentials: \(credential.debugDescription)")
                    // An identifier that the authenticator generates during registration to uniquely identify a specific credential.
                    credential.credentialID
                    
                    // This object contains the public key. If you request it, it also contains the attestation statement. To learn more, see the W3C Web Authentication specification.
                    credential.rawAttestationObject
                    
                    // This object acts as an input to the signing algorithm. It needs to be in JSON form for the relying party to verify the provided signature. The developer should ignore this value.
                    credential.rawClientDataJSON
                    
                    
                    print("passkey registration: \(credential)")
                case .passkeyAssertion(let credential):
                    credential.credentialID
                    credential.rawAuthenticatorData
                    credential.rawClientDataJSON
                    
                    print("passkey assertion: \(credential.credentialID)")
                default:
                    print(result)
                }
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
