import XCTest
@testable import JellySave

final class ErrorHandlerTests: XCTestCase {
    func testMessageTranslation() {
        let handler = ErrorHandler.shared
        let message = handler.message(for: JellySaveError.network)
        XCTAssertTrue(message.contains("網路"))

        let nsError = NSError(domain: NSCocoaErrorDomain, code: 134070, userInfo: nil)
        let otherMessage = handler.message(for: nsError)
        XCTAssertTrue(otherMessage.contains("資料"))
    }
}
