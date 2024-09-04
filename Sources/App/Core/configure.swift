import Vapor

// configures your application
public func configure(_ app: Application) async throws {
  // Serves files from `Public/` directory
  app.middleware.use(
    FileMiddleware(
      publicDirectory: app.directory.publicDirectory
    )
  )

  // register routes
  try routes(app)
}
