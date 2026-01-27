import SwiftUI

struct HomeHeaderView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                
                Text("Mark") // Placeholder for user name
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                // Notification Button
                Button {
                    // Action
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.surfaceSecondary)
                            )
                        
                        // Badge
                        Circle()
                            .fill(ThemeColor.accent.color)
                            .frame(width: 10, height: 10)
                            .offset(x: 0, y: 0)
                            .overlay(
                                Circle()
                                    .stroke(Color.appBackground, lineWidth: 2)
                            )
                    }
                }
                
                // Profile/Settings Button
                Button {
                    // Action
                } label: {
                    Image(systemName: "person.circle.fill") // Placeholder for avatar
                        .font(.system(size: 40))
                        .foregroundStyle(Color.textSecondary)
                        .background(
                            Circle()
                                .fill(Color.surfaceSecondary)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.surfaceSecondary, lineWidth: 2)
                        )
                }
            }
        }
        .padding(.bottom, Constants.Spacing.sm)
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "早安，準備好開始新的一天了嗎？"
        case 12..<18: return "午安，記得休息一下喔"
        case 18..<22: return "晚安，今天過得如何？"
        default: return "夜深了，早點休息吧"
        }
    }
}

#Preview {
    HomeHeaderView()
        .padding()
        .background(Color.appBackground)
}
