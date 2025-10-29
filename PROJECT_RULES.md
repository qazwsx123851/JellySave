# JellySave Project Rules

## Tech Baseline
- iOS target: 16.0+
- Xcode: 15+
- Swift: 5.9+
- Frameworks: SwiftUI, Combine, Swift Charts, Core Data + CloudKit, UserNotifications
- Architecture: MVVM, dependency-injected services

## Development Flow
1. UI-first sequence per TODO.md
   - Phase 1-2: Build static UI and theme system (no data bindings)
   - Phase 3-4: Implement data models, services, view models and bind UI
   - Phase 5-7: Core features, animations, iCloud
   - Phase 8-9: Performance, security, automated tests
2. Every screen ships static first, reviewed and approved before adding logic
3. Keep PRs small and scoped to one module/feature

## Source Structure
- Follow the structure in README.md under `JellySave/`
- Feature-first folders under `Features/` with `Views/` and `ViewModels/`
- Shared components/utilities only when reused in 2+ places

## Swift Code Style
- Naming: descriptive, full words; functions are verbs; variables are nouns
- Avoid 1–2 letter names; avoid magic numbers (use `Constants`)
- Use `struct` by default; `class` only when reference semantics are required
- Optionals: prefer early returns and guard statements
- Concurrency: prefer Combine for observation; use async/await for I/O or async APIs
- No empty catch blocks; handle errors meaningfully
- Keep functions < 60 lines; files < 400 lines when feasible
- UI modifiers: one per line; avoid deep nesting

## SwiftUI Guidelines
- Views are lightweight and value-type; move logic to ViewModels
- Use `@State`, `@Binding`, `@FocusState` appropriately; avoid state duplication
- Use accessible colors and dynamic type; support Dark Mode
- Animations: subtle and purposeful; prefer `.interactiveSpring()` and `.transaction` for performance
- Charts: Swift Charts only; no third-party chart libs

## MVVM & Dependency Injection
- ViewModel responsibilities:
  - Input handling, business orchestration, formatting for the view
  - No Core Data fetch code inside Views
- Services:
  - `AccountService`, `SavingGoalService`, `NotificationService`, `CloudKitManager`
  - Pure business logic; testable; no UI imports
- Inject services into ViewModels via initializers; avoid singletons (except Apple stacks like `UNUserNotificationCenter.current()`)

## Core Data & CloudKit
- Use `NSPersistentCloudKitContainer` for iCloud sync
- Entities: `Account`, `SavingGoal`, `MonthlySnapshot`, `NotificationSettings`
- Migrations: use lightweight migrations when possible; bump model version per change
- Access Core Data through a dedicated `CoreDataStack` only
- Fetched data exposed to ViewModels via Combine publishers
- Conflict policy: last-write-wins unless domain rule requires merge; log merges

## Notifications
- Local notifications only for MVP
- All notifications scheduled by `NotificationService`
- Content source: `InspirationalQuotes`
- Respect user preferences and system quiet hours; provide opt-out

## UI/UX Rules
- Visual style: modern minimal; card layout; soft gradients
- Color tokens and typography via `Color+Theme` and `Constants`
- Reusable UI: `CustomButton`, `CurrencyTextField`, `ProgressRing`, `CardContainer`
- Accessibility: VoiceOver labels, Dynamic Type, sufficient contrast

## Testing Policy
- Unit tests mandatory for Services and ViewModels (80%+ business logic coverage)
- UI tests for core flows: accounts, goals, navigation, notification settings
- Integration tests for data sync and iCloud container
- Accessibility tests for VoiceOver and Dynamic Type
- Test naming: `test_<MethodUnderTest>_Given_When_Then`

## CI/CD (recommended)
- On each commit: run unit tests and linting
- On each PR: run full test suite (unit, UI where feasible)
- Nightly: performance sanity checks; weekly: accessibility suite
- Fastlane lanes suggested: `test`, `uitest`, `beta` (future)

## Git Workflow
- Branch naming: `feature/<area>-<short-desc>`, `fix/<area>-<issue>`
- Commit message: Conventional Commits
  - `feat:`, `fix:`, `refactor:`, `test:`, `chore:`, `docs:`, `perf:`, `ci:`
- One feature per PR; add screenshots for UI changes
- Require 1 approval; green checks before merge

### Repository hygiene (.gitignore)
- Ignore Xcode artifacts: `DerivedData/`, `build/`, `xcuserdata/`, `*.xcuserstate`
- Ignore user files: `*.pbxuser`, `*.mode1v3`, `*.mode2v3`, `*.perspectivev3`
- SwiftPM: ignore `.swiftpm/`, `.build/`, `Packages/`; keep `Package.resolved` tracked
- Optional managers: ignore `Pods/` (CocoaPods) and `Carthage/` folders if present
- CI/Reports: ignore logs, coverage (`*.log`, `*.xccov*`, `Reports/`, `build_logs/`)
- Fastlane artifacts: `fastlane/test_output`, `fastlane/screenshots`, reports/html
- Secrets and local configs: `*.xcconfig.local`, `Secrets.xcconfig`, `.env*`
- Editors: `.vscode/`, `.idea/`

## Error Handling & Logging
- Use domain-specific error types; map to user-friendly messages
- Log errors with context; avoid logging PII
- Surface actionable errors to users with guidance

## Security & Privacy
- Keychain for sensitive data (tokens, secrets)
- Do not persist secrets in repo; use Xcode build settings or CI secrets
- Comply with Apple privacy requirements; request minimum permissions

## Performance Budgets
- App launch < 2.0s on mid-range devices
- HomeView initial render < 300ms with cached data
- Chart rendering 60fps on last two iOS versions

## Internationalization
- Prepare strings in `Localizable.strings`; default `en`, `zh-Hant` later
- No hard-coded user-visible strings in code

## Documentation
- Keep README.md and TODO.md in sync with scope changes
- Each feature PR must include a brief `Implementation Notes` section

## Review Checklist (PR author)
- UI matches static spec from Phase 2
- No business logic in Views
- Tests added/updated and passing locally
- Accessibility labels and Dynamic Type verified
- Strings externalized; no hard-coded currency symbols outside formatters

## Release & Versioning
- Semantic Versioning for app milestones
- Tag releases; maintain CHANGELOG.md

## Deviation Policy
- Any deviation from these rules must be documented in the PR with rationale and impact
