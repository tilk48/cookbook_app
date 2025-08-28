Golden tests and screenshot capture

Overview
- Uses golden_toolkit to render screens and capture pixel-accurate images AI agents can inspect.
- Provides FakeMealieClient to stub API responses without network.
- Provides TestDiScope to register fakes in GetIt and satisfy widgets that depend on AuthProvider.

Run tests
flutter test --update-goldens

Artifacts
- Golden images are written under test/goldens/ by the test runner.

Notes
- AuthenticatedImage performs HTTP fetch; in tests, use FakeMealieClient and let image fail gracefully or provide a placeholder. The UI remains testable.
- Add more fixtures and tests per screen for reliable automation.
