import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/category/fetch_sub_categories_cubit.dart';
import 'package:Talab/data/model/category_model.dart';
import 'package:Talab/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:Talab/ui/screens/widgets/errors/no_data_found.dart';
import 'package:Talab/ui/screens/widgets/errors/no_internet.dart';
import 'package:Talab/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/api.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/custom_silver_grid_delegate.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:Talab/data/cubits/banner_cubit.dart';
import 'package:Talab/ui/screens/sub_category/subcategory_banner_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Talab/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:Talab/data/cubits/item/fetch_item_from_category_cubit.dart';
import 'package:Talab/data/model/custom_field/custom_field_model.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/model/item_filter_model.dart';
import 'package:Talab/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:Talab/utils/category_filter_map.dart';

class SubCategoryScreen extends StatefulWidget {
  final List<CategoryModel> categoryList;
  final String catName;
  final int catId;
  final List<String> categoryIds;

  const SubCategoryScreen(
      {super.key,
      required this.categoryList,
      required this.catName,
      required this.catId,
      required this.categoryIds});

  @override
  State<SubCategoryScreen> createState() => _CategoryListState();

  static Route route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => SubCategoryScreen(
        categoryList: args?['categoryList'],
        catName: args?['catName'],
        catId: args?['catId'],
        categoryIds: args?['categoryIds'],
      ),
    );
  }
}

enum _ViewMode { grid, list }

