import Dependencies
import NIOFileSystem
import OpenAPIRuntime
import OpenAPIVapor
import Vapor

struct OpenAPIController: APIProtocol {

  @Dependency(\.request) var request

  func getJSON(
    _ input: Operations.getJSON.Input
  ) async throws -> Operations.getJSON.Output {
    .ok(
      .init(
        body: .json(
          .init(
            message: "Hello, Vapor!",
            status: "success"
          )
        )
      )
    )
  }

  func getCat(
    _ input: Operations.getCat.Input
  ) async throws -> Operations.getCat.Output {
    var image = try await request.fileio.collectFile(
      at: request.application.directory.publicDirectory.appending("cat.jpg")
    )
    guard let data = image.readData(
      length: image.readableBytes,
      byteTransferStrategy: .noCopy
    ) else {
      throw Abort(.badRequest)
    }

    return .ok(
      .init(
        body: .jpeg(
          .init(data)
        )
      )
    )
  }

  func getCatWithChunks(
    _ input: Operations.getCatWithChunks.Input
  ) async throws -> Operations.getCatWithChunks.Output {
    let filePath = request.application.directory.publicDirectory.appending("cat.jpg")

    let length: HTTPBody.Length = switch try await FileSystem.shared.info(forFileAt: .init(filePath))?.size {
    case let size?:
        .known(size) // content-length
    default:
        .unknown
    }

    let fileChunks = try await request.fileio.readFile(at: filePath)

    let bytes = fileChunks.map {
      $0.getBytes(at: 0, length: $0.readableBytes) ?? []
    }

    let body = HTTPBody(
      bytes,
      length: length,
      iterationBehavior: .single
    )

    return .ok(
      .init(
        body: .jpeg(body)
      )
    )
  }

  func getAllUsers(
    _ input: Operations.getAllUsers.Input
  ) async throws -> Operations.getAllUsers.Output {
    try await .ok(
      .init(
        body: .json(
          User.query(on: request.db)
            .all()
            .map {
              try .init(
                id: $0.requireID(),
                username: $0.name,
                email: $0.email
              )
            }
        )
      )
    )
  }

  func createUser(
    _ input: Operations.createUser.Input
  ) async throws -> Operations.createUser.Output {
    switch input.body {
    case let .json(payload):
      let user = User(name: payload.username, email: payload.email)
      try await user.save(on: request.db)

      return try .created(
        .init(
          body: .json(
            .init(
              id: user.requireID(),
              username: user.name,
              email: user.email
            )
          )
        )
      )
    }
  }

  func getUserById(
    _ input: Operations.getUserById.Input
  ) async throws -> Operations.getUserById.Output {
    guard let user = try await User.find(input.path.id, on: request.db) else {
      throw Abort(.notFound, reason: "user.id: \(input.path.id) not found.")
    }
    return .ok(
      .init(
        body: .json(
          .init(
            id: input.path.id,
            username: user.name,
            email: user.email
          )
        )
      )
    )
  }

  func updateUserById(
    _ input: Operations.updateUserById.Input
  ) async throws -> Operations.updateUserById.Output {
    guard let user = try await User.find(input.path.id, on: request.db) else {
      throw Abort(.notFound, reason: "user.id: \(input.path.id) not found.")
    }
    switch input.body {
    case let .json(payload):
      user.name = payload.username
      user.email = payload.email
      try await user.save(on: request.db)
      return .ok(
        .init(
          body: .json(
            .init(
              id: input.path.id,
              username: user.name,
              email: user.email
            )
          )
        )
      )
    }
  }

  func deleteUserById(
    _ input: Operations.deleteUserById.Input
  ) async throws -> Operations.deleteUserById.Output {
    guard let user = try await User.find(input.path.id, on: request.db) else {
      throw Abort(.notFound, reason: "user.id: \(input.path.id) not found.")
    }
    try await user.delete(on: request.db)

    return .noContent(.init())
  }
}
