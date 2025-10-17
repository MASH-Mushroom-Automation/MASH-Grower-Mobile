# Figma Design Extraction Guide for MASH App

## 🎨 Design Links Provided
- **DevMode Link**: https://www.figma.com/design/cqbzNHnSamXDRGYELe9CeI/MASH-Files?node-id=1-2325&m=dev&t=ruIlSsey3gmamazG-1
- **Full Share Link**: https://www.figma.com/design/cqbzNHnSamXDRGYELe9CeI/MASH-Files?node-id=1-2325&t=ruIlSsey3gmamazG-1

## 📋 Extraction Checklist

### Phase 1: Design Token Extraction

#### Colors
- [ ] Extract primary color palette
- [ ] Extract secondary colors
- [ ] Extract neutral/gray scale
- [ ] Extract semantic colors (success, error, warning)
- [ ] Extract background colors
- [ ] Note opacity variations

#### Typography
- [ ] Extract font families used
- [ ] Extract font sizes (H1, H2, H3, Body, Caption, etc.)
- [ ] Extract font weights (Light, Regular, Medium, Bold)
- [ ] Extract line heights
- [ ] Extract letter spacing

#### Spacing & Layout
- [ ] Extract padding values
- [ ] Extract margin values
- [ ] Extract border radius values
- [ ] Extract component heights
- [ ] Extract grid spacing

### Phase 2: Component Analysis

#### Buttons
- [ ] Primary button styles
- [ ] Secondary button styles
- [ ] Button sizes (small, medium, large)
- [ ] Button states (normal, pressed, disabled)

#### Cards
- [ ] Card elevation/shadows
- [ ] Card border radius
- [ ] Card padding
- [ ] Card background colors

#### Inputs
- [ ] Text field styling
- [ ] Border styles
- [ ] Placeholder text styling
- [ ] Error states

### Phase 3: Screen Layouts

#### Authentication Screens
- [ ] Login screen layout
- [ ] Register screen layout
- [ ] Logo positioning
- [ ] Form field spacing

#### Dashboard
- [ ] Sensor card layouts
- [ ] Chart positioning
- [ ] Status indicators
- [ ] Navigation elements

#### Device Management
- [ ] Device list item design
- [ ] Device status indicators
- [ ] Action button placement

## 🛠️ Extraction Tools

### Manual Extraction (Recommended for Accuracy)
1. **Open Figma in Browser**
2. **Take Screenshots** of key screens
3. **Use Figma's Inspect Panel** (press I or click the inspect icon)
4. **Export Assets**: Select elements and export as PNG/SVG

### Automated Extraction
```bash
# Using the installed figma-api-exporter
figma-api-exporter --token YOUR_FIGMA_TOKEN --file-id cqbzNHnSamXDRGYELe9CeI --node-id 1:2325

# Or use Figma's built-in export features
```

## 📊 Expected Design Tokens

Based on typical mobile app designs, we should extract:

### Colors (Hex Codes)
```dart
class DesignColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF______);
  static const Color primaryLight = Color(0xFF______);
  static const Color primaryDark = Color(0xFF______);

  // Secondary Colors
  static const Color secondary = Color(0xFF______);
  static const Color accent = Color(0xFF______);

  // Neutral Colors
  static const Color background = Color(0xFF______);
  static const Color surface = Color(0xFF______);
  static const Color textPrimary = Color(0xFF______);
  static const Color textSecondary = Color(0xFF______);
}
```

### Typography Scale
```dart
class DesignTypography {
  // Headlines
  static const double h1 = __;  // pixels
  static const double h2 = __;
  static const double h3 = __;

  // Body Text
  static const double bodyLarge = __;
  static const double bodyMedium = __;
  static const double bodySmall = __;

  // Supporting Text
  static const double caption = __;
  static const double overline = __;
}
```

### Spacing System
```dart
class DesignSpacing {
  static const double xs = __;   // 4px
  static const double sm = __;   // 8px
  static const double md = __;   // 16px
  static const double lg = __;   // 24px
  static const double xl = __;   // 32px
  static const double xxl = __;  // 48px
}
```

## 📝 Next Steps

1. **Review the Figma Design**: Open the provided links and explore the design
2. **Extract Design Tokens**: Use the checklist above to capture all design specifications
3. **Export Assets**: Download logos, icons, and images from Figma
4. **Document Findings**: Create a summary of the design specifications
5. **Begin Implementation**: Start updating Flutter components to match the design

## 🔗 Useful Resources

- [Figma Developer Documentation](https://www.figma.com/developers/api)
- [Flutter Design System Guidelines](https://material.io/design)
- [Converting Designs to Flutter](https://flutter.dev/docs/development/ui/layout)

## 📞 Questions to Ask Designer

- What is the primary brand color?
- Are there specific font requirements?
- What are the target device sizes?
- Are there dark mode designs?
- What are the key user flows?

---

*Ready to extract design tokens from your Figma file!* 🚀
