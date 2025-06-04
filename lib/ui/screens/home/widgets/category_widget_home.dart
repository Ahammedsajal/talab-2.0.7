// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/category/fetch_category_cubit.dart';
import 'package:Talab/data/model/category_model.dart';
import 'package:Talab/ui/screens/home/home_screen.dart';
import 'package:Talab/ui/screens/home/widgets/category_home_card.dart';
import 'package:Talab/ui/screens/main_activity.dart';
import 'package:Talab/ui/screens/widgets/errors/no_data_found.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:flutter_svg/svg.dart';

/* ──────────────────────────────────────────────────────────────────────────
 * Switchable Category Widget for Home Screen
 *   - ViewMode.horizontal  … original ribbon (max 10 + “more”)
 *   - ViewMode.expanded    … accordion list with masonry sub-grid
 *   - ViewMode.staggered   … flat staggered grid of top-level categories
 * Toggle between them with three icon buttons.
 * ──────────────────────────────────────────────────────────────────────────*/

enum _ViewMode { horizontal, expanded, staggered }

class CategoryWidgetHome extends StatefulWidget {
  const CategoryWidgetHome({super.key});

  @override
  State<CategoryWidgetHome> createState() => _CategoryWidgetHomeState();
}

class _CategoryWidgetHomeState extends State<CategoryWidgetHome> {
  _ViewMode _mode = _ViewMode.staggered;
  final Map<int, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final noDataPadding = isDesktop
        ? 80.0
        : isTablet
            ? 65.0
            : 50.0;

