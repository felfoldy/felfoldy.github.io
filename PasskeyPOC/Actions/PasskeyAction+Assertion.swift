//
//  PasskeyAction+Assertion.swift
//  PasskeyPOC
//
//  Created by Tibor Felföldy on 2025-02-08.
//

import Foundation

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

extension PasskeyAction {
    func getPasskeyAuthenticationOptions(username: String) async throws -> PasskeyAuthentication {
        log.info("Query GetPasskeyAuthenticationOptions")

        let challengeData = Data("challenge".utf8).base64EncodedString()
        
        let query = PasskeyPOC.PocGetPasskeyAuthenticationOptionsQuery(
            authinput: .init(username: username, challenge: challengeData)
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
        
        logJson("GetPasskeyAuthenticationOptions response", data: optionsData)
        
        let option = try JSONDecoder().decode(PasskeyAuthenticationOption.self, from: optionsData)
        
        return PasskeyAuthentication(session: options.session, option: option)
    }
    
    func validatePasskey(session: String, credential: AssertionCredential) async throws {
        log.info("Mutate ValidatePasskey")
        
        let id = credential.credentialID.base64EncodedString()
        
        logJson("clientDataJSON", data: credential.rawClientDataJSON)
        
        let jsonDictionary: [String: Any] = [
            "id": id,
            "rawId": id,
            "response": [
                "clientDataJSON": credential.rawClientDataJSON.base64EncodedString(),
                "authenticatorData": credential.rawAuthenticatorData.base64urlEncodedString(),
                "signature": credential.signature.base64urlEncodedString(),
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
              let verified = response.data?.pocValidatePasskey.verified,
              verified else {
                  throw PasskeyError.verificationFailed
        }
        
        log.critical("Is verified: \(verified)")
    }
}
