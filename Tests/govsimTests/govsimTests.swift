import Testing
@testable import govsim

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    // Swift Testing Documentation
    // https://developer.apple.com/documentation/testing
    let message = "hello world"
    #expect(message == "hello world")
}
