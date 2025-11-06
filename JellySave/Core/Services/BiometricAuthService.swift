import Combine
import LocalAuthentication

protocol BiometricAuthServiceProtocol {
    func canEvaluatePolicy() -> Bool
    func authenticate(reason: String) -> AnyPublisher<Void, Error>
}

final class BiometricAuthService: BiometricAuthServiceProtocol {
    private let contextProvider: () -> LAContext
    private let policy: LAPolicy

    init(policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics,
         contextProvider: @escaping () -> LAContext = { LAContext() }) {
        self.policy = policy
        self.contextProvider = contextProvider
    }

    func canEvaluatePolicy() -> Bool {
        var error: NSError?
        let context = contextProvider()
        let canEvaluate = context.canEvaluatePolicy(policy, error: &error)
        return canEvaluate && error == nil
    }

    func authenticate(reason: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            let context = self.contextProvider()
            context.evaluatePolicy(self.policy, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if let error {
                        promise(.failure(error))
                    } else if success {
                        promise(.success(()))
                    } else {
                        promise(.failure(JellySaveError.invalidState))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
