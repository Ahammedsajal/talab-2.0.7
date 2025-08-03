import 'package:Talab/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Talab/utils/api.dart';
import 'package:Talab/utils/hive_utils.dart';
import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/home/fetch_section_items_cubit.dart';
import 'package:Talab/data/helper/designs.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/model/custom_field/custom_field_model.dart';
import 'package:Talab/data/model/item_filter_model.dart';
import 'package:Talab/ui/screens/home/widgets/item_horizontal_card.dart';
import 'package:Talab/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:Talab/ui/screens/widgets/errors/no_data_found.dart';
import 'package:Talab/ui/screens/widgets/errors/no_internet.dart';
import 'package:Talab/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:Talab/ui/screens/widgets/dynamic_filter_bar.dart';

class SectionItemsScreen extends StatefulWidget {
  final String title;
  final int sectionId;

  const SectionItemsScreen({
    super.key,
    required this.title,
    required this.sectionId,
  });

  static Route route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return BlurredRouter(
      builder: (_) => SectionItemsScreen(
          title: arguments['title'], sectionId: arguments['sectionId']),
    );
  }

  @override
  _SectionItemsScreenState createState() => _SectionItemsScreenState();
}

class _SectionItemsScreenState extends State<SectionItemsScreen> {
  //late final ScrollController _controller = ScrollController();

  late ScrollController _controller = ScrollController()
    ..addListener(
      () {
        if (_controller.offset >= _controller.position.maxScrollExtent) {
          if (context.read<FetchSectionItemsCubit>().hasMoreData()) {
            context.read<FetchSectionItemsCubit>().fetchSectionItemMore(
                sectionId: widget.sectionId,
                city: HiveUtils.getCityName(),
                areaId: HiveUtils.getAreaId(),
                country: HiveUtils.getCountryName(),
                stateName: HiveUtils.getStateName(),
                filter: _filter);
          }
        }
      },
    );

  List<CustomFieldModel> _customFields = [];
  final Map<int, dynamic> _selectedFilters = {};
  List<dynamic> _adTypes = [];
  int? _adTypeId;
  String? _selectedAdType;
  ItemFilterModel? _filter;

  @override
  void initState() {
    super.initState();
    //_controller.addListener(hasMoreItemsScrollListener);
    getAllItems();
  }

  void getAllItems() async {
    context.read<FetchSectionItemsCubit>().fetchSectionItem(
        sectionId: widget.sectionId,
        city: HiveUtils.getCityName(),
        areaId: HiveUtils.getAreaId(),
        country: HiveUtils.getCountryName(),
        state: HiveUtils.getStateName(),
        filter: _filter);
  }

  void _extractFilters(List<ItemModel> items) {
    final Map<int, Set<dynamic>> values = {};
    final Map<int, CustomFieldModel> info = {};

    for (final item in items) {
      if (item.customFields == null) continue;
      for (final field in item.customFields!) {
        if (field.id == null) continue;
        info[field.id!] = field;
        final val = field.value;
        if (val != null && val.toString().isNotEmpty) {
          values.putIfAbsent(field.id!, () => {}).add(val);
        }
        if (field.values is List) {
          values.putIfAbsent(field.id!, () => {}).addAll(List.from(field.values));
        }
      }
    }

    _adTypeId = null;
    _adTypes.clear();
    _customFields.clear();

    info.forEach((id, field) {
      final vals = values[id]?.toList() ?? [];
      if (field.name?.toLowerCase() == 'ad_type') {
        _adTypeId = id;
        _adTypes = vals;
      } else if (vals.isNotEmpty) {
        _customFields.add(field..values = vals);
      }
    });
  }

