import 'package:Talab/data/model/custom_field/custom_field_model.dart';
import 'package:Talab/utils/api.dart';
import 'package:flutter/material.dart';

class CustomFieldRepository {
  Future<List<CustomFieldModel>> getCustomFields(String categoryIds) async {
    try {
      Map<String, dynamic> parameters = {
        Api.categoryIds: categoryIds,
      };

      Map<String, dynamic> response = await Api.get(
          url: Api.getCustomFieldsApi, queryParameters: parameters);
          
          debugPrint('DEBUG getCustomFields response: $response');

      List<CustomFieldModel> modelList = (response['data'] as List)
          .map((e) => CustomFieldModel.fromMap(e))
          .toList();

      // Merge duplicate fields by name and combine their values
      final Map<String, CustomFieldModel> merged = {};
      for (final field in modelList) {
        final key = (field.name ?? '').toLowerCase();
        if (merged.containsKey(key)) {
          final existing = merged[key]!;
          if (existing.values is List && field.values is List) {
            final List existingValues = List.from(existing.values as List);
            final List newValues = List.from(field.values as List);
            final Set combined = {...existingValues, ...newValues};
            existing.values = combined.toList();
          }
        } else {
          merged[key] = field;
        }
      }

      return merged.values.toList();
    } catch (e) {
      throw "$e";
    }
  }
}
