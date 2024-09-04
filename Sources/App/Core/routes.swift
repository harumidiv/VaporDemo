import Vapor

func routes(_ app: Application) throws {
  app.get { req async in
    "It works!"
  }

  app.get("hello") { req async -> String in
    "Hello, world!"
  }

  app.get("json") { _ async throws in
    let json = [
      "message": "Hello, Vapor!",
      "status": "success"
    ]
    let response = Response(status: .ok)
    try response.content.encode(json, as: .json)
    return response
  }

  app.get("cat") { request async throws in
    let image = try await request.fileio.collectFile(
      at: app.directory.publicDirectory.appending("cat.jpg")
    )
    var headers = HTTPHeaders()
    headers.contentType = .jpeg

    return Response(
      status: .ok,
      headers: headers,
      body: .init(buffer: image)
    )
  }

  try app.register(collection: MyController())
  try app.register(collection: HTTPBinController())
}
