import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const SettingTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20.0,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: trailing ??
              (onTap != null
                  ? Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).hintColor,
                    )
                  : null),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 72.0, right: 16.0),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
      ],
    );
  }
}
