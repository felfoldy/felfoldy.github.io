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
}

class PasskeyAction {
    let apolloClient = ApolloClient(url: URL(string: "http://localhost:3000/graphql")!)
    
    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(
        relyingPartyIdentifier: "felfoldy.github.io"
    )
    
    func register(username: String) async throws -> Bool {
        let registration = try await getPasskeyRegistrationOptions(username: username)
        
        let credentials = try await passkeyRegistrationRequest(option: registration.option)
        
        return try await savePasskey(session: registration.session, credentials: credentials)
    }
}


private extension PasskeyAction {
    func getPasskeyRegistrationOptions(username: String) async throws -> PasskeyRegistration {
        log.info("Query GetPasskeyRegistrationOptions")
        
        let query = PasskeyPOC.PocGetPasskeyRegistrationOptionsQuery(
            reginput: .init(username: username,
                            challenge: "challenge")
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
        
        if let jsonObject = try? JSONSerialization.jsonObject(with: optionsData),
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            log.info("GetPasskeyRegistrationOptions response: \(jsonString)")
        }
        
        let option = try JSONDecoder().decode(PasskeyRegistrationOption.self, from: optionsData)
        return PasskeyRegistration(session: options.session, option: option)
    }
    
    func passkeyRegistrationRequest(option: PasskeyRegistrationOption) async throws -> ASAuthorizationPlatformPublicKeyCredentialRegistration {
        log.info("Passkey registration request")

        let request = platformProvider.createCredentialRegistrationRequest(
            challenge: option.challenge.data(using: .utf8)!,
            name: option.user.name,
            userID: option.user.id.data(using: .utf8)!
        )

        let controller = await ASController(authorizationRequests: [request])
        controller.performRequests()
        let credentials = try await controller.credentials()

        guard let registrationCredentials = credentials as? ASAuthorizationPlatformPublicKeyCredentialRegistration else {
            throw URLError(.unknown)
        }

        return registrationCredentials
    }

    func savePasskey(session: String, credentials: ASAuthorizationPlatformPublicKeyCredentialRegistration) async throws -> Bool {
        log.info("Query SavePasskey")
        
        let id = credentials.credentialID.base64EncodedString()
        
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
}

class ASController: ASAuthorizationController, ASAuthorizationControllerDelegate {
    var continuation: CheckedContinuation<any ASAuthorizationCredential, any Error>?
    
    override init(authorizationRequests: [ASAuthorizationRequest]) {
        super.init(authorizationRequests: authorizationRequests)
        delegate = self
    }
    
    func credentials() async throws -> ASAuthorizationCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation?.resume(returning: authorization.credential)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        continuation?.resume(throwing: error)
    }
}