  void _applyFilters() {
    ItemFilterModel base = _filter ?? ItemFilterModel.createEmpty();
    final Map<String, dynamic> current =
        Map<String, dynamic>.from(base.customFields ?? {});

    for (final field in _customFields) {
      current.remove('custom_fields[${field.id}]');
      current.remove('custom_fields[${field.id}][min]');
      current.remove('custom_fields[${field.id}][max]');
    }
    if (_adTypeId != null) {
      current.remove('custom_fields[$_adTypeId]');
    }

    _selectedFilters.forEach((key, value) {
      if (value is Map) {
        final min = value['min'];
        final max = value['max'];
        if (min != null && min.toString().isNotEmpty) {
          current['custom_fields[$key][min]'] = [min];
        }
        if (max != null && max.toString().isNotEmpty) {
          current['custom_fields[$key][max]'] = [max];
        }
      } else if (value is List) {
        current['custom_fields[$key]'] = value;
      } else {
        current['custom_fields[$key]'] = [value];
      }
    });

    if (_adTypeId != null && _selectedAdType != null) {
      current['custom_fields[$_adTypeId]'] = [_selectedAdType];
    }

    _filter = base.copyWith(customFields: current);
    getAllItems();
  }

  Widget _buildFilterBar() {
    if (_customFields.isEmpty) return const SizedBox.shrink();

    return DynamicFilterBar(
      fields: _customFields,
      selectedValues: _selectedFilters,
      onChanged: (id, value) {
        setState(() {
          _selectedFilters[id] = value;
        });
        _applyFilters();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.secondaryColor,
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          getAllItems();
        },
        color: context.color.territoryColor,
        child: Scaffold(
          appBar: UiUtils.buildAppBar(context,
              showBackButton: true, title: widget.title),
          body: BlocBuilder<FetchSectionItemsCubit, FetchSectionItemsState>(
            builder: (context, state) {
              if (state is FetchSectionItemsInProgress) {
                return shimmerEffect();
              } else if (state is FetchSectionItemsSuccess) {
                if (_customFields.isEmpty && state.items.isNotEmpty) {
                  _extractFilters(state.items);
                }
                if (state.items.isEmpty) {
                  return Center(
                    child: NoDataFound(
                      onTap: getAllItems,
                    ),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFilterBar(),
                    if (_adTypes.isNotEmpty)
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final type = _adTypes[index];
                            final selected = type == _selectedAdType;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAdType = type;
                                });
                                if (_adTypeId != null) {
                                  _selectedFilters[_adTypeId!] = type;
                                }
                                _applyFilters();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? context.color.territoryColor
                                          .withOpacity(0.2)
                                      : context.color.secondaryColor,
                                  border: Border.all(
                                      color: context.color.borderColor.darken(30)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: CustomText(
                                    type.toString(),
                                    color: context.color.textDefaultColor,
                                    fontSize: context.font.small,
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemCount: _adTypes.length,
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        controller: _controller,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.items.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          ItemModel item = state.items[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.adDetailsScreen,
                                arguments: {
                                  'model': item,
                                },
                              );
                            },
                            child: ItemHorizontalCard(
                              item: item,
                              showLikeButton: true,
                              additionalImageWidth: 8,
                            ),
                          );
                        },
                      ),
                    ),
                    if (state.isLoadingMore)
                      UiUtils.progress(
                        normalProgressColor: context.color.territoryColor,
                      )
                  ],
                );
              } else if (state is FetchSectionItemsFail) {
                if (state.error is ApiException &&
                    (state.error as ApiException).errorMessage ==
                        "no-internet") {
                  return NoInternet(
                    onRetry: getAllItems,
                  );
                }
                return const SomethingWentWrong();
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  ListView shimmerEffect() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        vertical: 10 + defaultPadding,
        horizontal: defaultPadding,
      ),
      itemCount: 5,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const ClipRRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: CustomShimmer(height: 90, width: 90),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: LayoutBuilder(builder: (context, c) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      CustomShimmer(
                        height: 10,
                        width: c.maxWidth - 50,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const CustomShimmer(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomShimmer(
                        height: 10,
                        width: c.maxWidth / 1.2,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomStart,
                        child: CustomShimmer(
                          width: c.maxWidth / 4,
                        ),
                      ),
                    ],
                  );
                }),
              )
            ],
          ),
        );
      },
    );
  }
}
