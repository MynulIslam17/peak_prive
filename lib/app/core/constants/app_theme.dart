import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'text-style.dart';

/// The app's single `ThemeData`.
///
/// `GetMaterialApp` previously had no `theme:` at all, so every screen
/// re-specified its own background, app bar, input borders and button colours.
/// That is the source of the drift between otherwise-identical screens
/// (five different page backgrounds, four incompatible app bars, three golds).
/// Defining it centrally means a screen that specifies nothing now looks
/// correct by default.
///
/// Inputs, buttons, cards and icons are deliberately NOT themed here: the
/// existing screens style those themselves, and a global style drew double
/// borders inside their own boxes.
abstract class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary_1,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary_1,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.secendary,
      onSecondary: AppColors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.white,
      outline: AppColors.border,
      // The seed's tertiary is green; it shows as the selected AM/PM in
      // time pickers. Keep it in the gold palette.
      tertiaryContainer: AppColors.goldTint,
      onTertiaryContainer: AppColors.goldDeep,
      // Material 3 paints dialogs, pickers and menus with these; the seed
      // made them cream. Keep every popup white like the pages.
      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.white,
      surfaceContainer: AppColors.white,
      surfaceContainerHigh: AppColors.white,
    );

    WidgetStateProperty<Color?> pick(Color selected, Color normal, {Color? disabled}) =>
        WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled) && disabled != null) return disabled;
          return s.contains(WidgetState.selected) ? selected : normal;
        });

    // Time picker colours take a WidgetStateColor instead.
    Color pickColor(Color selected, Color normal) =>
        WidgetStateColor.resolveWith((s) => s.contains(WidgetState.selected) ? selected : normal);

    final pickerButton = TextButton.styleFrom(
      foregroundColor: AppColors.goldDeep,
      textStyle: AppTextStyle.sub_h3_semibold_14(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    final pickerConfirm = TextButton.styleFrom(
      foregroundColor: AppColors.textOnPrimary,
      backgroundColor: AppColors.primary_1,
      textStyle: AppTextStyle.sub_h3_semibold_14(),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
    const pickerShape = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24)));

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.scaffold,
      primaryColor: AppColors.primary_1,
      dividerColor: AppColors.divider,
      disabledColor: AppColors.disabled,
      splashFactory: InkSparkle.splashFactory,
      textTheme: _textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: AppTextStyle.sub_h1_medium_18(),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),


      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),







      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.black_1,
        contentTextStyle: AppTextStyle.sub_h3_regular_14(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyle.sub_h1_medium_18(),
        contentTextStyle: AppTextStyle.sub_h3_regular_14(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Calendars: white, gold selected day, gold ring on today.
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: pickerShape,
        headerBackgroundColor: AppColors.white,
        headerForegroundColor: AppColors.textPrimary,
        headerHelpStyle: AppTextStyle.p_medium_12(color: AppColors.textTertiary),
        headerHeadlineStyle: AppTextStyle.h2_semibold_22(color: AppColors.textPrimary),
        weekdayStyle: AppTextStyle.p_medium_12(color: AppColors.textTertiary),
        dayStyle: AppTextStyle.sub_h3_medium_14(),
        dividerColor: AppColors.divider,
        dayForegroundColor: pick(AppColors.textOnPrimary, AppColors.textPrimary, disabled: AppColors.textDisabled),
        dayBackgroundColor: pick(AppColors.primary_1, Colors.transparent),
        dayOverlayColor: WidgetStatePropertyAll(AppColors.primary_1.withValues(alpha: 0.12)),
        todayForegroundColor: pick(AppColors.textOnPrimary, AppColors.goldDeep),
        todayBackgroundColor: pick(AppColors.primary_1, Colors.transparent),
        todayBorder: const BorderSide(color: AppColors.primary_1, width: 1.2),
        yearForegroundColor: pick(AppColors.textOnPrimary, AppColors.textPrimary, disabled: AppColors.textDisabled),
        yearBackgroundColor: pick(AppColors.primary_1, Colors.transparent),
        rangeSelectionBackgroundColor: AppColors.goldTint,
        rangePickerBackgroundColor: AppColors.white,
        rangePickerHeaderBackgroundColor: AppColors.white,
        rangePickerHeaderForegroundColor: AppColors.textPrimary,
        cancelButtonStyle: pickerButton,
        confirmButtonStyle: pickerConfirm,
      ),

      // Time pickers: white, the active hour/minute and AM/PM in gold tint.
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.white,
        elevation: 6,
        shape: pickerShape,
        helpTextStyle: AppTextStyle.p_medium_12(color: AppColors.textTertiary),
        hourMinuteShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
        hourMinuteColor: pickColor(AppColors.goldTint, const Color(0xFFF4F4F4)),
        hourMinuteTextColor: pickColor(AppColors.goldDeep, AppColors.textPrimary),
        dayPeriodShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        dayPeriodBorderSide: const BorderSide(color: AppColors.border),
        dayPeriodColor: pickColor(AppColors.goldTint, AppColors.white),
        dayPeriodTextColor: pickColor(AppColors.goldDeep, AppColors.textTertiary),
        dialBackgroundColor: const Color(0xFFF6F6F6),
        dialHandColor: AppColors.primary_1,
        dialTextColor: pickColor(AppColors.textOnPrimary, AppColors.textPrimary),
        entryModeIconColor: AppColors.textTertiary,
        cancelButtonStyle: pickerButton,
        confirmButtonStyle: pickerConfirm,
      ),

      popupMenuTheme: const PopupMenuThemeData(color: AppColors.white, surfaceTintColor: Colors.transparent),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary_1,
        linearTrackColor: AppColors.border,
      ),





      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }


  static TextTheme get _textTheme => GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: AppTextStyle.h1_smibold(),
        displayMedium: AppTextStyle.h1_medium_24(),
        headlineLarge: AppTextStyle.h2_semibold_22(),
        headlineMedium: AppTextStyle.h2_medium_22(),
        headlineSmall: AppTextStyle.h3_semibold_20(),
        titleLarge: AppTextStyle.h3_medium_20(),
        titleMedium: AppTextStyle.sub_h1_medium_18(),
        titleSmall: AppTextStyle.sub_h2_medium_16(),
        bodyLarge: AppTextStyle.sub_h2_regular_16(),
        bodyMedium: AppTextStyle.sub_h3_regular_14(),
        bodySmall: AppTextStyle.p_regular_12(),
        labelLarge: AppTextStyle.sub_h3_medium_14(),
        labelMedium: AppTextStyle.p_medium_12(),
        labelSmall: AppTextStyle.c_regular_10(),
      );
}
