// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PasskeyPOC {
  class PocValidatePasskeyMutation: GraphQLMutation {
    static let operationName: String = "PocValidatePasskey"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation PocValidatePasskey($verifyinput: PocValidatePasskeyInput!) { pocValidatePasskey(input: $verifyinput) { __typename verified } }"#
      ))

    public var verifyinput: PocValidatePasskeyInput

    public init(verifyinput: PocValidatePasskeyInput) {
      self.verifyinput = verifyinput
    }

    public var __variables: Variables? { ["verifyinput": verifyinput] }

    struct Data: PasskeyPOC.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PasskeyPOC.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("pocValidatePasskey", PocValidatePasskey.self, arguments: ["input": .variable("verifyinput")]),
      ] }

      /// Passkey Authentication checking step
      var pocValidatePasskey: PocValidatePasskey { __data["pocValidatePasskey"] }

      /// PocValidatePasskey
      ///
      /// Parent Type: `PocValidatePasskeyPayload`
      struct PocValidatePasskey: PasskeyPOC.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PasskeyPOC.Objects.PocValidatePasskeyPayload }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("verified", Bool.self),
        ] }

        var verified: Bool { __data["verified"] }
      }
    }
  }

}