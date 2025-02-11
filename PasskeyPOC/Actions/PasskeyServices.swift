//
//  PasskeyServices.swift
//  PasskeyPOC
//
//  Created by Tibor Felföldy on 2025-02-08.
//

import AuthenticationServices

typealias RegistrationCredential = ASAuthorizationPlatformPublicKeyCredentialRegistration
typealias AssertionCredential = ASAuthorizationPlatformPublicKeyCredentialAssertion

public extension Data {
    init?(base64urlEncoded input: String) {
        var base64 = input
        base64 = base64.replacingOccurrences(of: "-", with: "+")
        base64 = base64.replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 = base64.appending("=")
        }
        self.init(base64Encoded: base64)
    }

    func base64urlEncodedString() -> String {
        var result = self.base64EncodedString()
        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")
        return result
    }
}

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
    
    static let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "kulcsar-tamas-mbh.github.io")
    
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
    
    static func assertPasskey(option: PasskeyAuthenticationOption) async throws -> AssertionCredential {
        log.info("Passkey assertion")
        
        guard let challengeData = option.rawChallengeData else {
            throw PasskeyError.assertionFailed
        }
        
        let request = platformProvider.createCredentialAssertionRequest(
            challenge: challengeData
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
