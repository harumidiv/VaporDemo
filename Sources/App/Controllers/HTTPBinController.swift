import Vapor

struct HTTPBinController: RouteCollection {

  func boot(routes: any Vapor.RoutesBuilder) throws {
    let myRoutes = routes.grouped("httpbin")
    myRoutes.get("get", use: get)
    myRoutes.get("404", use: getStatus404)
    myRoutes.get("jpeg", use: getJpeg)
    myRoutes.get("json", use: getJSON)
    myRoutes.get("html", use: getHTML)
  }

  @Sendable
  func get(request: Request) async throws -> ClientResponse {
    try await request.client.get("https://httpbin.org/get")
  }

  @Sendable
  func getStatus404(request: Request) async throws -> ClientResponse {
    let response = try await request.client.get("https://httpbin.org/status/404")
    request.logger.info("status: \(response.status)") // 404 Not Found
    return response
  }

  @Sendable
  func getJpeg(request: Request) async throws -> ClientResponse {
    try await request.client.get("https://httpbin.org/image/jpeg")
  }

  @Sendable
  func getJSON(request: Request) async throws -> ClientResponse {
    try await request.client.get("https://httpbin.org/json")
  }

  @Sendable
  func getHTML(request: Request) async throws -> ClientResponse {
    try await request.client.get("https://httpbin.org/html")
  }
}
