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

      return modelList;
    } catch (e) {
      throw "$e";
    }
  }
}
