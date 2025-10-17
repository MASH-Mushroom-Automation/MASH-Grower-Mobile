# Figma to Flutter Design Integration Guide

## Overview
This guide outlines how to effectively use Figma designs as reference for Flutter development in the M.A.S.H. Grower Mobile App.

---

## 1. Design Handoff Preparation

### A. Figma Setup
1. **Access the Design File**
   - Get the Figma link from your designer
   - Ensure you have view/comment access
   - Bookmark the design file for quick access

2. **Design Organization**
   - Look for design system components
   - Identify reusable elements (buttons, cards, etc.)
   - Note spacing, typography, and color tokens

### B. Developer Tools Setup
```bash
# Install Figma plugins for developers
# 1. Anima (for prototyping)
# 2. TeleportHQ (code generation)
# 3. Figma to Flutter (component export)

# Install Flutter packages for design integration
flutter pub add flutter_svg      # For SVG assets
flutter pub add fluttericon      # For custom icons
flutter pub add google_fonts     # For custom fonts
```

---

## 2. Asset Extraction

### A. Export Assets from Figma
1. **Images and Icons**
   - Select assets in Figma
   - Export as PNG/SVG (preferably SVG for scalability)
   - Use 2x/3x scale for different screen densities

2. **Color Palette**
   - Extract hex codes from Figma styles
   - Create a color constants file

3. **Typography**
   - Note font families, sizes, weights
   - Create text theme configurations

### B. Asset Organization
```
assets/
├── images/
│   ├── logos/
│   ├── icons/
│   └── illustrations/
├── fonts/
└── animations/
```

---

## 3. Design Token Implementation

### A. Color System
```dart
// lib/core/theme/colors.dart
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF388E3C);

  // Secondary Colors
  static const Color secondary = Color(0xFF8BC34A);
  static const Color secondaryLight = Color(0xFFB2FF59);
  static const Color secondaryDark = Color(0xFF689F38);

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}
```

### B. Typography System
```dart
// lib/core/theme/text_styles.dart
class AppTextStyles {
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  );
}
```

---

## 4. Component Mapping

### A. Design to Flutter Widget Mapping

| Figma Element | Flutter Widget | Implementation |
|---------------|----------------|----------------|
| Rectangle/Button | ElevatedButton | Custom button component |
| Text Label | Text | Styled with theme |
| Card/Container | Card/Container | With shadows and padding |
| List | ListView | With custom item widgets |
| Navigation Bar | BottomNavigationBar | With icons and labels |
| Input Field | TextFormField | With validation and styling |
| Modal/Dialog | AlertDialog | With custom content |

### B. Screen Implementation Template
```dart
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        // Match Figma app bar design
        backgroundColor: AppColors.primary,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section - Match Figma layout
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              // Add content matching Figma design
            ),

            const SizedBox(height: 24),

            // Stats Cards - Match Figma grid layout
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Temperature',
                    value: '24°C',
                    icon: Icons.thermostat,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Humidity',
                    value: '65%',
                    icon: Icons.water_drop,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            // Additional sections matching Figma
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 5. Responsive Design Implementation

### A. Screen Size Breakpoints
```dart
// lib/core/utils/screen_utils.dart
class ScreenUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;
}
```

### B. Responsive Layout Implementation
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget tabletLayout;
  final Widget desktopLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    required this.tabletLayout,
    required this.desktopLayout,
  });

  @override
  Widget build(BuildContext context) {
    if (ScreenUtils.isDesktop(context)) {
      return desktopLayout;
    } else if (ScreenUtils.isTablet(context)) {
      return tabletLayout;
    } else {
      return mobileLayout;
    }
  }
}
```

---

## 6. Design System Consistency

### A. Component Library
Create reusable components matching Figma designs:

```dart
// lib/widgets/common/custom_button.dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: _getButtonStyle(),
      child: Text(text, style: _getTextStyle()),
    );
  }

  ButtonStyle _getButtonStyle() {
    // Match Figma button styles
    return ElevatedButton.styleFrom(
      backgroundColor: variant == ButtonVariant.primary
          ? AppColors.primary
          : AppColors.secondary,
      padding: _getPadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
```

### B. Theme Integration
```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      // ... match Figma typography
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        // Match Figma button specifications
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
```

---

## 7. Development Workflow

### A. Screen-by-Screen Implementation
1. **Review Figma Screen**
   - Take screenshots of the design
   - Note measurements, spacing, colors

2. **Create Component Hierarchy**
   - Break down the screen into components
   - Identify reusable elements

3. **Implement Layout**
   - Use Flutter layout widgets (Column, Row, Stack, etc.)
   - Match spacing and positioning from Figma

4. **Add Styling**
   - Apply colors, typography, shadows
   - Ensure responsive behavior

5. **Test & Iterate**
   - Compare with Figma design
   - Adjust for different screen sizes

### B. Collaboration Tools
1. **Figma Comments**: Use for design questions
2. **Shared Components**: Create a design system library
3. **Version Control**: Keep design and code in sync

---

## 8. Quality Assurance

### A. Design Comparison Checklist
- [ ] Colors match Figma palette
- [ ] Typography scales correctly
- [ ] Spacing follows design system
- [ ] Component interactions work as designed
- [ ] Responsive breakpoints match specifications
- [ ] Loading states and error states designed

### B. Cross-Platform Testing
- [ ] iOS appearance matches Figma
- [ ] Android appearance matches Figma
- [ ] Web version matches Figma
- [ ] Dark mode (if applicable)

---

## 9. Tools and Plugins

### A. Figma Plugins for Developers
1. **Figma to Flutter**: Export components as Flutter code
2. **TeleportHQ**: Convert designs to code
3. **Anima**: Interactive prototypes
4. **Figma Tokens**: Export design tokens

### B. Flutter Development Tools
1. **Flutter Inspector**: Debug layout issues
2. **Widgetbook**: Component library and testing
3. **Golden Tests**: Visual regression testing
4. **Device Preview**: Test across screen sizes

---

## 10. Best Practices

### A. Design Consistency
- Always reference the Figma design
- Use design tokens instead of hardcoded values
- Create reusable components for consistency

### B. Performance
- Optimize image assets (use SVG where possible)
- Implement proper caching for network images
- Use const constructors for static widgets

### C. Maintainability
- Document design decisions in code comments
- Keep components modular and reusable
- Use meaningful naming conventions

---

## Getting Started with Your Figma Design

To use your Figma design as reference:

1. **Share the Figma link** with development team
2. **Export required assets** (logos, icons, images)
3. **Create design tokens** (colors, typography, spacing)
4. **Implement screens** following the component mapping guide
5. **Test across devices** to ensure design fidelity

**Next Steps:**
1. Provide the Figma design link
2. Share any specific design questions
3. Let's start implementing screens based on the design specifications

---

*Document Version: 1.0 | Last Updated: October 17, 2025*
