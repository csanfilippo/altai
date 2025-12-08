/*
 MIT License

 Copyright (c) 2025 Calogero Sanfilippo

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

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
///enum CustomError: Error, UpliftingErrors {
///    case oddNumber
///    case uplifted(any Error)
///}
///
///func isEven(_ number: Int) -> Bool {
///    return number.isMultiple(of: 2) || number == 0
///}
///
///@discardableResult
///func throwingIfOdd(_ number: String) throws(CustomError) -> Int {
///
///    let number = try CustomError.uplift {
///        try JSONDecoder().decode(Int.self, from: number.data(using: .utf8)!)
///    }
///
///    guard isEven(number) else {
///        throw .oddNumber
///    }
///
///    return number
///}
/// ```
public protocol UpliftingErrors: Sendable {
    /// Convert any thrown error into this domain's error type.
    /// - Parameter error: The original error to uplift.
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
