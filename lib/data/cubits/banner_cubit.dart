import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/banner_model.dart';
import '../repositories/banner_repository.dart';

abstract class BannerState {}

class BannerInitial extends BannerState {}

class BannerLoading extends BannerState {}

class BannerSuccess extends BannerState {
  final List<BannerModel> banners;
  BannerSuccess(this.banners);
}

class BannerFailure extends BannerState {
  final dynamic error;
  BannerFailure(this.error);
}

class BannerCubit extends Cubit<BannerState> {
  BannerCubit() : super(BannerInitial());
  final BannerRepository _repository = BannerRepository();

  Future<void> fetchBanners({int? categoryId}) async {
    emit(BannerLoading());
    try {
      final data = await _repository.fetchBanners(categoryId: categoryId);
      emit(BannerSuccess(data));
    } catch (e) {
      emit(BannerFailure(e));
    }
  }
}
