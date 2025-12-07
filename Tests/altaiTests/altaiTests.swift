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
                #expect(true)
            default:
                Issue.record()
            }
        }
    }
}
