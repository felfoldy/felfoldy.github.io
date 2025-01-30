// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PasskeyPOC {
  struct PocGetPasskeyRegistrationOptionsInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      username: String,
      challenge: String,
      credentials: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "username": username,
        "challenge": challenge,
        "credentials": credentials
      ])
    }

    var username: String {
      get { __data["username"] }
      set { __data["username"] = newValue }
    }

    var challenge: String {
      get { __data["challenge"] }
      set { __data["challenge"] = newValue }
    }

    var credentials: GraphQLNullable<String> {
      get { __data["credentials"] }
      set { __data["credentials"] = newValue }
    }
  }

}