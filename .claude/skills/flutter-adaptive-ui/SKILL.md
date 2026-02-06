---
name: flutter-adaptive-ui
description: ONLY for UI/layout/visual design work. Use when you need to build adaptive and responsive Flutter layouts, handle screen sizes and breakpoints, create responsive visual hierarchies, implement adaptive navigation UI (switching between NavigationBar/NavigationRail), design for multiple input types (touch/mouse/keyboard), or make UI decisions based on platform capabilities. DO NOT use for state management, routing logic, business logic, or architecture - use flutter-expert instead.
---

# Flutter Adaptive UI

## Overview

**IMPORTANT: This skill is EXCLUSIVELY for UI/layout/visual design work. For state management, navigation routing (GoRouter), business logic, architecture, performance optimization, testing, or any non-UI concerns, use the `flutter-expert` skill instead.**

Create Flutter applications that adapt gracefully to any screen size, platform, or input device. This skill provides comprehensive guidance for building responsive layouts that scale from mobile phones to large desktop displays while maintaining excellent user experience across touch, mouse, and keyboard interactions.

## Scope

**USE THIS SKILL FOR:**
- ✅ Layout design and responsive UI
- ✅ Screen size adaptation and breakpoints
- ✅ Visual widget composition (Row, Column, Stack, Grid, etc.)
- ✅ Adaptive navigation UI patterns (switching between NavigationBar/NavigationRail)
- ✅ MediaQuery and LayoutBuilder usage
- ✅ Input device handling (touch/mouse/keyboard interactions)
- ✅ Platform-specific UI decisions (what to show/hide)

**DO NOT USE THIS SKILL FOR:**
- ❌ State management (Riverpod, Bloc) → use `flutter-expert`
- ❌ Navigation routing logic (GoRouter) → use `flutter-expert`
- ❌ Business logic or data layer → use `flutter-expert`
- ❌ Performance optimization → use `flutter-expert`
- ❌ Testing strategies → use `flutter-expert`
- ❌ Project architecture → use `flutter-expert`
- ❌ API integrations or platform channels → use `flutter-expert`

## Quick Reference

**Core Layout Rule:** Constraints go down. Sizes go up. Parent sets position.

**3-Step Adaptive Approach:**
1. **Abstract** - Extract common data from widgets
2. **Measure** - Determine available space (MediaQuery/LayoutBuilder)
3. **Branch** - Select appropriate UI based on breakpoints

**Key Breakpoints:**
* Compact (Mobile): width < 600
* Medium (Tablet): 600 <= width < 840  
* Expanded (Desktop): width >= 840

## Adaptive Workflow

Follow the 3-step approach to make your app adaptive.

### Step 1: Abstract

Identify widgets that need adaptability and extract common data. Common patterns:
- Navigation UI (switch between bottom bar and side rail)
- Dialogs (fullscreen on mobile, modal on desktop)
- Content lists (reflow from single to multi-column)

For navigation, create a shared `Destination` class with icon and label used by both `NavigationBar` and `NavigationRail`.

### Step 2: Measure

Choose the right measurement tool:

**MediaQuery.sizeOf(context)** - Use when you need app window size for top-level layout decisions
- Returns entire app window dimensions
- Better performance than `MediaQuery.of()` for size queries
- Rebuilds widget when window size changes

**LayoutBuilder** - Use when you need constraints for specific widget subtree
- Provides parent widget's constraints as `BoxConstraints`
- Local sizing information, not global window size
- Returns min/max width and height ranges

Example:
```dart
// For app-level decisions
final width = MediaQuery.sizeOf(context).width;

// For widget-specific constraints
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    }
    return DesktopLayout();
  },
)
```

### Step 3: Branch

Apply breakpoints to select appropriate UI. Don't base decisions on device type - use window size instead.

Example breakpoints (from Material guidelines):
```dart
class AdaptiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    
    if (width >= 840) {
      return DesktopLayout();
    } else if (width >= 600) {
      return TabletLayout();
    }
    return MobileLayout();
  }
}
```

## Layout Fundamentals

### Understanding Constraints

Flutter layout follows one rule: **Constraints go down. Sizes go up. Parent sets position.**

Widgets receive constraints from parents, determine their size, then report size up to parent. Parents then position children.

Key limitation: Widgets can only decide size within parent constraints. They cannot know or control their own position.

For detailed examples and edge cases, see [layout-constraints.md](references/layout-constraints.md).

### Common Layout Patterns

**Row/Column**
- `Row` arranges children horizontally
- `Column` arranges children vertically
- Control alignment with `mainAxisAlignment` and `crossAxisAlignment`
- Use `Expanded` to make children fill available space proportionally

**Container**
- Add padding, margins, borders, background
- Can constrain size with width/height
- Without child/size, expands to fill constraints

**Expanded/Flexible**
- `Expanded` forces child to use available space
- `Flexible` allows child to use available space but can be smaller
- Use `flex` parameter to control proportions

