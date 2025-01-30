// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PasskeyPOC {
  class PocGetPasskeyRegistrationOptionsQuery: GraphQLQuery {
    static let operationName: String = "PocGetPasskeyRegistrationOptions"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PocGetPasskeyRegistrationOptions($reginput: PocGetPasskeyRegistrationOptionsInput!) { pocGetPasskeyRegistrationOptions(input: $reginput) { __typename session options } }"#
      ))

    public var reginput: PocGetPasskeyRegistrationOptionsInput

    public init(reginput: PocGetPasskeyRegistrationOptionsInput) {
      self.reginput = reginput
    }

    public var __variables: Variables? { ["reginput": reginput] }

    struct Data: PasskeyPOC.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PasskeyPOC.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("pocGetPasskeyRegistrationOptions", PocGetPasskeyRegistrationOptions.self, arguments: ["input": .variable("reginput")]),
      ] }

      /// Passkey Registration options step
      var pocGetPasskeyRegistrationOptions: PocGetPasskeyRegistrationOptions { __data["pocGetPasskeyRegistrationOptions"] }

      /// PocGetPasskeyRegistrationOptions
      ///
      /// Parent Type: `PocGetPasskeyRegistrationOptionsPayload`
      struct PocGetPasskeyRegistrationOptions: PasskeyPOC.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PasskeyPOC.Objects.PocGetPasskeyRegistrationOptionsPayload }
        static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("session", String.self),
          .field("options", String.self),
        ] }

        var session: String { __data["session"] }
        var options: String { __data["options"] }
      }
    }
  }

}