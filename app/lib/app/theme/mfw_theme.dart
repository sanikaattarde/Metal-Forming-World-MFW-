import 'package:flutter/material.dart';

import 'mfw_tokens.dart';

/// The app theme (MOD01-P2-T02), built from the design tokens only
/// (`DESIGN_TOKENS.md` section 6).
///
/// Light only, because the website has no dark scheme and none is proposed.
/// Text follows the device text size (OQ-25): the theme sets no scaler.
ThemeData buildMfwTheme() {
  const ColorScheme scheme = ColorScheme(
    brightness: Brightness.light,
    primary: MfwColours.action,
    onPrimary: MfwColours.onAction,
    secondary: MfwColours.actionPressed,
    onSecondary: MfwColours.onAction,
    error: MfwColours.error,
    onError: MfwColours.onAction,
    surface: MfwColours.surface,
    onSurface: MfwColours.heading,
    onSurfaceVariant: MfwColours.body,
    surfaceContainerLowest: MfwColours.surface,
    surfaceContainerLow: MfwColours.surface,
    surfaceContainer: MfwColours.surface,
    surfaceContainerHigh: MfwColours.surface,
    surfaceContainerHighest: MfwColours.inputFill,
    surfaceTint: Colors.transparent,
    outline: MfwColours.divider,
    outlineVariant: MfwColours.divider,
    inverseSurface: MfwColours.actionPressed,
    onInverseSurface: MfwColours.onAction,
  );

  final TextTheme textTheme = TextTheme(
    displayLarge: MfwType.display,
    displayMedium: MfwType.display,
    displaySmall: MfwType.display,
    headlineLarge: MfwType.h1,
    headlineMedium: MfwType.h2,
    headlineSmall: MfwType.h3,
    titleLarge: MfwType.h4,
    titleMedium: MfwType.h5,
    titleSmall: MfwType.formLabel,
    // Material draws text fields with bodyLarge, so it takes the website's
    // input text. List tiles, which also default to it, are set below.
    bodyLarge: MfwType.input,
    bodyMedium: MfwType.body,
    bodySmall: MfwType.small,
    labelLarge: MfwType.button,
    labelMedium: MfwType.label,
    labelSmall: MfwType.small,
  );

  const RoundedRectangleBorder square = RoundedRectangleBorder();
  const BorderSide hairline = BorderSide(color: MfwColours.divider);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: MfwFonts.inter,
    textTheme: textTheme,
    scaffoldBackgroundColor: MfwColours.surface,
    iconTheme: const IconThemeData(color: MfwColours.body),
    dividerTheme: const DividerThemeData(
      color: MfwColours.divider,
      thickness: MfwShape.stroke,
      space: MfwShape.stroke,
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: MfwColours.surface,
      foregroundColor: MfwColours.heading,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: MfwType.h4,
    ),
    filledButtonTheme: FilledButtonThemeData(style: _filledButtonStyle()),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _filledButtonStyle()),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _outlinedButtonStyle()),
    textButtonTheme: TextButtonThemeData(style: _textButtonStyle()),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: MfwColours.inputFill,
      labelStyle: MfwType.formLabel,
      floatingLabelStyle: MfwType.formLabel,
      hintStyle: MfwType.input.copyWith(color: MfwColours.body),
      helperStyle: MfwType.small,
      // Error text stays dark, because the red does not meet 4.5 to 1 on
      // white; the red border and an icon mark the error.
      errorStyle: MfwType.small.copyWith(color: MfwColours.heading),
      contentPadding: const EdgeInsets.all(MfwSpace.md),
      border: const OutlineInputBorder(borderSide: hairline),
      enabledBorder: const OutlineInputBorder(borderSide: hairline),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: MfwColours.actionPressed),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: MfwColours.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: MfwColours.error),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      elevation: const WidgetStatePropertyAll<double>(0),
      backgroundColor: const WidgetStatePropertyAll<Color>(
        MfwColours.inputFill,
      ),
      surfaceTintColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(MfwShape.searchRadius),
          ),
        ),
      ),
      textStyle: const WidgetStatePropertyAll<TextStyle>(MfwType.input),
      hintStyle: WidgetStatePropertyAll<TextStyle>(
        MfwType.input.copyWith(color: MfwColours.body),
      ),
      constraints: const BoxConstraints(minHeight: MfwShape.minTouchTarget),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: MfwType.h5,
      subtitleTextStyle: MfwType.body,
      leadingAndTrailingTextStyle: MfwType.small,
      iconColor: MfwColours.body,
      minTileHeight: MfwShape.minTouchTarget,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: MfwColours.inputFill,
      selectedColor: MfwColours.actionPressed,
      checkmarkColor: MfwColours.onAction,
      // Material chips resolve a state colour in the label style, so the
      // label turns white on the selected fill.
      labelStyle: MfwType.body.copyWith(
        color: WidgetStateColor.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected)
              ? MfwColours.onAction
              : MfwColours.heading,
        ),
      ),
      secondaryLabelStyle: MfwType.body.copyWith(color: MfwColours.onAction),
      side: hairline,
      shape: square,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: MfwColours.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      // A grey block behind the selected icon, so the selection is not
      // shown by colour alone (CODING_STANDARDS section 9).
      indicatorColor: MfwColours.inputFill,
      indicatorShape: square,
      iconTheme: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? MfwColours.action
              : MfwColours.body,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => MfwType.small.copyWith(
          color: states.contains(WidgetState.selected)
              ? MfwColours.action
              : MfwColours.body,
        ),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: MfwColours.action,
      unselectedLabelColor: MfwColours.body,
      indicatorColor: MfwColours.action,
      dividerColor: MfwColours.divider,
      labelStyle: MfwType.h5,
      unselectedLabelStyle: MfwType.h5,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: MfwColours.action,
      linearTrackColor: MfwColours.divider,
      circularTrackColor: MfwColours.divider,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: _selected(MfwColours.action, Colors.transparent),
      checkColor: const WidgetStatePropertyAll<Color>(MfwColours.onAction),
      side: const BorderSide(color: MfwColours.body),
      shape: square,
    ),
    radioTheme: RadioThemeData(
      fillColor: _selected(MfwColours.action, MfwColours.body),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: _selected(MfwColours.onAction, MfwColours.body),
      trackColor: _selected(MfwColours.action, MfwColours.inputFill),
      trackOutlineColor: _selected(MfwColours.action, MfwColours.body),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MfwColours.actionPressed,
      contentTextStyle: MfwType.body.copyWith(color: MfwColours.onAction),
      actionTextColor: MfwColours.onAction,
      shape: square,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: MfwColours.surface,
      surfaceTintColor: Colors.transparent,
      shape: square,
      titleTextStyle: MfwType.h3,
      contentTextStyle: MfwType.body,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: MfwColours.surface,
      surfaceTintColor: Colors.transparent,
      shape: square,
    ),
    cardTheme: const CardThemeData(
      color: MfwColours.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(side: hairline),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: MfwColours.heading,
      selectionColor: MfwColours.action.withValues(alpha: 0.3),
      selectionHandleColor: MfwColours.action,
    ),
  );
}

