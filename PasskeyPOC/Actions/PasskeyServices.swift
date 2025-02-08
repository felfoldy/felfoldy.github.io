//
//  PasskeyServices.swift
//  PasskeyPOC
//
//  Created by Tibor Felföldy on 2025-02-08.
//

import AuthenticationServices

typealias RegistrationCredential = ASAuthorizationPlatformPublicKeyCredentialRegistration
typealias AssertionCredential = ASAuthorizationPlatformPublicKeyCredentialAssertion

enum PasskeyError: LocalizedError {
    case registrationFailed
    case assertionFailed
    
    var errorDescription: String? {
        switch self {
        case .registrationFailed:
            return "Passkey registration failed"
        case .assertionFailed:
            return "Passkey assertion failed"
        }
    }
}

class PasskeyServices: ASAuthorizationController, ASAuthorizationControllerDelegate {
    var continuation: CheckedContinuation<any ASAuthorizationCredential, any Error>?
    
    override init(authorizationRequests: [ASAuthorizationRequest]) {
        super.init(authorizationRequests: authorizationRequests)
        delegate = self
    }
    
    func credential() async throws -> ASAuthorizationCredential {
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
    
    static let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "felfoldy.github.io")
    
    static func registerPasskey(option: PasskeyRegistrationOption) async throws -> RegistrationCredential {
        log.info("Passkey registration")
        
        guard let challengeData = option.rawChallengeData,
              let userId = option.user.id.data(using: .utf8) else {
            throw PasskeyError.registrationFailed
        }

        let request = platformProvider.createCredentialRegistrationRequest(
            challenge: challengeData,
            name: option.user.name,
            userID: userId
        )
        
        let controller = PasskeyServices(authorizationRequests: [request])
        controller.performRequests()
        let credential = try await controller.credential()
        
        guard let registrationCredential = credential as? RegistrationCredential else {
            throw PasskeyError.registrationFailed
        }
        
        return registrationCredential
    }
    
    static func assertPasskey(challenge: String) async throws -> AssertionCredential {
        log.info("Passkey assertion")
        
        let request = platformProvider.createCredentialAssertionRequest(
            challenge: Data(challenge.utf8)
        )
        
        let controller = PasskeyServices(authorizationRequests: [request])
        controller.performRequests()
        let credential = try await controller.credential()
        
        guard let assertionCredential = credential as? AssertionCredential else {
            throw PasskeyError.assertionFailed
        }
        
        return assertionCredential
    }
}
