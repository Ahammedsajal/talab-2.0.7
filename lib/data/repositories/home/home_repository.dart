import 'package:Talab/data/model/home/home_screen_section.dart';
import 'package:Talab/utils/api.dart';
import 'package:Talab/data/model/data_output.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/model/item_filter_model.dart';

class HomeRepository {
  Future<List<HomeScreenSection>> fetchHome(
      {String? country, String? state, String? city, int? areaId}) async {
    try {
      Map<String, dynamic> parameters = {
        if (city != null && city != "") 'city': city,
        if (areaId != null && areaId != "") 'area_id': areaId,
        if (country != null && country != "") 'country': country,
        if (state != null && state != "") 'state': state,
      };

      Map<String, dynamic> response = await Api.get(
          url: Api.getFeaturedSectionApi, queryParameters: parameters);
      List<HomeScreenSection> homeScreenDataList =
          (response['data'] as List).map((element) {
        return HomeScreenSection.fromJson(element);
      }).toList();

      return homeScreenDataList;
    } catch (e) {
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchHomeAllItems(
      {required int page,
      String? country,
      String? state,
      String? city,
      double? latitude,
      double? longitude,
      int? areaId,
      int? radius}) async {
    try {
      Map<String, dynamic> parameters = {
        "page": page,
        if (radius == null) ...{
          if (city != null && city != "") 'city': city,
          if (areaId != null && areaId != "") 'area_id': areaId,
          if (country != null && country != "") 'country': country,
          if (state != null && state != "") 'state': state,
        },
        if (radius != null && radius != "") 'radius': radius,
        if (latitude != null && latitude != "") 'latitude': latitude,
        if (longitude != null && longitude != "") 'longitude': longitude,
        "sort_by": "new-to-old"
      };

      Map<String, dynamic> response =
          await Api.get(url: Api.getItemApi, queryParameters: parameters);
      List<ItemModel> items = (response['data']['data'] as List)
          .map((e) => ItemModel.fromJson(e))
          .toList();

      return DataOutput(
          total: response['data']['total'] ?? 0, modelList: items);
    } catch (error) {
      rethrow;
    }
  }

  Future<DataOutput<ItemModel>> fetchSectionItems(
      {required int page,
      required int sectionId,
      String? country,
      String? state,
      String? city,
      int? areaId,
      ItemFilterModel? filter}) async {
    try {
      Map<String, dynamic> parameters = {
        "page": page,
        "featured_section_id": sectionId,
      };

      if (filter != null) {
        parameters.addAll(filter.toMap());

        if (filter.radius != null) {
          if (filter.latitude != null && filter.longitude != null) {
            parameters['latitude'] = filter.latitude;
            parameters['longitude'] = filter.longitude;
          }

          parameters.remove('city');
          parameters.remove('area');
          parameters.remove('area_id');
          parameters.remove('country');
          parameters.remove('state');
        } else {
          if (city != null && city != "") parameters['city'] = city;
          if (areaId != null) parameters['area_id'] = areaId;
          if (country != null && country != "") parameters['country'] = country;
          if (state != null && state != "") parameters['state'] = state;
        }

        if (filter.areaId == null) {
          parameters.remove('area_id');
        }

        parameters.remove('area');

        if (filter.customFields != null) {
          filter.customFields!.forEach((key, value) {
            if (value is List) {
              parameters[key] = value.map((e) => e.toString()).join(',');
            } else {
              parameters[key] = value.toString();
            }
          });
        }
      } else {
        if (city != null && city != "") parameters['city'] = city;
        if (areaId != null && areaId != "") parameters['area_id'] = areaId;
        if (country != null && country != "") parameters['country'] = country;
        if (state != null && state != "") parameters['state'] = state;
      }

      Map<String, dynamic> response =
          await Api.get(url: Api.getItemApi, queryParameters: parameters);
      List<ItemModel> items = (response['data']['data'] as List)
          .map((e) => ItemModel.fromJson(e))
          .toList();

      return DataOutput(
          total: response['data']['total'] ?? 0, modelList: items);
    } catch (error) {
      rethrow;
    }
  }
}
