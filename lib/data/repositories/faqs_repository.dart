import 'package:Talab/data/model/data_output.dart';
import 'package:Talab/data/model/faqs_model.dart';
import 'package:Talab/utils/api.dart';

class FaqsRepository {
  Future<DataOutput<FaqsModel>> fetchFaqs({required int page}) async {
    Map<String, dynamic> parameters = {
      Api.page: page,
    };

    Map<String, dynamic> result =
        await Api.get(url: Api.getFaqApi, queryParameters: parameters);

    List<FaqsModel> modelList = (result['data'] as List)
        .map((element) => FaqsModel.fromJson(element))
        .toList();

    return DataOutput<FaqsModel>(total: modelList.length, modelList: modelList);
  }
}
