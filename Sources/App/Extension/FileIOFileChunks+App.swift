import Vapor

// FIXME: `Type 'FileIO.FileChunks' does not conform to the 'Sendable' protocol` が発生するので Vapor 5 がリリースされるまでの回避策
extension FileIO.FileChunks: @unchecked Sendable {}
