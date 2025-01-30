// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PasskeyPOC {
  struct PocGetPasskeyAuthenticationOptionsInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      username: String,
      challenge: String
    ) {
      __data = InputDict([
        "username": username,
        "challenge": challenge
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
  }

}