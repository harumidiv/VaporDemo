import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {

  static let schema = "users"

  @ID(custom: "id", generatedBy: .database)
  var id: Int?

  @Field(key: "name")
  var name: String

  @Field(key: "email")
  var email: String

  init() {}

  init(name: String, email: String) {
    self.name = name
    self.email = email
  }
}
