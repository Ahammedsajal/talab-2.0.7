import 'package:Talab/data/model/custom_field/custom_field_model.dart';
import 'package:Talab/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:Talab/utils/hive_utils.dart';

class CustomFieldRepository {
  Future<List<CustomFieldModel>> getCustomFields(String categoryIds) async {
    try {
      Map<String, dynamic> parameters = {
        Api.categoryIds: categoryIds,
        Api.languageCode: HiveUtils.getLanguage()['code'] ?? ''
      };

      Map<String, dynamic> response = await Api.get(
          url: Api.getCustomFieldsApi, queryParameters: parameters);
          
          debugPrint('DEBUG getCustomFields response: $response');

      List<CustomFieldModel> modelList = (response['data'] as List)
          .map((e) => CustomFieldModel.fromMap(e))
          .toList();

      // Merge duplicate fields by id and prefer translated data
      final Map<String, CustomFieldModel> merged = {};
      for (final field in modelList) {
        final key = field.id?.toString() ?? '';
        if (merged.containsKey(key)) {
          final existing = merged[key]!;

          final bool existingHasTranslation =
              (existing.translatedName != null &&
                  existing.translatedName!.isNotEmpty) ||
                  existing.translatedValues != null;
          final bool fieldHasTranslation =
              (field.translatedName != null && field.translatedName!.isNotEmpty) ||
                  field.translatedValues != null;

          // Prefer the entry that contains translated data
          if (fieldHasTranslation && !existingHasTranslation) {
            merged[key] = field;
          }
        } else {
          merged[key] = field;
        }
      }

      final List<CustomFieldModel> result = merged.values.toList()
        ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

      return result;
    } catch (e) {
      throw "$e";
    }
  }
}
