import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black26,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(message!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.nunito(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: GoogleFonts.nunito(
                  color: AppTheme.textTertiary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status.toUpperCase()) {
      case 'DRAFT':
        bgColor = const Color(0xFF1E2D3D);
        textColor = const Color(0xFF94A3B8);
        break;
      case 'LOCKED':
        bgColor = const Color(0xFF1A2B45);
        textColor = const Color(0xFF60A5FA);
        break;
      case 'ESCROW_FUNDED':
        bgColor = const Color(0xFF251A45);
        textColor = const Color(0xFFA78BFA);
        break;
      case 'ACTIVE':
        bgColor = const Color(0xFF0F2A1A);
        textColor = const Color(0xFF34D399);
        break;
      case 'IN_PROGRESS':
        bgColor = const Color(0xFF2A1A0F);
        textColor = const Color(0xFFFB923C);
        break;
      case 'SUBMITTED':
        bgColor = const Color(0xFF2A230F);
        textColor = const Color(0xFFFBBF24);
        break;
      case 'COMPLETED':
        bgColor = const Color(0xFF0F2028);
        textColor = const Color(0xFF2DD4BF);
        break;
      case 'DISPUTED':
        bgColor = const Color(0xFF2A0F18);
        textColor = const Color(0xFFF87171);
        break;
      default:
        bgColor = const Color(0xFF1E2D3D);
        textColor = const Color(0xFF94A3B8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: GoogleFonts.nunito(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
