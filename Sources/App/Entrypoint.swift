import Dogstatsd
import Fluent
import FluentPostgresDriver
import Vapor
import Logging
import NIOCore
import NIOPosix
import OpenAPIVapor

@main
enum Entrypoint {

  static func main() async throws {
    var env = try Environment.detect()
    try LoggingSystem.bootstrap(from: &env)

    let app = try await Application.make(env)

    do {
      try await configure(app)
    } catch {
      app.logger.report(error: error)
      try? await app.asyncShutdown()
      throw error
    }
    try await app.execute()
    try await app.asyncShutdown()
  }
}

private extension Entrypoint {

  static func configure(_ app: Application) async throws {
    // Serves files from `Public/` directory
    app.middleware.use(
      FileMiddleware(
        publicDirectory: app.directory.publicDirectory
      )
    )

    // register routes
    try routes(app)

    // This attempts to install NIO as the Swift Concurrency global executor.
    // You can enable it if you'd like to reduce the amount of context switching between NIO and Swift Concurrency.
    // Note: this has caused issues with some libraries that use `.wait()` and cleanly shutting down.
    // If enabled, you should be careful about calling async functions before this point as it can cause assertion failures.
    // let executorTakeoverSuccess = NIOSingletons.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
    // app.logger.debug("Tried to install SwiftNIO's EventLoopGroup as Swift's global concurrency executor", metadata: ["success": .stringConvertible(executorTakeoverSuccess)])

    // OpenAPI
    let requestInjectionMiddleware = OpenAPIRequestInjectionMiddleware()
    let transport = VaporTransport(routesBuilder: app.grouped(requestInjectionMiddleware))
    let handler = OpenAPIController()
    try handler.registerHandlers(on: transport, serverURL: Servers.server1())
    app.get("openapi") { $0.redirect(to: "/openapi.html", redirectType: .permanent) }

    // Database
    let config = if let databaseSocketPath = try Environment.databaseSocketPath() {
      try SQLPostgresConfiguration(
        unixDomainSocketPath: databaseSocketPath,
        username: Environment.databaseUsername(),
        password: Environment.databasePassword(),
        database: Environment.databaseName()
      )
    } else {
      try SQLPostgresConfiguration(
        hostname: Environment.databaseHost(),
        port: Environment.databasePort(),
        username: Environment.databaseUsername(),
        password: Environment.databasePassword(),
        database: Environment.databaseName(),
        tls: .disable
      )
    }

    app.logger.info("SQLPostgresConfiguration: \(config)")

    app.databases.use(
      .postgres(
        configuration: config,
        connectionPoolTimeout: .seconds(120)
      ),
      as: .psql
    )

    app.migrations.add(CreateUser())

    do {
      try await app.autoMigrate()
    } catch let error as PSQLError {
      app.logger.error("app.autoMigrate failed. error: \(String(reflecting: error)), error.underlying: \(String(describing: error.underlying))")
    } catch {
      app.logger.error("app.autoMigrate failed. error: \(String(reflecting: error))")
    }

    app.dogstatsd.config = .udp(
      address: "localhost",
      port: 8125
    )
  }
}

private extension Entrypoint {

  static func routes(_ app: Application) throws {
    app.get { req async in
      req.dogstatsd.increment("test.metric")
      return "It works!"
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

    // Auth
    do {
      let protected = app.grouped(UserAuthenticator())
      protected.get("basic_auth") { req -> String in
        try req.auth.require(AuthUser.self).name
      }
    }
  }
}
