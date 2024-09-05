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
}
