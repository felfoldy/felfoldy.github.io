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
    @State private var username: String = ""
    @State private var loggedInUserId: String?
    private let passkeyAction = PasskeyAction()
    
    @State private var isAlertPresented = false
    @State private var error: Error?
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email", text: $username)
                    .keyboardType(.emailAddress)
                
                Button("Register", systemImage: "person.badge.key") {
                    Task {
                        do {
                            let id = try await passkeyAction.register(username: username)
                            loggedInUserId = id
                        } catch {
                            self.error = error
                            isAlertPresented = true
                        }
                    }
                }
                
                Button("Login", systemImage: "person.badge.key") {
                    Task {
                        do {
                            let userId = try await passkeyAction.assert(username: username)
                            loggedInUserId = userId
                        } catch {
                            self.error = error
                            isAlertPresented = true
                        }
                    }
                }
            }
            .padding()
            .textFieldStyle(.roundedBorder)
            .buttonStyle(.borderedProminent)
            .navigationDestination(item: $loggedInUserId) { userId in
                LoginSuccessView(userID: userId)
                    .tint(.accentColor)
            }
            .alert("Error", isPresented: $isAlertPresented) {
                Button("Ok") {}
            } message: {
                if let errorText = error?.localizedDescription {
                    Text(errorText)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
