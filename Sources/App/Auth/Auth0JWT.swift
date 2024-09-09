import JWTKit
import Vapor

struct Auth0JWT: JWTPayload {

  var sub: SubjectClaim
  var exp: ExpirationClaim

    func verify(using key: some JWTAlgorithm) throws {
        try exp.verifyNotExpired()
    }
}
