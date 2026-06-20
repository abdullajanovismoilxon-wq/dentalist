import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String toPhoneFormat() {
    final digits = replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12) {
      return '+${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 8)} ${digits.substring(8, 10)} ${digits.substring(10)}';
    }
    return this;
  }

  bool isValidPhone() {
    return RegExp(r'^\+998\d{9}$').hasMatch(this);
  }
}

extension DateTimeExtensions on DateTime {
  String formatDate() {
    return DateFormat('dd.MM.yyyy').format(this);
  }

  String formatTime() {
    return DateFormat('HH:mm').format(this);
  }

  String formatDateTime() {
    return DateFormat('dd.MM.yyyy HH:mm').format(this);
  }

  String formatRelative() {
    final now = DateTime.now();
    final diff = difference(now);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Hozir';
        }
        return '${diff.inMinutes} min oldin';
      }
      return '${diff.inHours} soat oldin';
    } else if (diff.inDays == 1) {
      return 'Kecha';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} kun oldin';
    }
    return formatDate();
  }
}

extension BuildContextExtensions on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF0D9488),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void hideLoadingDialog() {
    Navigator.of(this, rootNavigator: true).pop();
  }
}
