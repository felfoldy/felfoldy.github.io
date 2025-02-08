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
    @State var username: String = ""
    @State var passkeyAction = PasskeyAction()
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email", text: $username)
                
                Button("Register", systemImage: "person.badge.key") {
                    Interpreter.run("register('\(username)')")
                }
                
                Button("Login", systemImage: "person.badge.key") {
                    
                }
            }
            .padding()
            .textFieldStyle(.roundedBorder)
            .buttonStyle(.borderedProminent)
            .onAppear {
                let regOptions = #def("register(username: str) -> None") { args in
                    let username = String(args[0])!
                    
                    Task {
                        do {
                            try await passkeyAction.register(username: username)
                        } catch {
                            log.critical(error.localizedDescription)
                        }
                    }
                }
                Interpreter.main.bind(regOptions)
            }
        }
    }
}

#Preview {
    ContentView()
}
