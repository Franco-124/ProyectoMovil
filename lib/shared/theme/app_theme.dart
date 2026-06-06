import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ── Color Scheme ──────────────────────────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary:                AppColors.primary,
        onPrimary:              Colors.white,
        primaryContainer:       Color(0xFF2D1A80),
        onPrimaryContainer:     Color(0xFFE8DFFF),
        secondary:              AppColors.primaryLight,
        onSecondary:            Colors.white,
        secondaryContainer:     Color(0xFF1E1060),
        onSecondaryContainer:   Color(0xFFD4C8FF),
        surface:                AppColors.bgCard,
        onSurface:              AppColors.textPrimary,
        surfaceContainerHighest:AppColors.borderDefault,
        onSurfaceVariant:       AppColors.textSecondary,
        outline:                AppColors.borderDefault,
        outlineVariant:         AppColors.borderSubtle,
        error:                  AppColors.error,
        onError:                Colors.white,
        shadow:                 Colors.black,
        scrim:                  Colors.black87,
      ),

      scaffoldBackgroundColor: AppColors.bg,

      // ── Typography ────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge:  TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 28),
        headlineMedium:TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 24),
        headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 20),
        titleLarge:    TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
        titleMedium:   TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall:    TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        bodyLarge:     TextStyle(color: AppColors.textPrimary,   fontSize: 16, height: 1.5),
        bodyMedium:    TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        bodySmall:     TextStyle(color: AppColors.textMuted,     fontSize: 12, height: 1.4),
        labelLarge:    TextStyle(color: AppColors.textPrimary,   fontWeight: FontWeight.w600, fontSize: 14),
        labelMedium:   TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500, fontSize: 12),
        labelSmall:    TextStyle(color: AppColors.textMuted,     fontWeight: FontWeight.w500, fontSize: 10, letterSpacing: 0.6),
      ),

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor:     AppColors.bg,
        elevation:           0,
        scrolledUnderElevation: 0,
        surfaceTintColor:    Colors.transparent,
        centerTitle:         false,
        titleTextStyle: TextStyle(
          color:       AppColors.textPrimary,
          fontSize:    20,
          fontWeight:  FontWeight.w700,
          letterSpacing: -0.4,
        ),
        iconTheme:     IconThemeData(color: AppColors.textSecondary, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // ── NavigationBar ─────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:  AppColors.bgCard,
        surfaceTintColor: Colors.transparent,
        shadowColor:      Colors.black,
        elevation:        0,
        height:           68,
        labelBehavior:    NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor:   AppColors.primaryGlow,
        indicatorShape:   RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? const IconThemeData(color: AppColors.primary, size: 22)
              : const IconThemeData(color: AppColors.textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? const TextStyle(color: AppColors.primary,   fontSize: 10, fontWeight: FontWeight.w700)
              : const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500);
        }),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color:            AppColors.bgCard,
        elevation:        0,
        shadowColor:      Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.borderDefault),
        ),
        margin:      EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:              true,
        fillColor:           AppColors.bgInput,
        hintStyle:           const TextStyle(color: AppColors.textMuted, fontSize: 14),
        labelStyle:          const TextStyle(color: AppColors.textMuted, fontSize: 14),
        floatingLabelStyle:  const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
        prefixIconColor:     AppColors.textMuted,
        suffixIconColor:     AppColors.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:          AppColors.primary,
          foregroundColor:          Colors.white,
          disabledBackgroundColor:  AppColors.primaryGlow,
          disabledForegroundColor:  Colors.white54,
          elevation:    0,
          shadowColor:  Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(double.infinity, 52),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.borderDefault),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor:  AppColors.primary,
        foregroundColor:  Colors.white,
        elevation:        6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        extendedTextStyle: TextStyle(
          fontSize:      14,
          fontWeight:    FontWeight.w600,
          letterSpacing: 0.3,
        ),
        extendedPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      ),

      // ── Chips ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:  AppColors.bgCard,
        selectedColor:    AppColors.primaryGlow,
        checkmarkColor:   AppColors.primary,
        labelStyle:       const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        side:             const BorderSide(color: AppColors.borderDefault),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color:     AppColors.borderSubtle,
        thickness: 1,
        space:     1,
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        textColor:        AppColors.textPrimary,
        iconColor:        AppColors.textMuted,
        subtitleTextStyle:TextStyle(color: AppColors.textSecondary, fontSize: 13),
        tileColor:        Colors.transparent,
        contentPadding:   EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth:  24,
        visualDensity:    VisualDensity.comfortable,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor:    AppColors.bgElevated,
        surfaceTintColor:   Colors.transparent,
        elevation:          16,
        shadowColor:        Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle:   const TextStyle(color: AppColors.textPrimary,   fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:  AppColors.bgElevated,
        surfaceTintColor: Colors.transparent,
        elevation:        0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle:   true,
        dragHandleColor:  AppColors.borderStrong,
        dragHandleSize:   Size(40, 4),
      ),

      // ── Popup Menu ────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color:            AppColors.bgElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        elevation: 12,
        shadowColor: Colors.black54,
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : AppColors.textMuted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.primary : AppColors.borderDefault),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color:             AppColors.primary,
        linearTrackColor:  AppColors.borderDefault,
        circularTrackColor:AppColors.borderDefault,
      ),

      // ── Snack Bar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgElevated,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderDefault),
        ),
        behavior:    SnackBarBehavior.floating,
        elevation:   8,
        insetPadding:const EdgeInsets.all(12),
      ),

      // ── Refresh Indicator ─────────────────────────────────────────────────
      // color comes from colorScheme.primary (set above) ✓
    );
  }
}