    return Column(
      children: [
        _buildToggleBar(context),
        BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
          builder: (context, state) {
            if (state is! FetchCategorySuccess) return const SizedBox.shrink();
            if (state.categories.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(noDataPadding),
                child: const NoDataFound(),
              );
            }

            return _mode == _ViewMode.horizontal
                ? _HorizontalRibbon(
                    categories: state.categories,
                    onMoreTapped: () => Navigator.pushNamed(
                      context,
                      Routes.categories,
                      arguments: {"from": Routes.home},
                    ),
                  )
                : _mode == _ViewMode.expanded
                    ? _AccordionGrid(
                        categories: state.categories,
                        expanded: _expanded,
                        onToggle: (id) => setState(() {
                          _expanded[id] = !(_expanded[id] ?? false);
                        }),
                      )
                    : _StaggeredGridView(
                        categories: state.categories,
                      );
          },
        ),
      ],
    );
  }

  Widget _buildToggleBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final paddingHorizontal = isDesktop
        ? sidePadding * 1.5
        : isTablet
            ? sidePadding * 1.2
            : sidePadding;
    final iconSize = isDesktop
        ? 28.0
        : isTablet
            ? 26.0
            : 24.0;

    return Padding(
      padding:
          EdgeInsets.only(left: paddingHorizontal, right: paddingHorizontal),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton( 
            tooltip: 'Ribbon view',
            icon: SvgPicture.string(
                '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect x="1" y="7" width="4" height="10" stroke="currentColor" stroke-width="1.5" fill="none" rx="1"/>
                    <rect x="7" y="7" width="4" height="10" stroke="currentColor" stroke-width="1.5" fill="none" rx="1"/>
                    <rect x="13" y="7" width="4" height="10" stroke="currentColor" stroke-width="1.5" fill="none" rx="1"/>
                    <rect x="19" y="7" width="4" height="10" stroke="currentColor" stroke-width="1.5" fill="none" rx="1"/>
                  </svg>''',
                width: iconSize,
                height: iconSize,
                color: _mode == _ViewMode.horizontal
                    ? context.color.territoryColor
                    : context.color.iconColor ?? Colors.grey),
            onPressed: () => setState(() => _mode = _ViewMode.horizontal),
          ),
          IconButton(
            tooltip: 'Grid view',
            icon: Icon(Icons.list,
                size: iconSize,
                color: _mode == _ViewMode.expanded
                    ? context.color.territoryColor
                    : context.color.iconColor),
            onPressed: () => setState(() => _mode = _ViewMode.expanded),
          ),
          IconButton(
            tooltip: 'Staggered grid view',
            icon: Icon(Icons.dashboard,
                size: iconSize,
                color: _mode == _ViewMode.staggered
                    ? context.color.territoryColor
                    : context.color.iconColor),
            onPressed: () => setState(() => _mode = _ViewMode.staggered),
          ),
        ],
      ),
    );
  }
}

class _HorizontalRibbon extends StatelessWidget {
  const _HorizontalRibbon({
    required this.categories,
    required this.onMoreTapped,
  });

  final List<CategoryModel> categories;
  final VoidCallback onMoreTapped;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final height = isDesktop
        ? 124.0
        : isTablet
            ? 113.0
            : 103.0;
    final topPadding = isDesktop
        ? 16.0
        : isTablet
            ? 14.0
            : 12.0;
    final separatorWidth = isDesktop
        ? 16.0
        : isTablet
            ? 14.0
            : 12.0;
    final paddingHorizontal = isDesktop
        ? sidePadding * 1.5
        : isTablet
            ? sidePadding * 1.2
            : sidePadding;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: SizedBox(
        width: context.screenWidth,
        height: height,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            if (categories.length > 10 && index == categories.length) {
              return _MoreCard(onTap: onMoreTapped);
            }
            final cat = categories[index];
            return CategoryHomeCard(
              title: cat.name!,
              url: cat.url!,
              onTap: () {
                if (cat.children?.isNotEmpty ?? false) {
                  Navigator.pushNamed(context, Routes.subCategoryScreen,
                      arguments: {
                        'categoryList': cat.children,
                        'catName': cat.name,
                        'catId': cat.id,
                        'categoryIds': [cat.id.toString()]
                      });
                } else {
                  Navigator.pushNamed(context, Routes.itemsList, arguments: {
                    'catID': cat.id.toString(),
                    'catName': cat.name,
                    'categoryIds': [cat.id.toString()]
                  });
                }
              },
            );
          },
          itemCount: categories.length > 10
              ? categories.length + 1
              : categories.length,
          separatorBuilder: (_, __) => SizedBox(width: separatorWidth),
        ),
      ),
    );
  }
}

class _MoreCard extends StatelessWidget {
  const _MoreCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final width = isDesktop
        ? 84.0
        : isTablet
            ? 77.0
            : 70.0;
    final containerHeight = isDesktop
        ? 84.0
        : isTablet
            ? 77.0
            : 70.0;
    final borderRadius = isDesktop
        ? 22.0
        : isTablet
            ? 20.0
            : 18.0;
    final textPaddingHorizontal = isDesktop
        ? 4.0
        : isTablet
            ? 3.0
            : 2.0;
    final fontSize = isDesktop
        ? 14.0
        : isTablet
            ? 13.0
            : 12.0;
    final iconSize = isDesktop
        ? 28.0
        : isTablet
            ? 26.0
            : 24.0;

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Column(
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                height: containerHeight,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                        color: context.color.borderColor.darken(60), width: 1),
                    color: context.color.secondaryColor),
                child: Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: UiUtils.getSvg(
                      AppIcons.more,
                      color: context.color.territoryColor,
                      width: iconSize,
                      height: iconSize,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: textPaddingHorizontal),
                  child: CustomText(
                    'more'.translate(context),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    color: context.color.textDefaultColor,
                    fontSize: fontSize,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _AccordionGrid extends StatelessWidget {
  const _AccordionGrid({
    required this.categories,
    required this.expanded,
    required this.onToggle,
  });

  final List<CategoryModel> categories;
  final Map<int, bool> expanded;
  final void Function(int id) onToggle;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final paddingHorizontal = isDesktop
        ? sidePadding * 1.5
        : isTablet
            ? sidePadding * 1.2
            : sidePadding;
    final containerPaddingHorizontal = isDesktop
        ? 18.0
        : isTablet
            ? 16.0
            : 15.0;
    final containerPaddingVertical = isDesktop
        ? 15.0
        : isTablet
            ? 13.0
            : 12.0;
    final marginBottom = isDesktop
        ? 12.0
        : isTablet
            ? 10.0
            : 8.0;
    final fontSizeHeader = isDesktop
        ? 20.0
        : isTablet
            ? 19.0
            : 18.0;
    final fontSizeSub = isDesktop
        ? 16.0
        : isTablet
            ? 15.0
            : 14.0;
    final iconSize = isDesktop
        ? 28.0
        : isTablet
            ? 26.0
            : 24.0;
    final crossAxisCount = isDesktop
        ? 4
        : isTablet
            ? 3
            : 2;
    final imageHeight = isDesktop
        ? 144.0
        : isTablet
            ? 132.0
            : 120.0;
    final subPaddingBottom = isDesktop
        ? 16.0
        : isTablet
            ? 14.0
            : 12.0;
    final subMargin = isDesktop
        ? 8.0
        : isTablet
            ? 7.0
            : 6.0;
    final borderRadius = isDesktop
        ? 14.0
        : isTablet
            ? 12.0
            : 10.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: categories.length,
        itemBuilder: (_, idx) {
          final cat = categories[idx];
          final isOpen = expanded[cat.id!] ?? false;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => onToggle(cat.id!),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: containerPaddingHorizontal,
                      vertical: containerPaddingVertical),
                  margin: EdgeInsets.only(bottom: marginBottom),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(.2),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cat.name!,
                        style: TextStyle(
                            fontSize: fontSizeHeader,
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.blue.shade900,
                        size: iconSize,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: !isOpen
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(bottom: subPaddingBottom),
                        child: MasonryGridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount),
                          itemCount: cat.children?.length ?? 0,
                          itemBuilder: (_, subIdx) {
                            final subCat = cat.children![subIdx];
                            return GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                Routes.itemsList,
                                arguments: {
                                  'catID': subCat.id.toString(),
                                  'catName': subCat.name,
                                  'categoryIds': [subCat.id.toString()]
                                },
                              ),
                              child: Container(
                                margin: EdgeInsets.all(subMargin),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3))
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        subCat.url!,
                                        fit: BoxFit.cover,
                                        height: imageHeight,
                                        width: double.infinity,
                                        loadingBuilder: (context, child,
                                                progress) =>
                                            progress == null
                                                ? child
                                                : const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: isDesktop
                                                  ? 8.0
                                                  : isTablet
                                                      ? 7.0
                                                      : 6.0),
                                          color: Colors.black.withOpacity(0.6),
                                          child: Text(
                                            subCat.name!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: fontSizeSub,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StaggeredGridView extends StatelessWidget {
  const _StaggeredGridView({
    required this.categories,
  });

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final crossAxisCount = isDesktop
        ? 16
        : isTablet
            ? 10
            : 10;
    final mainAxisSpacing = isDesktop
        ? 3.0
        : isTablet
            ? 1.0
            : 1.0;
    final crossAxisSpacing = isDesktop
        ? 3.0
        : isTablet
            ? 1.0
            : 1.0;
    final mainAxisCellCount = isDesktop
        ? 4
        : isTablet
            ? 1.5
            : 3;
    final crossAxisCellCount = (int index) => (index % 4 == 0 || index % 4 == 3)
        ? (isDesktop
            ? 10
            : isTablet
                ? 7
                : 7)
        : (isDesktop
            ? 6
            : isTablet
                ? 3
                : 3);
    final leftOffset = (int index) => (index % 4 == 0 || index % 4 == 3)
        ? (isDesktop
            ? 0.45
            : isTablet
                ? 0.5
                : 0.53)
        : (isDesktop
            ? 0.1
            : isTablet
                ? 0.15
                : 0.2);
    final topOffset = (int index) => (index % 4 == 0 || index % 4 == 3)
        ? (isDesktop
            ? 0.3
            : isTablet
                ? 0.35
                : 0.35)
        : (isDesktop
            ? 0.2
            : isTablet
                ? 0.25
                : 0.25);
    final widthFactor = (int index) => (index % 4 == 0 || index % 4 == 3)
        ? (isDesktop
            ? 0.7
            : isTablet
                ? 0.4
                : 0.4)
        : (isDesktop ? 0.9 : 1.0);
    final heightFactor = (int index) => (index % 4 == 0 || index % 4 == 3)
        ? (isDesktop
            ? 0.5
            : isTablet
                ? 0.6
                : 0.6)
        : (isDesktop
            ? 1.0
            : isTablet
                ? 0.8
                : 0.8);
    final fontSize = isDesktop
        ? 16.0
        : isTablet
            ? 12.0
            : 12.0;
    final paddingHorizontal = isDesktop
        ? 20.0
        : isTablet
            ? 10.0
            : 10.0;
    final margin = isDesktop
        ? 10.0
        : isTablet
            ? 6.0
            : 6.0;
    final textPaddingHorizontal = isDesktop
        ? 12.0
        : isTablet
            ? 8.0
            : 8.0;
    final textPaddingVertical = isDesktop
        ? 6.0
        : isTablet
            ? 4.0
            : 4.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: StaggeredGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        children: List.generate(categories.length, (index) {
          final cat = categories[index];

          final List<Color> backgroundColors = [
            Color(0xFFD4EDFE),
            Color.fromARGB(255, 224, 219, 221),
          ];
          final Color tileColor =
              backgroundColors[(index % 4 == 0 || index % 4 == 3) ? 0 : 1];

          return StaggeredGridTile.count(
            crossAxisCellCount: crossAxisCellCount(index),
            mainAxisCellCount: mainAxisCellCount,
            child: GestureDetector(
              onTap: () {
                if (cat.children?.isNotEmpty ?? false) {
                  Navigator.pushNamed(context, Routes.subCategoryScreen,
                      arguments: {
                        'categoryList': cat.children,
                        'catName': cat.name,
                        'catId': cat.id,
                        'categoryIds': [cat.id.toString()]
                      });
                } else {
                  Navigator.pushNamed(context, Routes.itemsList, arguments: {
                    'catID': cat.id.toString(),
                    'catName': cat.name,
                    'categoryIds': [cat.id.toString()]
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.all(margin),
                decoration: BoxDecoration(
                  color: tileColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.1),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Positioned(
                          left: constraints.maxWidth * leftOffset(index),
                          top: constraints.maxHeight * topOffset(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              width: constraints.maxWidth * widthFactor(index),
                              height:
                                  constraints.maxHeight * heightFactor(index),
                              child: Image.network(
                                cat.url!,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                loadingBuilder: (context, child, progress) =>
                                    progress == null
                                        ? child
                                        : const Center(
                                            child: CircularProgressIndicator()),
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.red.withOpacity(0.1),
                                    child: const Center(
                                      child: Text(
                                        'Image not found',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          left: 1,
                          right: 1,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: textPaddingHorizontal,
                                vertical: textPaddingVertical),
                            child: Text(
                              cat.name!.toUpperCase(),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: (index % 4 == 0 || index % 4 == 3)
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : Colors.black,
                                fontSize: fontSize,
                                fontWeight: FontWeight.normal,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

extension on ColorScheme {
  Null get iconColor => null;
}