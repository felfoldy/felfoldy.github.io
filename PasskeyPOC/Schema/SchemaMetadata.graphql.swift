// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol PasskeyPOC_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == PasskeyPOC.SchemaMetadata {}

protocol PasskeyPOC_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == PasskeyPOC.SchemaMetadata {}

protocol PasskeyPOC_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == PasskeyPOC.SchemaMetadata {}

protocol PasskeyPOC_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == PasskeyPOC.SchemaMetadata {}

extension PasskeyPOC {
  typealias SelectionSet = PasskeyPOC_SelectionSet

  typealias InlineFragment = PasskeyPOC_InlineFragment

  typealias MutableSelectionSet = PasskeyPOC_MutableSelectionSet

  typealias MutableInlineFragment = PasskeyPOC_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "Mutation": return PasskeyPOC.Objects.Mutation
      case "PocGetPasskeyAuthenticationOptionsPayload": return PasskeyPOC.Objects.PocGetPasskeyAuthenticationOptionsPayload
      case "PocGetPasskeyRegistrationOptionsPayload": return PasskeyPOC.Objects.PocGetPasskeyRegistrationOptionsPayload
      case "PocSavePasskeyPayload": return PasskeyPOC.Objects.PocSavePasskeyPayload
      case "PocValidatePasskeyPayload": return PasskeyPOC.Objects.PocValidatePasskeyPayload
      case "Query": return PasskeyPOC.Objects.Query
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}