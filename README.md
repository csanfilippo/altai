# altai

**altai** is a simple Swift package aiming to improve the developer experience when using Swift [typed throws](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/errorhandling#Specifying-the-Error-Type).

# The background

Typed throws have been introduced with [Swift 6](https://www.swift.org/blog/announcing-swift-6/) and permit functions to specify the type of error that they throw as part of their signature.

```swift
enum CustomError: Error {
    case oddNumber
}

func isEven(_ number: Int) -> Bool {
    return number.isMultiple(of: 2) || number == 0
}

func throwingIfOdd(_ number: Int) throws(CustomError) -> Int {
  guard !isEven(number) else {
    throws .oddNumber
  }

  return number
}
```

When calling the function `throwingIfOdd`, the Swift compiler knows that the function can throw only `CustomError`.

```swift
do {
  let evenNumber = try throwingIfOdd(2)
  print("\(evenNumber) is even")
} catch {
  // Here error is of type CustomError
}
```

A (bad) side effect of typed throws is the problem of nested errors. Consider the following variation of the `throwingIfOdd` function

```swift
enum CustomError: Error {
    case oddNumber
    case decodingError
}

func throwingIfOdd(_ number: String) throws(CustomError) -> Int {
    
    do {
        let number = try JSONDecoder().decode(Int.self, from: number.data(using: .utf8)!)
        
        guard isEven(number) else {
            throw CustomError.oddNumber
        }
        
        return number
    } catch {
        if let customError = error as? CustomError {
            throw customError
        } else {
            throw .decodingError
        }
    }
}
```

The function now accepts a String input and attempts to decode it as an Int. If the decoding is successful, it evaluates whether the resulting Int is odd or even. However, if JSONDecoder encounters an error, we must catch it and map it to a CustomError. Even worse, we need to rethrow the CustomError that the function raised.

# Where altai can help

By conforming to the `UpliftingErrors` defined in **altai**, `CustomError` becomes 

```swift
enum CustomError: Error, UpliftingErrors {
    case oddNumber
    case uplifted(any Error)
}
```
and the `throwingIfOdd` becomes

```swift
func throwingIfOdd(_ number: String) throws(CustomError) -> Int {
    
    let number = try CustomError.uplift {
        try JSONDecoder().decode(Int.self, from: number.data(using: .utf8)!)
    }
    
    guard isEven(number) else {
        throw .oddNumber
    }
    
    return number
}
```

The `DecodingError` thrown by `JSONDecoder` is uplift and made available to the `CustomError` consumer
