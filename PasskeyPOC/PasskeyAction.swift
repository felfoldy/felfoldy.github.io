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
    
    func register(username: String) async throws {
        // MARK: GetPasskeyRegistrationOptions

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
        
        let option = try JSONDecoder().decode(PasskeyRegistrationOption.self, from: optionsData)
        
        guard let challengeData = option.challenge.data(using: .utf8),
              let userID = option.user.id.data(using: .utf8) else {
            throw URLError(.unknown)
        }
        
        // MARK: CredentialRegistration
        let request = platformProvider.createCredentialRegistrationRequest(
            challenge: challengeData,
            name: option.user.name,
            userID: userID
        )
        
        let controller = await ASController(authorizationRequests: [request])
        controller.performRequests()
        let credentials = try await controller.credentials()
        
        guard let registrationCredentials = credentials as? ASAuthorizationPlatformPublicKeyCredentialRegistration else {
            throw URLError(.unknown)
        }
        
        // MARK: SavePasskey
        
        guard let attestationObject = registrationCredentials.rawAttestationObject else {
            throw URLError(.unknown)
        }
        
        let jsonDictionary: [String: Any] = [
            "id": registrationCredentials.credentialID.base64EncodedString(),
            "rawId": registrationCredentials.credentialID.base64EncodedString(),
            "response": [
                "clientDataJSON": registrationCredentials.rawClientDataJSON.base64EncodedString(),
                "attestationObject": attestationObject.base64EncodedString()
            ],
            "type": "public-key",
            "authenticatorAttachment": "platform",
            "clientExtensionResults": [String: Any](),
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: jsonDictionary)
        
        guard let json = String(data: jsonData, encoding: .utf8) else {
            throw URLError(.unknown)
        }
        
        let mutation = PasskeyPOC.PocSavePasskeyMutation(saveinput: .init(
            session: options.session,
            response: json
        ))
        
        let mutationResult = await withCheckedContinuation { continuation in
            apolloClient.perform(mutation: mutation) { result in
                continuation.resume(returning: result)
            }
        }
        
        guard case let .success(response) = mutationResult,
            response.data?.pocSavePasskey.verified == true else {
            log.critical("Not verified!")
            throw URLError(.unknown)
        }
        
        log.info("Verified!!!!")
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
