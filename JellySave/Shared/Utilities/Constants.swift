import SwiftUI

public enum Constants {
    public enum Layout {
        /// Standard horizontal padding used throughout screens.
        public static let horizontalPadding: CGFloat = 20
        /// Vertical spacing between stacked sections.
        public static let sectionSpacing: CGFloat = 24
        /// Spacing for elements within a card container.
        public static let cardContentSpacing: CGFloat = 16
    }

    public enum CornerRadius {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 20
    }

    public enum Shadow {
        public static let cardRadius: CGFloat = 12
        public static let cardX: CGFloat = 0
        public static let cardY: CGFloat = 6
        public static let cardOpacity: Double = 0.08
    }

    public enum Typography {
        public static let title = Font.system(.title, design: .rounded).weight(.semibold)
        public static let headline = Font.system(.title3, design: .rounded).weight(.semibold)
        public static let subheadline = Font.system(.headline, design: .rounded)
        public static let body = Font.system(.body, design: .default)
        public static let caption = Font.system(.caption, design: .default)
    }

    public enum Button {
        public static let height: CGFloat = 54
        public static let cornerRadius: CGFloat = CornerRadius.medium
        public static let horizontalPadding: CGFloat = 16
    }

    public enum Progress {
        public static let ringLineWidth: CGFloat = 12
    }
}
