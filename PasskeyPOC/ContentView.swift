//
//  ContentView.swift
//  PasskeyPOC
//
//  Created by Tibor Felföldy on 2025-01-13.
//

import SwiftUI
import AuthenticationServices
import LogTools
import Apollo

let log = Logger()

struct ContentView: View {
    @State var username: String = ""
    @State var passkeyAction = PasskeyAction()
    
    @State private var loggedInUserId: String?
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email", text: $username)
                
                Button("Register", systemImage: "person.badge.key") {
                    Task {
                        do {
                            let id = try await passkeyAction.register(username: username)
                            loggedInUserId = id
                        } catch {
                            log.critical(error.localizedDescription)
                        }
                    }
                }
                
                Button("Login", systemImage: "person.badge.key") {
                    Task {
                        do {
                            let userId = try await passkeyAction.assert(username: username)
                            loggedInUserId = userId
                        } catch {
                            log.critical(error.localizedDescription)
                        }
                    }
                }
            }
            .padding()
            .textFieldStyle(.roundedBorder)
            .buttonStyle(.borderedProminent)
            .navigationDestination(item: $loggedInUserId) { userId in
                LoginSuccessView(userID: userId)
            }
        }
    }
}

#Preview {
    ContentView()
}
