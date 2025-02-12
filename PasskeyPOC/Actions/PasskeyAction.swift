//
//  PasskeyAction.swift
//  PasskeyPOC
//
//  Created by Tibor Felföldy on 2025-01-30.
//

import Apollo
import Foundation
import AuthenticationServices

class PasskeyAction {
    let apolloClient = ApolloClient(url: URL(string: "http://localhost:3000/graphql")!)
    
    func register(username: String) async throws -> String {
        let registration = try await getPasskeyRegistrationOptions(username: username)
        
        let credential = try await PasskeyServices.registerPasskey(option: registration.option)
        
        try await savePasskey(session: registration.session, credential: credential)
        
        return registration.option.user.id
    }
    
    func assert(username: String) async throws -> String {
        let authentication = try await getPasskeyAuthenticationOptions(username: username)
        
        let credential = try await PasskeyServices.assertPasskey(option: authentication.option)
        
        try await validatePasskey(session: authentication.session, credential: credential)
        
        return String(data: credential.userID, encoding: .utf8)!
    }
    
    func logJson(_ title: String, data: Data) {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            log.info("\(title): \(jsonString)")
        }
    }
}
