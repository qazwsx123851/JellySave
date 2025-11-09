import XCTest
@testable import JellySave

final class InMemoryKeychainService: KeychainServiceProtocol {
    private var storage: [String: Data] = [:]

    func save(_ data: Data, for key: String) throws {
        storage[key] = data
    }

    func read(for key: String) throws -> Data? {
        storage[key]
    }

    func delete(for key: String) throws {
        storage.removeValue(forKey: key)
    }
}

final class AppLockServiceTests: XCTestCase {
    func testPasscodeChangeRequiresCurrentValue() throws {
        let keychain = InMemoryKeychainService()
        let service = AppLockService(keychain: keychain, biometricService: BiometricAuthService(), defaults: .standard)

        XCTAssertNoThrow(try service.setPasscode(newValue: "1234"))

        XCTAssertThrowsError(try service.setPasscode(newValue: "8888"))
        XCTAssertThrowsError(try service.setPasscode(newValue: "8888", currentPasscode: "1111"))
        XCTAssertNoThrow(try service.setPasscode(newValue: "8888", currentPasscode: "1234"))
    }
}
