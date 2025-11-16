import XCTest

final class JellySaveUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testMainTabsAppear() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.tabBars.buttons["首頁"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["帳戶"].exists)
    }
}
