import Vapor

extension Environment {

  static func databaseSocketPath() throws -> String? {
    try? value(for: "DATABASE_SOCKET_PATH")
  }

  static func databaseHost() throws -> String {
    try value(for: "DATABASE_HOST")
  }

  static func databasePort() throws -> Int {
    try value(for: "DATABASE_PORT", using: Int.init)
  }

  static func databaseUsername() throws -> String {
    try value(for: "POSTGRES_USER")
  }

  static func databasePassword() throws -> String {
    try value(for: "POSTGRES_PASSWORD")
  }

  static func databaseName() throws -> String {
    try value(for: "POSTGRES_DB")
  }
}

private extension Environment {

  static func value<T>(
    for key: String,
    using transform: (String) -> T? = { $0 }
  ) throws -> T {
    guard let rawValue = Environment.get(key) else {
      throw Abort(.internalServerError, reason: "\(key) environment variable is missing")
    }
    guard let transformedValue = transform(rawValue) else {
      throw Abort(.internalServerError, reason: "\(key) environment variable could not be transformed to \(String(describing: T.self))")
    }
    return transformedValue
  }
}
