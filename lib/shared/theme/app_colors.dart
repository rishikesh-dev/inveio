import 'package:flutter/material.dart';

/// Central palette of all colors used in the app, organized by usage.
class AppColors {
  /// Primary brand color – electric lime for CTAs.
  static const primary = Color(0xFFB5FF45);

  /// Accent brand color – income green.
  static const primaryAccent = Color(0xFF00D97E);

  /// Lighter variant of the primary brand color.
  static const primaryLight = Color(0xFFD7FF75);

  /// Dark variant of the primary brand color, used for backgrounds.
  static const primaryDark = Color(0xFF0D1F1A);

  /// Primary brand color with reduced opacity.
  static const primaryAlpha = Color(0x26B5FF45);

  /// Semantic color for income indicators.
  static const income = Color(0xFF00D97E);

  //Semantic color for danger/error indicators.
  static const danger = Color(0xFFE0524A);

  /// Semantic color for expense indicators.
  static const expense = Color(0xFFFF9696);

  /// Semantic color for warning states.
  static const warning = Color(0xFFFFD45C);

  /// Semantic color for informational states.
  static const info = Color(0xFF8AB7FF);

  /// Income color with reduced opacity.
  static const incomeAlpha = Color(0x2600D97E);

  /// Expense color with reduced opacity.
  static const expenseAlpha = Color(0x26FF9696);

  /// Warning color with reduced opacity.
  static const warningAlpha = Color(0x26FFD45C);

  /// Info color with reduced opacity.
  static const infoAlpha = Color(0x268AB7FF);

  /// Dark theme – primary background color.
  static const darkBg = Color(0xFF090C09);

  /// Dark theme – shell/outer container background.
  static const darkShell = Color(0xFF0D1208);

  /// Dark theme – surface background.
  static const darkSurface = Color(0xFF111511);

  /// Dark theme – card background.
  static const darkCard = Color(0xFF151A12);

  /// Dark theme – alternate card background.
  static const darkCardAlt = Color(0xFF171E10);

  /// Dark theme – input field background.
  static const darkInput = Color(0xFF13180F);

  /// Dark theme – muted panel background.
  static const darkMutedPanel = Color(0xFF1E2A18);

  /// Dark theme – border color.
  static const darkBorder = Color(0xFF252D1E);

  /// Dark theme – softer border color.
  static const darkBorderSoft = Color(0xFF1E2A18);

  /// Light theme – primary background color.
  static const lightBg = Color(0xFFF0F5F2);

  /// Light theme – surface background.
  static const lightSurface = Color(0xFFFFFFFF);

  /// Light theme – card background.
  static const lightCard = Color(0xFFFFFFFF);

  /// Light theme – alternate card background.
  static const lightCardAlt = Color(0xFFE4EDE8);

  /// Light theme – border color.
  static const lightBorder = Color(0xFFCCDDD5);

  /// Light theme – softer border color.
  static const lightBorderSoft = Color(0xFFDCE8E2);

  /// Dark theme – primary text color.
  static const darkTextPrimary = Color(0xFFF7F7F0);

  /// Dark theme – secondary text color.
  static const darkTextSecondary = Color(0xFFC9CEB2);

  /// Dark theme – muted text color.
  static const darkTextMuted = Color(0xFF7C8C78);

  /// Light theme – primary text color.
  static const lightTextPrimary = Color(0xFF0D1F1A);

  /// Light theme – secondary text color.
  static const lightTextSecondary = Color(0xFF1A3C34);

  /// Light theme – muted text color.
  static const lightTextMuted = Color(0xFF6B8C7A);

  /// Category color – food & dining.
  static const catFood = Color(0xFFFF9F43);

  /// Category color – transport.
  static const catTransport = Color(0xFF54A0FF);

  /// Category color – shopping.
  static const catShopping = Color(0xFFFF6B9D);

  /// Category color – utilities.
  static const catUtilities = Color(0xFFFFD45C);

  /// Category color – software & subscriptions.
  static const catSoftware = Color(0xFFA29BFE);

  /// Category color – other expenses.
  static const catOther = Color(0xFF8395A7);

  /// Food category color with reduced opacity.
  static const catFoodAlpha = Color(0x26FF9F43);

  /// Transport category color with reduced opacity.
  static const catTransportAlpha = Color(0x2654A0FF);

  /// Shopping category color with reduced opacity.
  static const catShoppingAlpha = Color(0x26FF6B9D);

  /// Utilities category color with reduced opacity.
  static const catUtilitiesAlpha = Color(0x26FFD45C);

  /// Software category color with reduced opacity.
  static const catSoftwareAlpha = Color(0x26A29BFE);

  /// Other category color with reduced opacity.
  static const catOtherAlpha = Color(0x268395A7);

  /// GST status color for paid invoices.
  static const gstPaid = income;

  /// GST status color for pending invoices.
  static const gstPending = warning;

  /// GST status color for overdue invoices.
  static const gstOverdue = expense;
}
