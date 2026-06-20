import 'package:flutter/material.dart';
import '../core/constants.dart';

// ── AppBadge ────────────────────────────────────────────────
enum BadgeVariant { default_, success, warning, danger, info, primary }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final double fontSize;

  const AppBadge(this.label, {super.key, this.variant = BadgeVariant.default_, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
      final colors = {
      BadgeVariant.default_: (Color(AppColors.textSecondary), const Color(AppColors.divider)),
      BadgeVariant.success: (const Color(AppColors.success), const Color(AppColors.success).withValues(alpha: 0.1)),
      BadgeVariant.warning: (const Color(AppColors.warning), const Color(AppColors.warning).withValues(alpha: 0.1)),
      BadgeVariant.danger: (const Color(AppColors.error), const Color(AppColors.error).withValues(alpha: 0.1)),
      BadgeVariant.info: (const Color(AppColors.primary), const Color(AppColors.primaryLight)),
      BadgeVariant.primary: (Colors.white, const Color(AppColors.primary)),
    };
    final (fg, bg) = colors[variant]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: fontSize, color: fg, fontWeight: FontWeight.w500)),
    );
  }
}

// ── AppButton ───────────────────────────────────────────────
enum ButtonVariant { primary, secondary, outline, ghost, danger }
enum ButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color? borderColor) = switch (variant) {
      ButtonVariant.primary => (Color(AppColors.primary), Colors.white, null),
      ButtonVariant.secondary => (Color(AppColors.secondary), Colors.white, null),
      ButtonVariant.outline => (Colors.transparent, Color(AppColors.primary), Color(AppColors.primary)),
      ButtonVariant.ghost => (Colors.transparent, Color(AppColors.primary), null),
      ButtonVariant.danger => (Color(AppColors.error), Colors.white, null),
    };
    final (double h, double fontSz, double iconSz, EdgeInsets padding) = switch (size) {
      ButtonSize.sm => (36.0, 13.0, 16.0, const EdgeInsets.symmetric(horizontal: 14)),
      ButtonSize.md => (46.0, 15.0, 18.0, const EdgeInsets.symmetric(horizontal: 20)),
      ButtonSize.lg => (52.0, 17.0, 20.0, const EdgeInsets.symmetric(horizontal: 28)),
    };

    return SizedBox(
      width: width ?? double.infinity,
      height: h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.5),
          disabledForegroundColor: fg.withValues(alpha: 0.5),
          side: borderColor != null ? BorderSide(color: borderColor) : null,
          elevation: variant == ButtonVariant.ghost ? 0 : (variant == ButtonVariant.outline ? 0 : 1),
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          shadowColor: variant == ButtonVariant.primary ? const Color(AppColors.primary).withValues(alpha: 0.3) : Colors.transparent,
        ),
        child: isLoading
            ? SizedBox(width: iconSz, height: iconSz, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[Icon(icon, size: iconSz), const SizedBox(width: 6)],
                Text(label, style: TextStyle(fontSize: fontSz, fontWeight: FontWeight.w600)),
              ]),
      ),
    );
  }
}

// ── AppStarRating ───────────────────────────────────────────
enum StarSize { sm, md, lg }

class AppStarRating extends StatelessWidget {
  final double rating;
  final int maxStars;
  final StarSize size;
  final bool interactive;
  final ValueChanged<double>? onChanged;

  const AppStarRating({
    super.key,
    this.rating = 0,
    this.maxStars = 5,
    this.size = StarSize.md,
    this.interactive = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = switch (size) { StarSize.sm => 14.0, StarSize.md => 18.0, StarSize.lg => 24.0 };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (i) {
        final star = (i + 1).toDouble();
        final isFull = rating >= star;
        final isHalf = !isFull && rating >= star - 0.5;
        return GestureDetector(
          onTap: interactive ? () => onChanged?.call(star) : null,
          child: Padding(
            padding: EdgeInsets.only(right: iconSize * 0.15),
            child: Icon(
              isFull ? Icons.star : (isHalf ? Icons.star_half : Icons.star_border),
              size: iconSize,
              color: isFull || isHalf ? Color(AppColors.warning) : Color(AppColors.border),
            ),
          ),
        );
      }),
    );
  }
}

// ── AppStarBreakdown ────────────────────────────────────────
class AppStarBreakdown extends StatelessWidget {
  final Map<int, int> counts; // star -> count, e.g. {5: 30, 4: 15, ...}
  final int totalReviews;

  const AppStarBreakdown({super.key, required this.counts, required this.totalReviews});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (i) {
        final star = 5 - i;
        final count = counts[star] ?? 0;
        final pct = totalReviews > 0 ? count / totalReviews : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              SizedBox(width: 40, child: Text('$star', style: const TextStyle(fontSize: 13, color: Color(AppColors.textSecondary)))),
              const Icon(Icons.star, size: 14, color: Color(AppColors.warning)),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: const Color(AppColors.divider),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(AppColors.warning)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(width: 30, child: Text('$count', style: const TextStyle(fontSize: 12, color: Color(AppColors.textSecondary)))),
            ],
          ),
        );
      }),
    );
  }
}

// ── AppCard ─────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;

  const AppCard({super.key, required this.child, this.padding, this.margin, this.elevation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(AppColors.surface),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.cardShadow),
            blurRadius: elevation ?? 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
    );
  }
}

class AppCardHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const AppCardHeader({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 12),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(AppColors.textPrimary)),
        child: child,
      ),
    );
  }
}