For complete widget documentation, see [layout-basics.md](references/layout-basics.md) and [layout-common-widgets.md](references/layout-common-widgets.md).

## Best Practices

### Design Principles

**Break down widgets**
- Create small, focused widgets instead of large complex ones
- Improves performance with `const` widgets
- Makes testing and refactoring easier
- Share common components across different layouts

**Design to platform strengths**
- Mobile: Focus on capturing content, quick interactions, location awareness
- Tablet/Desktop: Focus on organization, manipulation, detailed work
- Web: Leverage deep linking and easy sharing

**Solve touch first**
- Start with great touch UI
- Test frequently on real mobile devices
- Layer on mouse/keyboard as accelerators, not replacements

### Implementation Guidelines

**Never lock orientation**
- Support both portrait and landscape
- Multi-window and foldable devices require flexibility
- Locked screens can be accessibility issues

**Avoid device type checks**
- Don't use `Platform.isIOS`, `Platform.isAndroid` for layout decisions
- Use window size instead
- Device type ≠ window size (windows, split screens, PiP)

**Use breakpoints, not orientation**
- Don't use `OrientationBuilder` for layout changes
- Use `MediaQuery.sizeOf` or `LayoutBuilder` with breakpoints
- Orientation doesn't indicate available space

**Don't fill entire width**
- On large screens, avoid full-width content
- Use multi-column layouts with `GridView` or flex patterns
- Constrain content width for readability

**Support multiple inputs**
- Implement keyboard navigation for accessibility
- Support mouse hover effects
- Handle focus properly for custom widgets

For complete best practices, see [adaptive-best-practices.md](references/adaptive-best-practices.md).

## Capabilities and Policies for UI Decisions

**NOTE: This pattern is ONLY for UI visibility decisions. For actual feature implementation, platform channels, or business logic, use `flutter-expert`.**

Separate what your UI *can* show from what it *should* show.

**Capabilities** (what UI can show)
- Platform UI component availability
- Input device support (touch, mouse, keyboard)
- Screen size and orientation support

**Policies** (what UI should show)
- Platform-specific design preferences
- Feature visibility based on screen size
- Adaptive UI patterns selection

### Implementation Pattern (UI Decisions Only)

```dart
// Capability class (for UI decisions)
class UICapability {
  bool canShowNavigationRail(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600;
  }

  bool hasMouseSupport() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }
}

// Policy class (for UI decisions)
class UIPolicy {
  bool shouldShowNavigationRail(BuildContext context) {
    // UI decision: show rail on larger screens
    return canShowNavigationRail(context);
  }

  bool shouldShowHoverEffects() {
    // UI decision: enable hover on desktop
    return hasMouseSupport();
  }
}
```

Benefits:
- Clear separation of UI concerns
- Easy to test UI behavior
- Adaptive UI logic is centralized

**Important:** For non-UI platform capabilities (camera access, GPS, file system, etc.), use `flutter-expert` skill.

For detailed examples, see [adaptive-capabilities.md](references/adaptive-capabilities.md) and [capability_policy_example.dart](assets/capability_policy_example.dart).

## Examples

### Responsive Navigation

Switch between bottom navigation (small screens) and navigation rail (large screens):

```dart
Widget build(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  
  return width >= 600 
    ? _buildNavigationRailLayout()
    : _buildBottomNavLayout();
}
```

Complete example: [responsive_navigation.dart](assets/responsive_navigation.dart)

### Adaptive Grid

Use `GridView.extent` with responsive maximum width:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    return GridView.extent(
      maxCrossAxisExtent: constraints.maxWidth < 600 ? 150 : 200,
      // ...
    );
  },
)
```

## Resources

### Reference Documentation
- [layout-constraints.md](references/layout-constraints.md) - Complete guide to Flutter's constraint system with 29 examples
- [layout-basics.md](references/layout-basics.md) - Core layout widgets and patterns
- [layout-common-widgets.md](references/layout-common-widgets.md) - Container, GridView, ListView, Stack, Card, ListTile
- [adaptive-workflow.md](references/adaptive-workflow.md) - Detailed 3-step adaptive design approach
- [adaptive-best-practices.md](references/adaptive-best-practices.md) - Design and implementation guidelines
- [adaptive-capabilities.md](references/adaptive-capabilities.md) - Capability/Policy pattern for platform behavior

### Example Code
- [responsive_navigation.dart](assets/responsive_navigation.dart) - NavigationBar ↔ NavigationRail switching
- [capability_policy_example.dart](assets/capability_policy_example.dart) - Capability/Policy class examples

### Scripts
This skill currently has no executable scripts. All guidance is in reference documentation.

### Assets
This skill includes complete Dart example files demonstrating:
- Responsive navigation patterns
- Capability and Policy implementation
- Adaptive layout strategies

These assets can be copied directly into your Flutter project or adapted to your needs.
