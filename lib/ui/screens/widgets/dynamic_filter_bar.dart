import 'package:flutter/material.dart';
import 'package:Talab/data/model/custom_field/custom_field_model.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';

typedef FilterValueChanged = void Function(int id, dynamic value);

class DynamicFilterBar extends StatelessWidget {
  final List<CustomFieldModel> fields;
  final Map<int, dynamic> selectedValues;
  final FilterValueChanged onChanged;

  const DynamicFilterBar({
    super.key,
    required this.fields,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = fields.where((f) {
      final name = (f.name ?? '').toLowerCase();
      final isValid = f.id != null && f.type != null && name != 'ad_type';
      if (!isValid) return false;
      if (f.type?.toLowerCase() == 'range') return true;
      return f.values is List && (f.values as List).isNotEmpty;
    }).toList();

    if (filtered.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: filtered
              .map(
                (field) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFieldWidget(context, field),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFieldWidget(BuildContext context, CustomFieldModel field) {
    switch (field.type?.toLowerCase()) {
      case 'checkbox':
        return _CheckboxFilter(
          field: field,
          selected: selectedValues[field.id] as List<dynamic>?,
          onChanged: (v) => onChanged(field.id!, v),
        );
      case 'range':
        return _RangeFilter(
          field: field,
          values: selectedValues[field.id] as Map<String, dynamic>?,
          onChanged: (v) => onChanged(field.id!, v),
        );
      default:
        return _DropdownFilter(
          field: field,
          selected: selectedValues[field.id],
          onChanged: (v) => onChanged(field.id!, v),
        );
    }
  }
}

class _DropdownFilter extends StatelessWidget {
  final CustomFieldModel field;
  final dynamic selected;
  final ValueChanged<dynamic> onChanged;

  const _DropdownFilter({
    required this.field,
    this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<dynamic>(
      value: selected,
      hint: CustomText(field.name!, fontSize: context.font.small),
      underline: const SizedBox.shrink(),
      onChanged: onChanged,
      items: (field.values as List)
          .map<DropdownMenuItem<dynamic>>(
            (e) => DropdownMenuItem(value: e, child: CustomText('$e')),
          )
          .toList(),
    );
  }
}

class _CheckboxFilter extends StatelessWidget {
  final CustomFieldModel field;
  final List<dynamic>? selected;
  final ValueChanged<List<dynamic>> onChanged;

  const _CheckboxFilter({
    required this.field,
    this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final display = (selected == null || selected!.isEmpty)
        ? field.name!
        : '${field.name}: ${selected!.join(', ')}';
    return InkWell(
      onTap: () async {
        final values = List<dynamic>.from(selected ?? []);
        final allValues = List.from(field.values as List);
        final result = await showDialog<List<dynamic>>(
          context: context,
          builder: (context) {
            return _MultiSelectDialog(
              title: field.name ?? '',
              options: allValues,
              initial: values,
            );
          },
        );
        if (result != null) {
          onChanged(result);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(display, fontSize: context.font.small),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}

class _MultiSelectDialog extends StatefulWidget {
  final String title;
  final List options;
  final List initial;

  const _MultiSelectDialog({
    required this.title,
    required this.options,
    required this.initial,
  });

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List _tempSelected;

  @override
  void initState() {
    _tempSelected = List.from(widget.initial);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.options
              .map(
                (o) => CheckboxListTile(
                  value: _tempSelected.contains(o),
                  title: Text('$o'),
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _tempSelected.add(o);
                      } else {
                        _tempSelected.remove(o);
                      }
                    });
                  },
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _tempSelected),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _RangeFilter extends StatelessWidget {
  final CustomFieldModel field;
  final Map<String, dynamic>? values;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _RangeFilter({
    required this.field,
    this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final display = (values == null ||
            (values?['min'] == null && values?['max'] == null))
        ? field.name!
        : '${field.name}: ${values?['min'] ?? ''}-${values?['max'] ?? ''}';
    return InkWell(
      onTap: () async {
        final minController =
            TextEditingController(text: values?['min']?.toString() ?? '');
        final maxController =
            TextEditingController(text: values?['max']?.toString() ?? '');
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(field.name ?? ''),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: minController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'From'),
                  ),
                  TextField(
                    controller: maxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'To'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'min': minController.text.isEmpty
                          ? null
                          : minController.text,
                      'max': maxController.text.isEmpty
                          ? null
                          : maxController.text,
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        if (result != null) {
          onChanged(result);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(display, fontSize: context.font.small),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
