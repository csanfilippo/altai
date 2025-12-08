# altai
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcsanfilippo%2Faltai%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/csanfilippo/altai)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcsanfilippo%2Faltai%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/csanfilippo/altai)

<img width="2314" height="1457" alt="altai_light" src="" />
<img width="2314" height="1457" alt="altai_dark" src="h" />



<picture>
  <source srcset="https://github.com/user-attachments/assets/ba9ebc14-cfdd-417a-8fe9-feb593a376b7" media="(prefers-color-scheme: dark)">
  <source srcset="https://github.com/user-attachments/assets/412816f3-611d-4d1f-9c14-d05885d36684"  media="(prefers-color-scheme: light)">
  <img src="https://github.com/user-attachments/assets/412816f3-611d-4d1f-9c14-d05885d36684" alt="altai logo" width="470" height="296">
</picture>

**altai** is a simple Swift package aiming to improve the developer experience when using Swift [typed throws](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/errorhandling#Specifying-the-Error-Type).

# The background

[Swift 6](https://www.swift.org/blog/announcing-swift-6/) introduced typed throws, allowing functions to specify the type of error they can throw in their signature.

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

The function now accepts a String input and attempts to decode it as an Int. If the decoding is successful, it evaluates whether the resulting Int is odd or even. However, if JSONDecoder throws an error, the code must catch it and map it to a CustomError. Even worse, we need to rethrow the CustomError that the function raised.

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

**altai** defines the extension method `uplift`, that catches the inner error and maps it to the domain specific error.

### Swift Package Manager

If you want to use **altai** in any other project that uses [SwiftPM](https://swift.org/package-manager/), add the package as a dependency in `Package.swift`:

```swift
dependencies: [
  .package(
    url: "https://github.com/csanfilippo/altai.git",
    from: "1.0.0"
  ),
]
```


