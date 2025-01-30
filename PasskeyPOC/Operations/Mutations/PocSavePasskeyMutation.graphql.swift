// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PasskeyPOC {
  class PocSavePasskeyMutation: GraphQLMutation {
    static let operationName: String = "PocSavePasskey"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation PocSavePasskey($saveinput: PocSavePasskeyInput!) { pocSavePasskey(input: $saveinput) { __typename verified } }"#
      ))

    public var saveinput: PocSavePasskeyInput

    public init(saveinput: PocSavePasskeyInput) {
      self.saveinput = saveinput
    }

    public var __variables: Variables? { ["saveinput": saveinput] }

    struct Data: PasskeyPOC.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PasskeyPOC.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] { [
        .field("pocSavePasskey", PocSavePasskey.self, arguments: ["input": .variable("saveinput")]),
      ] }

      /// Passkey Registration saving step
      var pocSavePasskey: PocSavePasskey { __data["pocSavePasskey"] }

      /// PocSavePasskey
      ///
      /// Parent Type: `PocSavePasskeyPayload`
      struct PocSavePasskey: PasskeyPOC.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PasskeyPOC.Objects.PocSavePasskeyPayload }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("verified", Bool.self),
        ] }

        var verified: Bool { __data["verified"] }
      }
    }
  }

}