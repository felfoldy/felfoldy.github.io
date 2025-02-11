//
//  PasskeyAction+Registration.swift
//  PasskeyPOC
//
//  Created by Tibor Felföldy on 2025-02-08.
//

import Foundation

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

extension PasskeyAction {
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
    
    func savePasskey(session: String, credential: RegistrationCredential) async throws -> Bool {
        log.info("Mutate SavePasskey")
        
        let id = credential.credentialID.base64EncodedString()
        
        logJson("clientDataJSON", data: credential.rawClientDataJSON)
        
        let jsonDictionary: [String: Any] = [
            "id": id,
            "rawId": id,
            "response": [
                "clientDataJSON": credential.rawClientDataJSON.base64EncodedString(),
                "attestationObject": credential.rawAttestationObject?.base64urlEncodedString()
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
