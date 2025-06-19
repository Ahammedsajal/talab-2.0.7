import 'package:Talab/data/model/banner_model.dart';
import 'package:Talab/utils/api.dart';

class BannerRepository {
  Future<List<BannerModel>> fetchBanners({int? categoryId}) async {
    try {
      final resp = await Api.get(
        url: Api.getBannersApi,
        queryParameters:
            categoryId == null ? null : {'category_id': categoryId},
      );
      final list = (resp['data'] as List?)
              ?.map((e) => BannerModel.fromJson(e))
              .toList() ??
          [];
      list.sort((a, b) => (a.sequence ?? 0).compareTo(b.sequence ?? 0));
      return list;
    } catch (e) {
      rethrow;
    }
  }
}
