import Foundation

enum JellySaveError: LocalizedError {
    case notImplemented
    case invalidState
    case biometricUnavailable
    case invalidPasscode
    case passcodeRequired
    case coreData(message: String)
    case network
    case unknown

    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "此功能尚未實作。"
        case .invalidState:
            return "應用狀態不正確，請稍後重試。"
        case .biometricUnavailable:
            return "無法使用生物辨識，請改用密碼解鎖。"
        case .invalidPasscode:
            return "密碼驗證失敗，請重新輸入。"
        case .passcodeRequired:
            return "請提供目前密碼以變更設定。"
        case .coreData(let message):
            return "資料存取發生問題：\(message)"
        case .network:
            return "網路狀態不佳，請檢查連線。"
        case .unknown:
            return "發生未知錯誤，請稍後重試。"
        }
    }
}
