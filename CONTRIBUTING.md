# Contributing to HabitFlow

Thank you for your interest in contributing to HabitFlow! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.6.0 or higher
- Dart SDK 3.0.0 or higher
- Git
- Android Studio / VS Code with Flutter extensions

### Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/yourusername/habitflow.git
   cd habitflow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📋 Development Guidelines

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Write clear, concise comments for complex logic
- Keep functions small and focused on a single responsibility

### Architecture

We follow Clean Architecture principles:

```
lib/
├── core/           # Shared utilities, constants, themes
├── data/           # Data sources, repositories, models
├── domain/         # Business logic, entities, use cases
└── presentation/   # UI, screens, widgets, state management
```

### State Management

- Use **Riverpod** for state management
- Create providers for business logic
- Keep UI state separate from business logic
- Use `@riverpod` annotation for code generation

### File Naming

- Use snake_case for file names
- Use descriptive names: `habit_detail_screen.dart`
- Group related files in folders
- Use barrel exports (`index.dart`) for clean imports

## 🐛 Bug Reports

When reporting bugs, please include:

1. **Environment**
   - Flutter version (`flutter --version`)
   - Device/OS information
   - App version

2. **Steps to reproduce**
   - Clear, numbered steps
   - Expected vs actual behavior
   - Screenshots or videos if helpful

3. **Additional context**
   - Error logs
   - Related issues
   - Workarounds if any

## ✨ Feature Requests

For new features:

1. **Check existing issues** first
2. **Describe the problem** you're trying to solve
3. **Propose a solution** with mockups if possible
4. **Consider alternatives** you've thought about
5. **Add labels** like `enhancement`, `ui/ux`, `backend`, etc.

## 🔧 Pull Request Process

### Before Submitting

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, tested code
   - Update documentation if needed
   - Add tests for new functionality

3. **Test thoroughly**
   ```bash
   flutter test
   flutter analyze
   ```

4. **Commit with clear messages**
   ```bash
   git commit -m "feat: add habit streak visualization"
   git commit -m "fix: resolve calendar sync issue"
   git commit -m "docs: update API documentation"
   ```

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

### Review Process

1. **Automated checks** must pass
2. **Code review** by maintainers
3. **Testing** on different devices
4. **Documentation** updates if needed
5. **Merge** after approval

## 🧪 Testing

### Unit Tests
```bash
flutter test test/unit/
```

### Widget Tests
```bash
flutter test test/widget/
```

### Integration Tests
```bash
flutter test integration_test/
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📱 Platform-Specific Guidelines

### Android
- Follow Material Design guidelines
- Test on different screen sizes
- Consider accessibility features
- Handle different Android versions

### iOS
- Follow Human Interface Guidelines
- Test on different iOS versions
- Consider iPhone and iPad layouts
- Handle iOS-specific permissions

## 🎨 UI/UX Guidelines

### Design System
- Use predefined colors from `AppColors`
- Use typography from `AppTextStyles`
- Follow spacing guidelines from `AppSpacing`
- Use consistent component patterns

### Accessibility
- Add semantic labels
- Ensure proper contrast ratios
- Support screen readers
- Test with accessibility tools

### Responsive Design
- Test on different screen sizes
- Use responsive layouts
- Handle orientation changes
- Consider tablet layouts

## 🔒 Security

- Never commit sensitive data
- Use environment variables for API keys
- Validate all user inputs
- Follow secure coding practices

## 📚 Documentation

### Code Documentation
- Document public APIs
- Add inline comments for complex logic
- Update README for new features
- Keep architecture docs current

### API Documentation
- Document all endpoints
- Include request/response examples
- Update when APIs change
- Use consistent formatting

## 🏷 Labels

We use these labels for issues and PRs:

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements to documentation
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention is needed
- `priority: high` - High priority
- `priority: low` - Low priority
- `ui/ux` - User interface/experience
- `backend` - Backend related
- `frontend` - Frontend related
- `testing` - Testing related

## 💬 Communication

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For questions and general discussion
- **Discord**: For real-time chat (link in README)
- **Email**: For security issues (security@habitflow.app)

## 🎉 Recognition

Contributors will be:
- Listed in our README
- Mentioned in release notes
- Invited to our Discord community
- Given early access to new features

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to HabitFlow! 🎉
