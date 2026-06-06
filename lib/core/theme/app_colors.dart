import 'package:flutter/material.dart';

/// Midnight Finance palette — single source of truth for all colors.
/// Every screen and widget should reference these constants instead of
/// hardcoding hex literals.
class AppColors {
  AppColors._();

  // ── Backgrounds (layered depth) ──────────────────────────────────────────
  static const Color bg         = Color(0xFF070B14); // scaffold / deepest
  static const Color bgCard     = Color(0xFF0D1826); // cards, surfaces
  static const Color bgElevated = Color(0xFF112230); // bottom sheets, modals
  static const Color bgInput    = Color(0xFF162840); // form fields
  static const Color bgHover    = Color(0xFF1A3050); // hover / pressed states

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color borderSubtle  = Color(0xFF162340); // dividers
  static const Color borderDefault = Color(0xFF1D3050); // card borders
  static const Color borderStrong  = Color(0xFF2A4470); // emphasis borders

  // ── Brand — Violet-Indigo ─────────────────────────────────────────────────
  static const Color primary      = Color(0xFF7B5CF5);
  static const Color primaryDark  = Color(0xFF6344DF);
  static const Color primaryLight = Color(0xFF9E82FF);
  static const Color primaryGlow  = Color(0x337B5CF5); // 20% opacity glow

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFE8F0FF); // cool-white
  static const Color textSecondary = Color(0xFF7E98BE); // blue-gray
  static const Color textMuted     = Color(0xFF4A6280); // very muted

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00D4A1); // teal-emerald
  static const Color income  = Color(0xFF10D999); // income positive
  static const Color warning = Color(0xFFF5A524); // warm amber
  static const Color error   = Color(0xFFF05060); // warm red

  // ── Status badge fills (translucent on dark bg) ───────────────────────────
  static const Color pendingBg  = Color(0x26F5A524);
  static const Color pendingFg  = Color(0xFFFBBF24);
  static const Color overdueBg  = Color(0x26F05060);
  static const Color overdueFg  = Color(0xFFF87171);
  static const Color paidBg     = Color(0x2600D4A1);
  static const Color paidFg     = Color(0xFF2DD4BF);
  static const Color cancelledBg = Color(0x264A6280);
  static const Color cancelledFg = Color(0xFF7E98BE);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [Color(0xFF5440E0), Color(0xFF9B30F0)];
  static const List<Color> successGradient = [Color(0xFF00C48A), Color(0xFF00D4A1)];
  static const List<Color> cardGradient    = [Color(0xFF0D1826), Color(0xFF112230)];

  // ── Legacy aliases (keeps old imports compiling) ──────────────────────────
  static const Color bgDark          = bg;
  static const Color bgNavy          = bgCard;
  static const Color surface         = bgCard;
  static const Color surfaceHigh     = bgInput;
  static const Color border          = borderDefault;
  static const Color accentTeal      = Color(0xFF4CC9F0);
  static const Color accentBlue      = primary;
  static const Color textWhite       = textPrimary;
  static const Color textGray        = textSecondary;
  static const Color inputBg         = bgInput;
  static const Color cardBg          = bgCard;
  static const Color darkButton      = Color(0xFF0D1B2A);
  static const Color statusCompleted = success;
  static const Color statusCancelled = error;
  static const Color statusPending   = warning;
}
