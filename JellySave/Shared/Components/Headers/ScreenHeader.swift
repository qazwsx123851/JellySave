import SwiftUI

struct ScreenHeader: View {
    let title: String
    var subtitle: String? = nil
    var actionIcon: String? = nil
    var onAction: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                if let subtitle {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundStyle(Color.textSecondary)
                }
                
                Text(title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
            }
            
            Spacer()
            
            if let actionIcon, let onAction {
                Button(action: onAction) {
                    Image(systemName: actionIcon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(ThemeColor.primary.color)
                                .shadow(color: ThemeColor.primary.color.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
            }
        }
        .padding(.bottom, Constants.Spacing.sm)
    }
}

#Preview {
    VStack {
        ScreenHeader(title: "預覽標題", actionIcon: "plus", onAction: {})
        ScreenHeader(title: "設定", subtitle: "User Name")
    }
    .padding()
    .background(Color.appBackground)
}
