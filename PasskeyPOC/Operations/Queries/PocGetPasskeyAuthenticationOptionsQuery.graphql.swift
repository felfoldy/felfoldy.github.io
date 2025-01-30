// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension PasskeyPOC {
  class PocGetPasskeyAuthenticationOptionsQuery: GraphQLQuery {
    static let operationName: String = "PocGetPasskeyAuthenticationOptions"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query PocGetPasskeyAuthenticationOptions($authinput: PocGetPasskeyAuthenticationOptionsInput!) { pocGetPasskeyAuthenticationOptions(input: $authinput) { __typename session options } }"#
      ))

    public var authinput: PocGetPasskeyAuthenticationOptionsInput

    public init(authinput: PocGetPasskeyAuthenticationOptionsInput) {
      self.authinput = authinput
    }

    public var __variables: Variables? { ["authinput": authinput] }

    struct Data: PasskeyPOC.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { PasskeyPOC.Objects.Query }
      static var __selections: [ApolloAPI.Selection] { [
        .field("pocGetPasskeyAuthenticationOptions", PocGetPasskeyAuthenticationOptions.self, arguments: ["input": .variable("authinput")]),
      ] }

      /// Passkey Authentication options step
      var pocGetPasskeyAuthenticationOptions: PocGetPasskeyAuthenticationOptions { __data["pocGetPasskeyAuthenticationOptions"] }

      /// PocGetPasskeyAuthenticationOptions
      ///
      /// Parent Type: `PocGetPasskeyAuthenticationOptionsPayload`
      struct PocGetPasskeyAuthenticationOptions: PasskeyPOC.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { PasskeyPOC.Objects.PocGetPasskeyAuthenticationOptionsPayload }
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