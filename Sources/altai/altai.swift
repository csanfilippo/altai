import Foundation

/// A protocol for error types that can *uplift* arbitrary errors into a domain-specific
/// error representation.
///
/// Conforming types implement `uplifted(_:)` to translate any thrown error into `Self`.
/// Use the helper `uplift(_:)` functions to run operations and automatically rethrow
/// domain errors produced by `uplifted(_:)`.
///
/// Example:
/// ```swift
/// enum NetworkError: Error, UpliftingErrors {
///     case transport
///     case decoding
///     case uplifted(_ error: any Error)
/// }
/// ```
public protocol UpliftingErrors: Sendable {
    /// Convert any thrown error into this domain's error type.
    /// - Parameter error: The original error to convert.
    /// - Returns: A `Self` value that represents the provided error in this domain.
    static func uplifted(_ error: any Error) -> Self
}

public extension UpliftingErrors {
    /// Runs a throwing operation and rethrows a domain error mapped by `uplifted(_:)`.
    ///
    /// This helper executes `operation` and, if it throws, converts the underlying
    /// error into `Self` using `uplifted(_:)`, then rethrows it as `throws(Self)`.
    /// - Parameter operation: A closure that may throw while producing a value.
    /// - Returns: The value produced by `operation` if it succeeds.
    /// - Throws: A `Self` error produced by `uplifted(_:)` when `operation` throws.
    static func uplift<T>(_ operation: () throws -> T) throws(Self) -> T {
        do {
            return try operation()
        } catch {
            throw Self.uplifted(error)
        }
    }
    
    /// Runs an async throwing operation and rethrows a domain error mapped by `uplifted(_:)`.
    ///
    /// Executes the async `operation` and, if it throws, converts the underlying error
    /// into `Self` using `uplifted(_:)`, then rethrows it as `throws(Self)`.
    /// - Parameter operation: An async closure that may throw while producing a value.
    /// - Returns: The value produced by `operation` if it succeeds.
    /// - Throws: A `Self` error produced by `uplifted(_:)` when `operation` throws.
    static func uplift<T>(_ operation: () async throws -> T) async throws(Self) -> T {
        do {
            return try await operation()
        } catch {
            throw Self.uplifted(error)
        }
    }
}
