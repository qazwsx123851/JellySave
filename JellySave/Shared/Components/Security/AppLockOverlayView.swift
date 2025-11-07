import Combine
import SwiftUI

struct AppLockOverlayView: View {
    @EnvironmentObject private var appLockService: AppLockService
    @State private var passcode: String = ""
    @State private var errorMessage: String?
    @State private var biometricCancellable: AnyCancellable?
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: Constants.Spacing.xl) {
                VStack(spacing: Constants.Spacing.sm) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(ThemeColor.primary.color)
                    Text("JellySave 已鎖定")
                        .font(Constants.Typography.title.weight(.bold))
                        .foregroundStyle(.white)
                    Text("輸入解鎖密碼或使用 Face ID/Touch ID")
                        .font(Constants.Typography.body)
                        .foregroundStyle(Color.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: Constants.Spacing.md) {
                    SecureField("輸入 4-6 位數密碼", text: $passcode)
                        .keyboardType(.numberPad)
                        .textContentType(.password)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(Constants.CornerRadius.medium)
                        .foregroundStyle(.white)
                        .focused($isFieldFocused)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(Constants.Typography.caption)
                            .foregroundStyle(Color.accentCoral)
                    }

                    CustomButton(title: "解鎖", style: .primary) {
                        attemptUnlock()
                    }
                    .disabled(passcode.isEmpty)

                    if appLockService.canUseBiometrics {
                        Button {
                            attemptBiometricUnlock()
                        } label: {
                            Label("使用 Face ID/Touch ID", systemImage: "faceid")
                                .font(Constants.Typography.body.weight(.semibold))
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.white)
                        .padding(.top, Constants.Spacing.sm)
                    }
                }
                .frame(maxWidth: 360)
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFieldFocused = true
            }
        }
    }

    private func attemptUnlock() {
        if appLockService.unlock(with: passcode) {
            passcode = ""
            errorMessage = nil
        } else {
            errorMessage = "密碼不正確，請再試一次。"
            passcode = ""
            isFieldFocused = true
        }
    }

    private func attemptBiometricUnlock() {
        biometricCancellable = appLockService.authenticateWithBiometrics()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in
                errorMessage = nil
            }
    }
}
