import Foundation
import os

final class ErrorHandler {
    static let shared = ErrorHandler()

    private let logger = Logger(subsystem: "com.jellysave", category: "errors")

    private init() {}

    func handle(_ error: Error) -> String {
        let message = message(for: error)
        logger.error("\(error.localizedDescription, privacy: .public)")
        return message
    }

    func message(for error: Error) -> String {
        if let jellyError = error as? JellySaveError {
            return jellyError.errorDescription ?? "發生未知錯誤。"
        }

        let nsError = error as NSError
        if nsError.domain == NSCocoaErrorDomain {
            return "資料處理時發生錯誤 (\(nsError.code))。"
        }

        switch nsError.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorTimedOut:
            return JellySaveError.network.errorDescription ?? "請檢查網路連線。"
        default:
            return JellySaveError.unknown.errorDescription ?? "發生未知錯誤。"
        }
    }
}
