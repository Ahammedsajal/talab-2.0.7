import 'dart:async';
import 'dart:math';

import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/item/fetch_item_from_category_cubit.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/model/item_filter_model.dart';
import 'package:Talab/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:Talab/ui/screens/home/widgets/item_horizontal_card.dart';
import 'package:Talab/ui/screens/main_activity.dart';
import 'package:Talab/ui/screens/native_ads_screen.dart';
import 'package:Talab/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:Talab/ui/screens/widgets/errors/no_data_found.dart';
import 'package:Talab/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/api.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/constant.dart';
import 'package:Talab/utils/custom_silver_grid_delegate.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/hive_utils.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:Talab/data/model/custom_field/custom_field_model.dart';
import 'package:Talab/utils/category_filter_map.dart';
import 'package:Talab/data/cubits/custom_field/fetch_custom_fields_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ItemsList extends StatefulWidget {
  final String categoryId, categoryName;
  final List<String> categoryIds;

  const ItemsList(
      {super.key,
      required this.categoryId,
      required this.categoryName,
      required this.categoryIds});

  @override
  ItemsListState createState() => ItemsListState();

  static Route route(RouteSettings routeSettings) {
    Map? arguments = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => ItemsList(
        categoryId: arguments?['catID'] as String,
        categoryName: arguments?['catName'],
        categoryIds: arguments?['categoryIds'],
      ),
    );
  }
}

class ItemsListState extends State<ItemsList> {
  late ScrollController controller;
  static TextEditingController searchController = TextEditingController();
  bool isFocused = false;
  bool isList = false;
  String previousSearchQuery = "";
  Timer? _searchDelay;
  String? sortBy;
  ItemFilterModel? filter;
  static const double searchBarHeight = 56.0;
  static const double filterBarHeight = 40.0;
  static const double adTypeBarHeight = 40.0;
  List<CustomFieldModel> _customFields = [];
  final Map<int, dynamic> _selectedFilters = {};
  List<dynamic> _adTypes = [];
  int? _adTypeId;
  String? _selectedAdType;

  bool _isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= 600;

  void _applyFilters() {
    ItemFilterModel base = filter ?? ItemFilterModel.createEmpty();
    final Map<String, dynamic> current =
        Map<String, dynamic>.from(base.customFields ?? {});

    // remove previous selections related to this screen
    for (final field in _customFields) {
      current.remove('custom_fields[${field.id}]');
    }
    if (_adTypeId != null) {
      current.remove('custom_fields[$_adTypeId]');
    }

    _selectedFilters.forEach((key, value) {
      current['custom_fields[$key]'] = [value];
    });
    if (_adTypeId != null && _selectedAdType != null) {
      current['custom_fields[$_adTypeId]'] = [_selectedAdType];
    }

    filter = base.copyWith(
      customFields: current,
      categoryId: widget.categoryId,
    );
    context.read<FetchItemFromCategoryCubit>().fetchItemFromCategory(
      categoryId: int.parse(widget.categoryId),
      search: searchController.text,
      filter: filter,
    );
  }

  Widget _buildFilterBar() {
    if (_customFields.isEmpty) {
      return const SizedBox.shrink();
    }

    final filterNames = categoryFilterMap[widget.categoryName]
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
        child: Row(
            children: widgets
                .map((w) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: w,
                    ))
                .toList()),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    searchBody = {};
    Constant.itemFilter = null;
    searchController = TextEditingController();
    searchController.addListener(searchItemListener);
    controller = ScrollController()..addListener(_loadMore);

    context
        .read<FetchCustomFieldsCubit>()
        .fetchCustomFields(categoryIds: widget.categoryIds.join(','));

