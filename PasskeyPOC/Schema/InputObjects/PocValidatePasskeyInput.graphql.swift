// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension PasskeyPOC {
  struct PocValidatePasskeyInput: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      session: String,
      response: String
    ) {
      __data = InputDict([
        "session": session,
        "response": response
      ])
    }

    var session: String {
      get { __data["session"] }
      set { __data["session"] = newValue }
    }

    var response: String {
      get { __data["response"] }
      set { __data["response"] = newValue }
    }
  }

}