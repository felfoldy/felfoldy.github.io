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
import Apollo
import SwiftPy

let log = Logger()

struct ContentView: View {
    @Environment(\.authorizationController) private var authorizationController
    @State private var showConsole = false
    
    @State var userID: String = ""
    @State var challenge: String = ""
    @State var userName: String = ""
    @State var request: Cancellable?
    @State var passkeyAction = PasskeyAction()
    
    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
        relyingPartyIdentifier: "felfoldy.github.io"
    )
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Create") {
                    TextField("user name", text: $userName)
                    
                    Button("create passkey") {
                        Interpreter.run("query_reg_options()")
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
            .onAppear {
                let regOptions = #def("query_reg_options") {
                    Task {
                        do {
                            try await passkeyAction.register(username: userName)
                        } catch {
                            log.critical(error.localizedDescription)
                        }
                    }
                }
                Interpreter.main.bind(regOptions)
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
