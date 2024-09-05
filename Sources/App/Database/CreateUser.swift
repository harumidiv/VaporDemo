import Fluent

struct CreateUser: Migration {

  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema("users")
      .field("id", .int, .identifier(auto: true))
      .field("name", .string, .required)
      .field("email", .string, .required)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema("users").delete()
  }
}