class _CategoryListState extends State<SubCategoryScreen>
    with TickerProviderStateMixin {
  late final ScrollController controller = ScrollController();
  _ViewMode _mode = _ViewMode.grid;

  List<CustomFieldModel> _customFields = [];
  List<dynamic> _adTypes = [];
  int? _adTypeId;
  String? _selectedAdType;
  int _totalAds = 0;
  final Map<int, dynamic> _selectedFilters = {};
  ItemFilterModel? _filter;

  @override
  void initState() {
    getSubCategories();
    if (widget.categoryList.isEmpty) {
      controller.addListener(pageScrollListen);
    }
    context
        .read<FetchCustomFieldsCubit>()
        .fetchCustomFields(categoryIds: widget.categoryIds.join(','));
    _filter = ItemFilterModel(categoryId: widget.catId.toString());
    context.read<FetchItemFromCategoryCubit>().fetchItemFromCategory(
        categoryId: widget.catId,
        search: '',
        filter: _filter);
    super.initState();
  }

  void getSubCategories() {
    if (widget.categoryList.isEmpty) {
      context
          .read<FetchSubCategoriesCubit>()
          .fetchSubCategories(categoryId: widget.catId);
    }
  }

  void pageScrollListen() {
    if (controller.isEndReached()) {
      if (context.read<FetchSubCategoriesCubit>().hasMoreData()) {
        context
            .read<FetchSubCategoriesCubit>()
            .fetchSubCategories(categoryId: widget.catId);
      }
    }
  }

  void _applyFilters() {
    ItemFilterModel base = _filter ?? ItemFilterModel.createEmpty();
    Map<String, dynamic> fields = {};
    _selectedFilters.forEach((key, value) {
      fields['custom_fields[' + key.toString() + ']'] = [value];
    });
    if (_adTypeId != null && _selectedAdType != null) {
      fields['custom_fields[' + _adTypeId.toString() + ']'] = [_selectedAdType];
    }
    _filter = base.copyWith(
      customFields: {...?base.customFields, ...fields},
      categoryId: widget.catId.toString(),
    );
    context.read<FetchItemFromCategoryCubit>().fetchItemFromCategory(
      categoryId: widget.catId,
      search: '',
      filter: _filter,
    );
  }

  Widget _buildFilterBar() {
    if (_customFields.isEmpty) {
      return const SizedBox.shrink();
    }

    final filterNames = categoryFilterMap[widget.catName]
        ?.map((e) => e.toLowerCase())
        .toList();
    final fields = _customFields.where((f) {
      final name = (f.name ?? '').toLowerCase();
      final isValid = f.id != null &&
          f.values != null &&
          name != 'ad_type' &&
          (f.values is List && (f.values as List).isNotEmpty);
      if (!isValid) return false;
      if (filterNames != null) {
        return filterNames.contains(name);
      }
      return true;
    }).toList();

    if (fields.isEmpty) return const SizedBox.shrink();

    List<Widget> widgets = fields
        .map(
          (field) => DropdownButton<dynamic>(
            value: _selectedFilters[field.id!],
            hint: CustomText(field.name!, fontSize: context.font.small),
            underline: const SizedBox.shrink(),
            onChanged: (v) {
              setState(() {
                _selectedFilters[field.id!] = v;
              });
              _applyFilters();
            },
            items: (field.values as List)
                .map<DropdownMenuItem<dynamic>>(
                    (e) => DropdownMenuItem(value: e, child: CustomText('$e')))
                .toList(),
          ),
        )
        .toList();

    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(children: widgets.map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)).toList()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
          context: context, statusBarColor: context.color.secondaryColor),
      child: Scaffold(
          backgroundColor: context.color.backgroundColor,
          appBar: UiUtils.buildAppBar(
            context,
            showBackButton: true,
            title: widget.catName,
          ),
          body: BlocListener<FetchItemFromCategoryCubit, FetchItemFromCategoryState>(
            listener: (context, state) {
              if (state is FetchItemFromCategorySuccess && _selectedAdType == null) {
                _totalAds = state.total;
              }
            },
            child: BlocListener<FetchCustomFieldsCubit, FetchCustomFieldState>(
              listener: (context, state) {
                if (state is FetchCustomFieldSuccess) {
                  setState(() {
                    _customFields = state.fields;
                    final field = state.fields.firstWhere(
                        (f) => f.name?.toLowerCase() == 'ad_type',
                        orElse: () => CustomFieldModel());
                    _adTypeId = field.id;
                    _adTypes =
                        field.values is List ? List.from(field.values) : [];
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: SingleChildScrollView(
                  child: Container(
                    color: context.color.secondaryColor,
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, Routes.itemsList,
                                    arguments: {
                                      'catID': widget.catId.toString(),
                                      'catName': widget.catName,
                                      "categoryIds": [...widget.categoryIds]
                                    });
                              },
                              child: CustomText(
                                "${"lblall".translate(context)}\t${widget.catName}",
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                color: context.color.textDefaultColor,
                                fontWeight: FontWeight.w600,
                                fontSize: context.font.normal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _mode = _ViewMode.grid),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1,
                                    color: context.color.borderColor.darken(30)),
                                color: context.color.secondaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: UiUtils.getSvg(AppIcons.gridViewIcon,
                                    color: _mode == _ViewMode.grid
                                        ? context.color.textDefaultColor
                                        : context.color.textDefaultColor
                                            .withValues(alpha: 0.2)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _mode = _ViewMode.list),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 1,
                                    color: context.color.borderColor.darken(30)),
                                color: context.color.secondaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: UiUtils.getSvg(AppIcons.listViewIcon,
                                    color: _mode == _ViewMode.list
                                        ? context.color.textDefaultColor
                                        : context.color.textDefaultColor
                                            .withValues(alpha: 0.2)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 1.2,
                      height: 10,
                    ),
                    SubCategoryBannerSlider(categoryId: widget.catId),
                    const Divider(
                      thickness: 1.2,
                      height: 10,
                    ),
                    _buildFilterBar(),
                    const SizedBox(height: 8),
                    _adTypes.isNotEmpty
                        ? SizedBox(
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: selected
                                            ? context.color.territoryColor.withOpacity(0.2)
                                            : context.color.secondaryColor,
                                        border: Border.all(color: context.color.borderColor.darken(30)),
                                        borderRadius: BorderRadius.circular(20)),
                                    child: Center(
                                        child: CustomText(
                                      type.toString(),
                                      color: context.color.textDefaultColor,
                                      fontSize: context.font.small,
                                    )),
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemCount: _adTypes.length,
                            ),
                          )
                        : const SizedBox.shrink(),
                    if (_selectedFilters.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      buildFilteredItems(),
                      const Divider(
                        thickness: 1.2,
                        height: 10,
                      ),
                    ],
                    widget.categoryList.isNotEmpty
                        ? _mode == _ViewMode.list
                            ? _buildList(widget.categoryList)
                            : _buildGrid(widget.categoryList)
                        : fetchSubCategoriesData()
                  ],
                ),
              ),
            ),
                    )),
    )));
  }

  Widget fetchSubCategoriesData() {
    return BlocBuilder<FetchSubCategoriesCubit, FetchSubCategoriesState>(
      builder: (context, state) {
        if (state is FetchSubCategoriesInProgress) {
          return shimmerEffect();
        }

        if (state is FetchSubCategoriesFailure) {
          if (state.errorMessage is ApiException) {
            if (state.errorMessage == "no-internet") {
              return NoInternet(
                onRetry: () {
                  context
                      .read<FetchSubCategoriesCubit>()
                      .fetchSubCategories(categoryId: widget.catId);
                },
              );
            }
          }

          return const SomethingWentWrong();
        }

        if (state is FetchSubCategoriesSuccess) {
          if (state.categories.isEmpty) {
            return NoDataFound(
              onTap: () {
                context
                    .read<FetchSubCategoriesCubit>()
                    .fetchSubCategories(categoryId: widget.catId);
              },
            );
          }
          return _mode == _ViewMode.list
              ? _buildList(state.categories)
              : _buildGrid(state.categories);
        }

        return Container();
      },
    );
  }

  Widget buildFilteredItems() {
    return BlocBuilder<FetchItemFromCategoryCubit, FetchItemFromCategoryState>(
      builder: (context, state) {
        if (state is FetchItemFromCategoryInProgress) {
          return Center(child: UiUtils.progress());
        }
        if (state is FetchItemFromCategorySuccess) {
          List<ItemModel> items = state.itemModel;
          if (items.isEmpty) {
            return const NoDataFound();
          }
          final crossAxisCount = MediaQuery.of(context).size.width >= 600 ? 3 : 2;
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                crossAxisCount: crossAxisCount,
                height: MediaQuery.of(context).size.height / 3.5,
                mainAxisSpacing: 7,
                crossAxisSpacing: 10),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ItemCard(item: items[index]);
            },
          );
        }
        if (state is FetchItemFromCategoryFailure) {
          return const SomethingWentWrong();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildList(List<CategoryModel> categories) {
    return ListView.separated(
      itemCount: categories.length,
      padding: EdgeInsets.zero,
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => const Divider(thickness: 1.2, height: 10),
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          onTap: () {
            if ((category.children?.isEmpty ?? true) && category.subcategoriesCount == 0) {
              Navigator.pushNamed(context, Routes.itemsList, arguments: {
                'catID': category.id.toString(),
                'catName': category.name,
                'categoryIds': [...widget.categoryIds, category.id.toString()]
              });
            } else {
              Navigator.pushNamed(context, Routes.subCategoryScreen, arguments: {
                'categoryList': category.children,
                'catName': category.name,
                'catId': category.id,
                'categoryIds': [...widget.categoryIds, category.id.toString()]
              });
            }
          },
          leading: FittedBox(
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: context.color.territoryColor.withValues(alpha: 0.1),
              ),
              child: UiUtils.imageType(
                category.url ?? '',
                color: context.color.territoryColor,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: CustomText(
            category.name ?? '',
            textAlign: TextAlign.start,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            color: context.color.textDefaultColor,
            fontSize: context.font.normal,
          ),
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.color.borderColor.darken(10),
            ),
            child: Icon(
              Icons.chevron_right_outlined,
              color: context.color.textDefaultColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(List<CategoryModel> categories) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 1200 ? 5 : screenWidth >= 600 ? 4 : 3;
    List<Widget> tiles = [
      GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, Routes.itemsList, arguments: {
            'catID': widget.catId.toString(),
            'catName': widget.catName,
            'categoryIds': [...widget.categoryIds]
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: context.color.territoryColor.withOpacity(0.1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.grid_view, color: context.color.territoryColor),
              const SizedBox(height: 4),
              CustomText('exploreAllAds'.translate(context),
                  fontSize: context.font.small,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center),
              const SizedBox(height: 2),
              CustomText('$_totalAds ${'ads'.translate(context)}',
                  fontSize: context.font.smaller,
                  color: context.color.textDefaultColor.withOpacity(0.6)),
            ],
          ),
        ),
      )
    ];
    tiles.addAll(categories.map((cat) {
      return GestureDetector(
        onTap: () {
          if ((cat.children?.isEmpty ?? true) && cat.subcategoriesCount == 0) {
            Navigator.pushNamed(context, Routes.itemsList, arguments: {
              'catID': cat.id.toString(),
              'catName': cat.name,
              'categoryIds': [...widget.categoryIds, cat.id.toString()]
            });
          } else {
            Navigator.pushNamed(context, Routes.subCategoryScreen, arguments: {
              'categoryList': cat.children,
              'catName': cat.name,
              'catId': cat.id,
              'categoryIds': [...widget.categoryIds, cat.id.toString()]
            });
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: context.color.territoryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: UiUtils.imageType(cat.url ?? '',
                    color: context.color.territoryColor,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 6),
            CustomText(
              cat.name ?? '',
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              fontSize: context.font.small,
            )
          ],
        ),
      );
    }));

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: tiles,
    );
  }

  Widget shimmerEffect() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 15,
      separatorBuilder: (context, index) {
        return const Divider(
          thickness: 1.2,
          height: 10,
        );
      },
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.shimmerBaseColor,
          highlightColor: Theme.of(context).colorScheme.shimmerHighlightColor,
          child: Container(
            padding: EdgeInsets.all(5),
            width: double.maxFinite,
            height: 56,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          ),
        );
      },
    );
  }
}