    context.read<FetchItemFromCategoryCubit>().fetchItemFromCategory(
        categoryId: int.parse(
          widget.categoryId,
        ),
        search: "",
        filter: ItemFilterModel(
            country: HiveUtils.getCountryName() ?? "",
            areaId: HiveUtils.getAreaId() != null
                ? int.parse(HiveUtils.getAreaId().toString())
                : null,
            city: HiveUtils.getCityName() ?? "",
            state: HiveUtils.getStateName() ?? "",
            categoryId: widget.categoryId,
            radius: HiveUtils.getNearbyRadius() ?? null,
            latitude: HiveUtils.getLatitude() ?? null,
            longitude: HiveUtils.getLongitude() ?? null));

    Future.delayed(Duration.zero, () {
      selectedCategoryId = widget.categoryId;
      selectedCategoryName = widget.categoryName;
      searchBody[Api.categoryId] = widget.categoryId;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.removeListener(_loadMore);
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  //this will listen and manage search
  void searchItemListener() {
    _searchDelay?.cancel();
    searchCallAfterDelay();
  }

//This will create delay so we don't face rapid api call
  void searchCallAfterDelay() {
    _searchDelay = Timer(const Duration(milliseconds: 500), itemSearch);
  }

  ///This will call api after some delay
  void itemSearch() {
    // if (searchController.text.isNotEmpty) {
    if (previousSearchQuery != searchController.text) {
      context.read<FetchItemFromCategoryCubit>().fetchItemFromCategory(
          categoryId: int.parse(
            widget.categoryId,
          ),
          search: searchController.text);
      previousSearchQuery = searchController.text;
      sortBy = null;
      setState(() {});
    }
  }

  void _loadMore() async {
    if (controller.isEndReached()) {
      if (context.read<FetchItemFromCategoryCubit>().hasMoreData()) {
        context.read<FetchItemFromCategoryCubit>().fetchItemFromCategoryMore(
            catId: int.parse(
              widget.categoryId,
            ),
            search: searchController.text,
            sortBy: sortBy,
            filter: ItemFilterModel(
              country: HiveUtils.getCountryName() ?? "",
              areaId: HiveUtils.getAreaId() != null
                  ? int.parse(HiveUtils.getAreaId().toString())
                  : null,
              city: HiveUtils.getCityName() ?? "",
              state: HiveUtils.getStateName() ?? "",
              categoryId: widget.categoryId,
            ));
      }
    }
  }

  Widget searchBarWidget() {
    return Container(
      height: 56,
      color: context.color.secondaryColor,
      child: LayoutBuilder(builder: (context, c) {
        return SizedBox(
            width: c.maxWidth,
            child: FittedBox(
              fit: BoxFit.none,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 18.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 243,
                        height: 40,
                        alignment: AlignmentDirectional.center,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: context.color.borderColor.darken(30)),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: context.color.primaryColor),
                        child: TextFormField(
                            controller: searchController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8),
                              //OutlineInputBorder()
                              fillColor:
                                  Theme.of(context).colorScheme.primaryColor,
                              hintText: "searchHintLbl".translate(context),
                              prefixIcon: setSearchIcon(),
                              prefixIconConstraints: const BoxConstraints(
                                  minHeight: 5, minWidth: 5),
                            ),
                            enableSuggestions: true,
                            onEditingComplete: () {
                              setState(
                                () {
                                  isFocused = false;
                                  FocusScope.of(context).unfocus();
                                },
                              );
                              print("onediting");
                            },
                            onTap: () {
                              //change prefix icon color to primary
                              setState(() {
                                isFocused = true;
                              });
                            })),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isList = false;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: context.color.borderColor.darken(30)),
                          color: context.color.secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: UiUtils.getSvg(AppIcons.gridViewIcon,
                              color: !isList
                                  ? context.color.textDefaultColor
                                  : context.color.textDefaultColor
                                      .withValues(alpha: 0.2)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isList = true;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: context.color.borderColor.darken(30)),
                          color: context.color.secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: UiUtils.getSvg(AppIcons.listViewIcon,
                              color: isList
                                  ? context.color.textDefaultColor
                                  : context.color.textDefaultColor
                                      .withValues(alpha: 0.2)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
      }),
    );
  }

  Widget setSearchIcon() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: UiUtils.getSvg(AppIcons.search,
            color: context.color.textDefaultColor));
  }

  Widget setSuffixIcon() {
    return GestureDetector(
      onTap: () {
        searchController.clear();
        isFocused = false; //set icon color to black back
        FocusScope.of(context).unfocus(); //dismiss keyboard
        setState(() {});
      },
      child: Icon(
        Icons.close_rounded,
        color: Theme.of(context).colorScheme.blackColor,
        size: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return bodyWidget();
  }

  Widget bodyWidget() {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.secondaryColor,
      ),
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
        child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (isPop, result) {
          Constant.itemFilter = null;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primaryColor,
          appBar: UiUtils.buildAppBar(context,
              showBackButton: true,
              title: selectedCategoryName == ""
                  ? widget.categoryName
                  : selectedCategoryName),
          bottomNavigationBar: bottomWidget(),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  searchBody = {};
                  Constant.itemFilter = null;

                  context.read<FetchItemFromCategoryCubit>().fetchItemFromCategory(
                        categoryId: int.parse(widget.categoryId),
                        search: "",
                      );
                },
                color: context.color.territoryColor,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: searchBarHeight +
                        filterBarHeight +
                        (_adTypes.isNotEmpty ? adTypeBarHeight : 0),
                  ),
                  child: fetchItems(),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: searchBarWidget(),
              ),
              Positioned(
                top: searchBarHeight,
                left: 0,
                right: 0,
                child: _buildFilterBar(),
              ),
              if (_adTypes.isNotEmpty)
                Positioned(
                  top: searchBarHeight + filterBarHeight,
                  left: 0,
                  right: 0,
                  child: SizedBox(
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
                                  ? context.color.territoryColor.withOpacity(0.2)
                                  : context.color.secondaryColor,
                              border:
                                  Border.all(color: context.color.borderColor.darken(30)),
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
                ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Container bottomWidget() {
    return Container(
      color: context.color.secondaryColor,
      padding: EdgeInsets.only(top: 3, bottom: 3),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          filterByWidget(),
          VerticalDivider(
            color: context.color.borderColor.darken(50),
          ),
          // Add a vertical divider here
          sortByWidget(),
        ],
      ),
    );
  }

  Widget filterByWidget() {
    return InkWell(
      child: Row(
        children: [
          UiUtils.getSvg(AppIcons.filterByIcon,
              color: context.color.textDefaultColor),
          SizedBox(
            width: 7,
          ),
          CustomText("filterTitle".translate(context))
        ],
      ),
      onTap: () {
         debugPrint('DEBUG: categoryIds passed to FilterScreen = ${widget.categoryIds}');
        Navigator.pushNamed(context, Routes.filterScreen, arguments: {
          "update": getFilterValue,
          "from": "itemsList",
          "categoryIds": widget.categoryIds
        }).then((value) {
          if (value == true) {
            ItemFilterModel updatedFilter =
                filter!.copyWith(categoryId: widget.categoryId);
            context.read<FetchItemFromCategoryCubit>().fetchItemFromCategory(
                categoryId: int.parse(
                  widget.categoryId,
                ),
                search: searchController.text.toString(),
                filter: updatedFilter);
          }
          setState(() {});
        });
      },
    );
  }

  void getFilterValue(ItemFilterModel model) {
    filter = model;
    setState(() {});
  }

  Widget sortByWidget() {
    return InkWell(
      child: Row(
        children: [
          UiUtils.getSvg(AppIcons.sortByIcon,
              color: context.color.textDefaultColor),
          SizedBox(
            width: 7,
          ),
          CustomText("sortBy".translate(context))
        ],
      ),
      onTap: () {
        showSortByBottomSheet();
      },
    );
  }

  void showSortByBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          topRight: Radius.circular(8.0),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: context.color.borderColor,
                    ),
                    height: 6,
                    width: 60,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 17, horizontal: 20),
                child: CustomText(
                  'sortBy'.translate(context),
                  textAlign: TextAlign.start,
                  fontWeight: FontWeight.bold,
                  fontSize: context.font.large,
                ),
              ),

              Divider(height: 1), // Add some space between title and options
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                title: CustomText('default'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<FetchItemFromCategoryCubit>()
                      .fetchItemFromCategory(
                          categoryId: int.parse(
                            widget.categoryId,
                          ),
                          search: searchController.text.toString(),
                          sortBy: null);

                  setState(() {
                    sortBy = null;
                    print("isfocus$isFocused");

                    FocusManager.instance.primaryFocus?.unfocus();
                  });

                  // Handle option 1 selection
                },
              ),
              Divider(height: 1), // Divider between option 1 and option 2
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                title: CustomText('newToOld'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<FetchItemFromCategoryCubit>()
                      .fetchItemFromCategory(
                          categoryId: int.parse(
                            widget.categoryId,
                          ),
                          search: searchController.text.toString(),
                          sortBy: "new-to-old");
                  setState(() {
                    sortBy = "new-to-old";
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                },
              ),
              Divider(height: 1), // Divider between option 2 and option 3
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                title: CustomText('oldToNew'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<FetchItemFromCategoryCubit>()
                      .fetchItemFromCategory(
                          categoryId: int.parse(
                            widget.categoryId,
                          ),
                          search: searchController.text.toString(),
                          sortBy: "old-to-new");
                  setState(() {
                    sortBy = "old-to-new";
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                },
              ),
              Divider(height: 1), // Divider between option 3 and option 4
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                title: CustomText('priceHighToLow'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<FetchItemFromCategoryCubit>()
                      .fetchItemFromCategory(
                          categoryId: int.parse(
                            widget.categoryId,
                          ),
                          search: searchController.text.toString(),
                          sortBy: "price-high-to-low");
                  setState(() {
                    sortBy = "price-high-to-low";
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                },
              ),
              Divider(height: 1), // Divider between option 4 and option 5
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                title: CustomText('priceLowToHigh'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<FetchItemFromCategoryCubit>()
                      .fetchItemFromCategory(
                          categoryId: int.parse(
                            widget.categoryId,
                          ),
                          search: searchController.text.toString(),
                          sortBy: "price-low-to-high");
                  setState(() {
                    sortBy = "price-low-to-high";
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget fetchItems() {
    return BlocBuilder<FetchItemFromCategoryCubit, FetchItemFromCategoryState>(
        builder: (context, state) {
      if (state is FetchItemFromCategoryInProgress) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          itemCount: 10,
          itemBuilder: (context, index) {
            return buildItemsShimmer(context);
          },
        );
      }

      if (state is FetchItemFromCategoryFailure) {
        return Center(
          child: CustomText(state.errorMessage),
        );
      }
      if (state is FetchItemFromCategorySuccess) {
        if (state.itemModel.isEmpty) {
          return Center(
            child: NoDataFound(
              onTap: () {
                context
                    .read<FetchItemFromCategoryCubit>()
                    .fetchItemFromCategory(
                        categoryId: int.parse(
                          widget.categoryId,
                        ),
                        search: searchController.text.toString());
              },
            ),
          );
        }
        return Column(
          children: [
            Expanded(child: mainChildren(state.itemModel)
                /* isList
                  ? ListView.builder(
                      shrinkWrap: true,
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 3),
                      itemCount: calculateItemCount(state.itemModel.length),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        if ((index + 1) % 4 == 0) {
                          return NativeAdWidget(type: TemplateType.medium);
                        }

                        int itemIndex = index - (index ~/ 4);
                        ItemModel item = state.itemModel[itemIndex];
                        return GestureDetector(
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
                          ),
                        );
                      },
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      controller: controller,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                              crossAxisCount: 2,
                              height: MediaQuery.of(context).size.height /
                                  3.5,
                              mainAxisSpacing: 7,
                              crossAxisSpacing: 10),
                      itemCount: calculateItemCount(state.itemModel.length),
                      itemBuilder: (context, index) {
                        if ((index + 1) % 4 == 0) {
                          return NativeAdWidget(type: TemplateType.medium);
                        }

                        int itemIndex = index - (index ~/ 4);
                        ItemModel item = state.itemModel[itemIndex];

                        return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                Routes.adDetailsScreen,
                                arguments: {
                                  'model': item,
                                },
                              );
                            },
                            child: ItemCard(
                              item: item,
                            ));
                      },
                    ),*/
                ),
            if (state.isLoadingMore) UiUtils.progress()
          ],
        );
      }
      return Container();
    });
  }

  void _navigateToDetails(BuildContext context, ItemModel item) {
    Navigator.pushNamed(
      context,
      Routes.adDetailsScreen,
      arguments: {'model': item},
    );
  }

  Widget mainChildren(List<ItemModel> items) {
    List<Widget> children = [];
    int gridCount = Constant.nativeAdsAfterItemNumber;
    int total = items.length;

    for (int i = 0; i < total; i += gridCount /* + listCount*/) {
      if (isList) {
        children.add(_buildListViewSection(
            context, i, min(gridCount, total - i), items));
      } else {
        children.add(_buildGridViewSection(
            context, i, min(gridCount, total - i), items));
      }

      int remainingItems = total - i - gridCount;
      if (remainingItems > 0) {
        children.add(NativeAdWidget(type: TemplateType.medium));
      }
    }

    return SingleChildScrollView(
      controller: controller,
      physics: BouncingScrollPhysics(),
      child: Column(children: children),
    );
  }

  Widget _buildListViewSection(BuildContext context, int startIndex,
      int itemCount, List<ItemModel> items) {
    if (_isTablet(context)) {
      const double cardHeight = 137;
      const double spacing = 10;
      const double horizontalPadding = 15;
      final screenWidth = MediaQuery.of(context).size.width;
      const int crossAxisCount = 3;
      final cardWidth = (screenWidth - horizontalPadding * 2 -
              (crossAxisCount - 1) * spacing) /
          crossAxisCount;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding:
            const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
          crossAxisCount: crossAxisCount,
          height: cardHeight,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          ItemModel item = items[startIndex + index];
          return GestureDetector(
            onTap: () => _navigateToDetails(context, item),
            child: ItemHorizontalCard(
              item: item,
              cardWidth: cardWidth,
              cardHeight: cardHeight,
            ),
          );
        },
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        ItemModel item = items[startIndex + index];
        return GestureDetector(
          onTap: () => _navigateToDetails(context, item),
          child: ItemHorizontalCard(item: item),
        );
      },
    );
  }

  Widget _buildGridViewSection(BuildContext context, int startIndex,
      int itemCount, List<ItemModel> items) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPadding = 15;
    const double spacing = 8;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;
    final isDesktop = screenWidth >= 1200;
    final crossAxisCount = isDesktop
        ? 4
        : isTablet
            ? 3
            : 2;
    final itemWidth = (screenWidth - horizontalPadding * 2 -
            (crossAxisCount - 1) * spacing) /
        crossAxisCount;

    final itemHeight = isTablet ? itemWidth * 1.4 : itemWidth * 1.4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding:
          const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        crossAxisCount: crossAxisCount,
        height: itemHeight,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        ItemModel item = items[startIndex + index];
        return GestureDetector(
          onTap: () => _navigateToDetails(context, item),
          child: ItemCard(
            item: item,
            width: itemWidth,
            height: itemHeight,
            bigCard: isTablet,
          ),
        );
      },
    );
  }

  Widget buildItemsShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
            border: Border.all(width: 1.5, color: context.color.borderColor),
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            CustomShimmer(
              height: 120,
              width: 100,
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomShimmer(
                  width: 100,
                  height: 10,
                  borderRadius: 7,
                ),
                CustomShimmer(
                  width: 150,
                  height: 10,
                  borderRadius: 7,
                ),
                CustomShimmer(
                  width: 120,
                  height: 10,
                  borderRadius: 7,
                ),
                CustomShimmer(
                  width: 80,
                  height: 10,
                  borderRadius: 7,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
