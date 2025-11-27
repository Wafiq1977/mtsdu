import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final VoidCallback? onTrailingIconTap;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;

  const ListItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
    this.onTrailingIconTap,
    this.backgroundColor,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? Theme.of(context).cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: leadingIcon != null
            ? Icon(leadingIcon, color: Theme.of(context).primaryColor)
            : null,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: titleColor ?? Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: subtitleColor ?? Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        trailing: trailingIcon != null
            ? IconButton(
                icon: Icon(trailingIcon, color: Theme.of(context).primaryColor),
                onPressed: onTrailingIconTap,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
