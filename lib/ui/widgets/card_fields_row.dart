import 'package:Talab/data/model/item/item_card_field.dart';
import 'package:flutter/material.dart';

/// Builds a compact row of up to two card fields.
///
/// The UI shows only the value of each field. When the [category]
/// belongs to Real Estate, an area icon is placed before the field
/// named "area" (case-insensitive) or the first field if an area field
/// is not found within the first two entries.
Widget buildCardFieldsRow(
  BuildContext context,
  String category,
  List<ItemCardField>? cardFields,
) {
  if (cardFields == null || cardFields.isEmpty) {
    return const SizedBox.shrink();
  }

  // Whether the item is in the Real Estate category.
  final bool isRealEstate = category.toLowerCase().contains('real estate');

  // Take only the first two fields to keep the row compact.
  final List<ItemCardField> visibleFields =
      cardFields.take(2).toList(growable: false);

  // Determine which field should display the area icon.
  int areaIconIndex = visibleFields.indexWhere(
    (f) => (f.name ?? '').toLowerCase() == 'area',
  );
  if (isRealEstate && areaIconIndex == -1) {
    areaIconIndex = 0; // Fallback to the first field.
  }

  // Text style mirrors the card's default styling.
  final TextStyle valueStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        fontWeight: FontWeight.normal,
      );

  // Helper to build an individual field widget.
  Widget buildField(ItemCardField field, bool withIcon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (withIcon) ...[
          Icon(Icons.square_foot,
              size: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 2),
        ],
        Flexible(
          child: Text(
            field.value ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valueStyle,
          ),
        ),
      ],
    );
  }

  final List<Widget> children = [
    Expanded(child: buildField(visibleFields[0], isRealEstate && areaIconIndex == 0)),
  ];

  if (visibleFields.length > 1) {
    children.add(const SizedBox(width: 8));
    children.add(
      Expanded(
        child: buildField(
          visibleFields[1],
          isRealEstate && areaIconIndex == 1,
        ),
      ),
    );
  }

  // Row ensures the fields appear side by side with spacing and no wrapping.
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: children,
  );
}
