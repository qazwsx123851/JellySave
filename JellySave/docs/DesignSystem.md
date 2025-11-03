# JellySave Design System

## Palette
- Primary Mint `Color.primaryMint`
- Secondary Sky `Color.secondarySky`
- Accent Coral `Color.accentCoral`
- Success Green `Color.successGreen`
- Warning Amber `Color.warningAmber`
- Surface / Background colors via `ThemeColor`

## Typography
| Style | Font |
| ----- | ---- |
| Hero | `Constants.Typography.hero` |
| Title | `Constants.Typography.title` |
| Subtitle | `Constants.Typography.subtitle` |
| Body | `Constants.Typography.body` |
| Caption | `Constants.Typography.caption` |

## Spacing / Layout
Use `Constants.Spacing` / `Constants.CornerRadius` helpers. The `maxWidthLayout()` modifier caps content width to 720pt.

## Components
- `CustomButton` primary/secondary/outline styles, 44pt min height
- `ProgressRing` animated gradients for completion
- `CardContainer` with optional header/action button
- `TagLabel`, `EmptyStateView`, `GradientBackground`
- `CurrencyTextField` handles TWD formatting

## Theming
`ThemeService` publishes the current `AppTheme` (system/light/dark) and persists the user choice. Inject with `@EnvironmentObject` and use `.preferredColorScheme(themeService.currentTheme.preferredColorScheme)` on the window root.
