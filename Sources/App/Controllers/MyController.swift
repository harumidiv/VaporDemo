import Vapor

struct MyController: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    let myRoutes = routes.grouped("my")
    myRoutes.get("json", use: getJSON)
    myRoutes.get("cat", use: getCat)
    myRoutes.get("catWithStream", use: getCatWithStream)
    myRoutes.get("notfound", use: notFound)
  }

  @Sendable
  func getJSON(request: Request) throws -> Response {
    let json = [
      "message": "Hello, Vapor!",
      "status": "success"
    ]
    let response = Response(status: .ok)
    try response.content.encode(json, as: .json)
    return response
  }

  @Sendable
  func getCat(request: Request) async throws -> Response {
    let image = try await request.fileio.collectFile(
      at: request.application.directory.publicDirectory.appending("cat.jpg")
    )
    var headers = HTTPHeaders()
    headers.contentType = .jpeg

    return Response(
      status: .ok,
      headers: headers,
      body: .init(buffer: image)
    )
  }

  @Sendable
  func getCatWithStream(request: Request) async throws -> Response {
    try await request.fileio.asyncStreamFile(
      at: request.application.directory.publicDirectory.appending("cat.jpg")
    )
  }

  @Sendable
  func notFound(request: Request) async throws -> Response {
    do {
      let _ = try await request.fileio.collectFile(
        at: request.application.directory.publicDirectory.appending("not_found_image.jpg")
      )
      return Response(status: .ok)
    } catch {
      request.logger.error("original error: \(error)")
      throw Abort(.notFound, reason: "Not found Request")
    }
  }
}
