import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import 'package:go_router/go_router.dart';
import '../providers/variant_providers.dart';
import 'confirmation_dialog.dart';

class VariantListTile extends ConsumerWidget {
  final Variant variant;

  const VariantListTile({
    super.key,
    required this.variant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(
        variant.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: variant.description != null && variant.description!.isNotEmpty
          ? Text(
              variant.description!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) async {
          if (value == 'edit') {
            context.go('/variants/${variant.id}/edit');
          } else if (value == 'delete') {
            final confirmed = await showConfirmationDialog(
              context,
              title: 'Delete Variant?',
              message:
                  'Are you sure you want to delete "${variant.name}"? This action cannot be undone.',
            );

            if (confirmed == true && context.mounted) {
              await ref
                  .read(variantListNotifierProvider.notifier)
                  .deleteVariant(variant.id);
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
