# Contributing to UniversalDesignSystem

Thank you for contributing to UniversalDesignSystem! Follow these guidelines for development, testing, and asset generation.

---

## Development Environment Requirements

- **macOS**: 14.0 or newer
- **Xcode**: 16.0 or newer (Swift 6 toolchain)
- **Python**: 3.9+ (standard installation, no third-party pip dependencies required)

---

## Command Reference

### 1. Build Swift Package

```bash
swift build
```

### 2. Run Swift Unit Tests

```bash
swift test
```

### 3. Run Python Code Generator

To validate token JSONs and generate Swift accessors:

```bash
python3 scripts/generate_design_system.py
```

### 4. Run Python Unit Tests

To run generator edge case tests:

```bash
python3 scripts/tests/test_generator.py
```

---

## Code Quality Rules

1. **Strict Concurrency**: All UI-bound components and handlers must specify `@MainActor` where appropriate. Value types crossing concurrency boundaries must conform to `Sendable`.
2. **Zero Unnecessary Dependencies**: Do not introduce third-party CocoaPods or SPM runtime dependencies.
3. **Synchronization**: Whenever a design token or component is added to `UDSSwiftUI`, provide an equivalent counterpart in `UDSUIKit`.
