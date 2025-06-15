import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/item/item_repository.dart';

abstract class ItemViewCountState {}
class ItemViewCountInitial extends ItemViewCountState {}
class ItemViewCountLoading extends ItemViewCountState {}
class ItemViewCountLoaded extends ItemViewCountState {
  final Map<int, int> counts;
  ItemViewCountLoaded(this.counts);
}
class ItemViewCountFailure extends ItemViewCountState {
  final String error;
  ItemViewCountFailure(this.error);
}

class ItemViewCountCubit extends Cubit<ItemViewCountState> {
  final ItemRepository _repo = ItemRepository();
  Map<int, int> counts = {};
  ItemViewCountCubit() : super(ItemViewCountInitial());

  Future<void> fetchViewCounts() async {
    try {
      emit(ItemViewCountLoading());
      counts = await _repo.fetchItemViewCounts();
      emit(ItemViewCountLoaded(counts));
    } catch (e) {
      emit(ItemViewCountFailure(e.toString()));
    }
  }

  Future<void> increment(int itemId, {int views = 1}) async {
    try {
      await _repo.incrementItemView(itemId, views: views);
      await fetchViewCounts();
    } catch (e) {
      emit(ItemViewCountFailure(e.toString()));
    }
  }
}
