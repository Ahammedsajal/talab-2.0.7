import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback? onTap;
  final Widget? icon;
  final bool centerTitle;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.buttonText,
    this.onTap,
    this.icon,
    this.centerTitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleWidget = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: centerTitle
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (centerTitle)
                Flexible(child: Center(child: titleWidget))
              else
                Expanded(child: titleWidget),
              if (!centerTitle && onTap != null)
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.4),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onTap!,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            buttonText,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios, size: 14),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
