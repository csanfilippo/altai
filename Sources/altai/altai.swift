import Foundation

public protocol UpliftingErrors: Sendable {
    static func uplifted(_ error: any Error) -> Self
}

public extension UpliftingErrors {
    static func uplift<T>(_ operation: () throws -> T) throws(Self) -> T {
        do {
            return try operation()
        } catch {
            throw Self.uplifted(error)
        }
    }
    
    static func uplift<T>(_ operation: () async throws -> T) async throws(Self) -> T {
        do {
            return try await operation()
        } catch {
            throw Self.uplifted(error)
        }
    }
}
