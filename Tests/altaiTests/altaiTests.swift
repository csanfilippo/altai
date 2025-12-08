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

import Testing
import Foundation
@testable import altai

enum CustomError: Error, UpliftingErrors {
    case oddNumber
    case uplifted(any Error)
}

func isEven(_ number: Int) -> Bool {
    return number.isMultiple(of: 2) || number == 0
}

@discardableResult
func throwingIfOdd(_ number: String) throws(CustomError) -> Int {
    
    let number = try CustomError.uplift {
        try JSONDecoder().decode(Int.self, from: number.data(using: .utf8)!)
    }
    
    guard isEven(number) else {
        throw .oddNumber
    }
    
    return number
}

@Suite("UpliftingErrors")
struct UpliftingErrorsTests {
    @Test("any nested error is uplifted")
    func nestedErrorTest() {
        do {
            try throwingIfOdd("not a number")
        } catch {
            switch error {
            case .uplifted(let error):
                #expect(error is DecodingError)
            default:
                Issue.record()
            }
        }
    }

    @Test("UpliftingErrors doesn't interfere with the normal flow")
    func noErrorTest() {
        #expect(throws: Never.self) {
            try throwingIfOdd("2")
        }
    }

    @Test("UpliftingErrors doesn't uplift errors adhereing to the contract")
    func expectedErrorTest() {
        do {
            try throwingIfOdd("21")
        } catch {
            switch error {
            case .oddNumber:
                #expect(Bool(true))
            default:
                Issue.record()
            }
        }
    }
}
