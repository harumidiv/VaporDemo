import Vapor

struct UserAuthenticator: AsyncBasicAuthenticator {

  typealias User = App.AuthUser

  func authenticate(
    basic: BasicAuthorization,
    for request: Request
  ) async throws {
    if basic.username == "test" && basic.password == "secret" {
      request.auth.login(User(name: "Vapor"))
    }
  }
}