/// The filled red button of the website: square, a 1 px border in its own
/// colour, `#161616` when pressed, focused or hovered.
ButtonStyle _filledButtonStyle() {
  final WidgetStateProperty<Color> fill = WidgetStateProperty.resolveWith((
    Set<WidgetState> states,
  ) {
    if (states.contains(WidgetState.disabled)) {
      return MfwColours.divider;
    }
    if (_isActive(states)) {
      return MfwColours.actionPressed;
    }
    return MfwColours.action;
  });
  return ButtonStyle(
    backgroundColor: fill,
    foregroundColor: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => states.contains(WidgetState.disabled)
          ? MfwColours.body
          : MfwColours.onAction,
    ),
    overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    side: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => BorderSide(color: fill.resolve(states)),
    ),
    elevation: const WidgetStatePropertyAll<double>(0),
    textStyle: WidgetStatePropertyAll<TextStyle>(MfwType.button),
    shape: const WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(),
    ),
    minimumSize: const WidgetStatePropertyAll<Size>(
      Size(64, MfwShape.minTouchTarget),
    ),
    padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: MfwSpace.xl),
    ),
  );
}

/// A red outline and label, `#161616` when pressed, focused or hovered.
ButtonStyle _outlinedButtonStyle() {
  final WidgetStateProperty<Color> ink = _inkColour();
  return ButtonStyle(
    foregroundColor: ink,
    overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    side: WidgetStateProperty.resolveWith(
      (Set<WidgetState> states) => BorderSide(color: ink.resolve(states)),
    ),
    textStyle: WidgetStatePropertyAll<TextStyle>(MfwType.button),
    shape: const WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(),
    ),
    minimumSize: const WidgetStatePropertyAll<Size>(
      Size(64, MfwShape.minTouchTarget),
    ),
    padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: MfwSpace.xl),
    ),
  );
}

/// A red text link, as the website's "Read More" links.
ButtonStyle _textButtonStyle() {
  return ButtonStyle(
    foregroundColor: _inkColour(),
    overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    textStyle: WidgetStatePropertyAll<TextStyle>(MfwType.button),
    shape: const WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(),
    ),
    minimumSize: const WidgetStatePropertyAll<Size>(
      Size(MfwShape.minTouchTarget, MfwShape.minTouchTarget),
    ),
  );
}

WidgetStateProperty<Color> _inkColour() {
  return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) {
      return MfwColours.body;
    }
    return _isActive(states) ? MfwColours.actionPressed : MfwColours.action;
  });
}

bool _isActive(Set<WidgetState> states) =>
    states.contains(WidgetState.pressed) ||
    states.contains(WidgetState.focused) ||
    states.contains(WidgetState.hovered);

WidgetStateProperty<Color> _selected(Color selected, Color other) {
  return WidgetStateProperty.resolveWith(
    (Set<WidgetState> states) =>
        states.contains(WidgetState.selected) ? selected : other,
  );
}
