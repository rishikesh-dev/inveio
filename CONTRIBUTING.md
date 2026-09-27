# Contributing to Kharcha

We love contributions! Here's how to get started.

## Getting Started

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Make your changes.
4. Run `flutter analyze` to ensure no lint issues.
5. Run `flutter test` to verify existing tests pass.
6. Commit with a clear message (`git commit -m "feat: add your feature"`).
7. Push and open a Pull Request.

## Code Style

- Follow [Dart's effective dart style guide](https://dart.dev/guides/language/effective-dart/style).
- Use `snake_case` for file names and directories.
- Use `PascalCase` for classes, enums, and extensions.
- Use `camelCase` for variables, functions, and parameters.
- Keep widget files focused — one screen or one widget per file.
- Use meaningful names over abbreviations.

## What Not to Do

- ✅ Do fix typos, improve naming, and add tests.
- ❌ Don't hardcode API keys, secrets, or personal data.
- ❌ Don't commit generated files (`build/`, `.dart_tool/`, etc.).
- ❌ Don't add emojis to code or documentation.

## Pull Request Checklist

- [ ] No new analyzer warnings or errors (`flutter analyze`).
- [ ] Existing tests pass (`flutter test`).
- [ ] Added tests for new functionality if applicable.
- [ ] Updated relevant documentation.
- [ ] PR description clearly explains the change.

## Need Help?

Open an issue with the label `question` — we're happy to help.
