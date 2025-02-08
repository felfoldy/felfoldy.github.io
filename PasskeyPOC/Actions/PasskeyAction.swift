//
//  PasskeyAction.swift
//  PasskeyPOC
//
//  Created by Tibor Felföldy on 2025-01-30.
//

import Apollo
import Foundation
import SwiftPy
import AuthenticationServices

struct PasskeyRegistration {
    let session: String
    let option: PasskeyRegistrationOption
}

struct PasskeyRegistrationOption: Codable {
    struct User: Codable {
        let id: String
        let name: String
    }
    
    let challenge: String
    let user: User
    
    var rawChallengeData: Data? {
        Data(base64Encoded: challenge)
    }
}

struct PasskeyAuthentication {
    let session: String
    let option: PasskeyAuthenticationOption
}

struct PasskeyAuthenticationOption: Codable {
    let challenge: String

    var rawChallengeData: Data? {
        Data(base64Encoded: challenge)
    }
}

class PasskeyAction {
    let apolloClient = ApolloClient(url: URL(string: "http://localhost:3000/graphql")!)
    
    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
        relyingPartyIdentifier: "felfoldy.github.io"
    )
    
    func register(username: String) async throws -> Bool {
        let registration = try await getPasskeyRegistrationOptions(username: username)
        
        let credentials = try await PasskeyServices.registerPasskey(option: registration.option)
        
        return try await savePasskey(session: registration.session, credentials: credentials)
    }
    
    func assert(username: String) async throws {
        let authentication = try await getPasskeyAuthOptions(username: username)
        
        let credential = try await PasskeyServices.assertPasskey(challenge: authentication.option.challenge)
        
        try await validatePasskey(session: authentication.session, credential: credential)
    }
}

// MARK: - Assert

private extension PasskeyAction {
    func getPasskeyAuthOptions(username: String) async throws -> PasskeyAuthentication {
        log.info("Query GetPasskeyAuthenticationOptions")

        let query = PasskeyPOC.PocGetPasskeyAuthenticationOptionsQuery(
            authinput: .init(username: username, challenge: "challenge")
        )

        let result = await withCheckedContinuation { continuation in
            apolloClient.fetch(query: query) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard case let .success(response) = result,
              let options = response.data?.pocGetPasskeyAuthenticationOptions,
              let optionsData = Data(base64Encoded: options.options) else {
            throw URLError(.unknown)
        }
        
        logJson("GetPasskeyRegistrationOptions response", data: optionsData)
        
        let option = try JSONDecoder().decode(PasskeyAuthenticationOption.self, from: optionsData)
        
        return PasskeyAuthentication(session: options.session, option: option)
    }
    
    func validatePasskey(session: String, credential: ASAuthorizationPublicKeyCredentialAssertion) async throws {
        let id = credential.credentialID.base64EncodedString()
        
        logJson("clientDataJSON", data: credential.rawClientDataJSON)
        
        let jsonDictionary: [String: Any] = [
            "id": id,
            "rawId": id,
            "response": [
                "clientDataJSON": credential.rawClientDataJSON.base64EncodedString(),
                "authenticatorData": credential.rawAuthenticatorData.base64EncodedString(),
                "signature": credential.signature.base64EncodedString(),
            ],
            "clientExtensionResults": [String: Any](),
            "type": "public-key",
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)

        guard let json = String(data: jsonData, encoding: .utf8) else {
            throw URLError(.unknown)
        }
        
        log.trace("ValidatePasskey response json: \(json)")
        
        let mutation = PasskeyPOC.PocValidatePasskeyMutation(verifyinput: .init(
            session: session,
            response: json
        ))
        
        let mutationResult = await withCheckedContinuation { continuation in
            apolloClient.perform(mutation: mutation) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard case let .success(response) = mutationResult,
              let verified = response.data?.pocValidatePasskey else {
            throw URLError(.unknown)
        }
        
        log.critical("Is verified: \(verified)")
    }
}

// MARK: - Registrations

private extension PasskeyAction {
    func getPasskeyRegistrationOptions(username: String) async throws -> PasskeyRegistration {
        log.info("Query GetPasskeyRegistrationOptions")
        
        let challengeData = Data("challenge".utf8).base64EncodedString()

        let query = PasskeyPOC.PocGetPasskeyRegistrationOptionsQuery(
            reginput: .init(username: username,
                            challenge: challengeData)
        )
        
        let result = await withCheckedContinuation { continuation in
            apolloClient.fetch(query: query) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard case let .success(response) = result,
              let options = response.data?.pocGetPasskeyRegistrationOptions,
              let optionsData = Data(base64Encoded: options.options) else {
            throw URLError(.unknown)
        }

        logJson("GetPasskeyRegistrationOptions response", data: optionsData)

        let option = try JSONDecoder().decode(PasskeyRegistrationOption.self, from: optionsData)
        return PasskeyRegistration(session: options.session, option: option)
    }

    func savePasskey(session: String, credentials: ASAuthorizationPlatformPublicKeyCredentialRegistration) async throws -> Bool {
        log.info("Query SavePasskey")
        
        let id = credentials.credentialID.base64EncodedString()
        
        logJson("clientDataJSON", data: credentials.rawClientDataJSON)
        
        let jsonDictionary: [String: Any] = [
            "id": id,
            "rawId": id,
            "response": [
                "clientDataJSON": credentials.rawClientDataJSON.base64EncodedString(),
                "attestationObject": credentials.rawAttestationObject?.base64EncodedString()
            ],
            "clientExtensionResults": [String: Any](),
            "type": "public-key",
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        
        guard let json = String(data: jsonData, encoding: .utf8) else {
            return false
        }
        
        log.trace("SavePasskey response json: \(json)")
        
        let mutation = PasskeyPOC.PocSavePasskeyMutation(saveinput: .init(
            session: session,
            response: json
        ))
        
        let mutationResult = await withCheckedContinuation { continuation in
            apolloClient.perform(mutation: mutation) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard case let .success(response) = mutationResult,
            let verified = response.data?.pocSavePasskey.verified else {
            throw URLError(.unknown)
        }
        
        log.critical("isVerified: \(verified)")
        return verified
    }
    
    func logJson(_ title: String, data: Data) {
        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            log.info("\(title): \(jsonString)")
        }
    }
}
