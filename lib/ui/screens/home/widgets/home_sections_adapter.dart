import 'package:Talab/app/app_theme.dart';
import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/favorite/favorite_cubit.dart';
import 'package:Talab/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:Talab/data/cubits/system/app_theme_cubit.dart';
import 'package:Talab/data/cubits/item/item_view_count_cubit.dart';
import 'package:Talab/data/model/home/home_screen_section.dart';
import 'package:Talab/data/model/item/item_card_field.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/repositories/favourites_repository.dart';
import 'package:Talab/ui/screens/home/home_screen.dart';
import 'package:Talab/ui/screens/home/widgets/section_header.dart';
import 'package:Talab/ui/screens/home/widgets/banner_section_widget.dart';
import 'package:Talab/ui/screens/home/widgets/grid_list_adapter.dart';
import 'package:Talab/ui/screens/widgets/promoted_widget.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/extensions/lib/currency_formatter.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:Talab/utils/icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
class HomeSectionsAdapter extends StatelessWidget {
  final HomeScreenSection section;

  const HomeSectionsAdapter({
    super.key,
    required this.section,
  });

  Widget _buildItemCard({
    required BuildContext context,
    required ItemModel? item,
    required int index,
    required int realIndex,
    required double animationValue,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.adDetailsScreen,
          arguments: {"model": item},
        );
      },
      child: Opacity(
        opacity: animationValue,
        child: ExpandableHomeItemCard(
          item: item,
          width: _getCardWidth(context),
        ),
      ),
    );
  }

  double _getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600 && width <= 1200;
    final isDesktop = width > 1200;
    final fraction = isDesktop
        ? 0.25
        : isTablet
            ? 0.45
            : 0.7;
    return width * fraction;
  }
  @override
  Widget build(BuildContext context) {
    if (section.filter == 'banner') {
      return BannerSectionWidget(section: section);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;
    final gridHeightStyle3 = isDesktop ? 280.0 : isTablet ? 255.0 : 270.0;
    final crossAxisCountStyle3 = isDesktop
        ? 4
        : isTablet
            ? 4
            : 2;
    final cardWidthStyle3And4 = isDesktop ? 260.0 : isTablet ? 240.0 : 240.0;
    final listSeparatorWidthStyle4 = isDesktop ? 16.0 : isTablet ? 12.0 : 10.0;

   if (section.style == "style_1") {
  return section.sectionData!.isNotEmpty
      ? Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SectionHeader(
                    title: section.title ?? "Trending Items",
                    buttonText: "Explore",
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.sectionWiseItemsScreen,
                        arguments: {
                          "title": section.title,
                          "sectionId": section.sectionId,
                        },
                      );
                    },
                  ),
                ),
              SizedBox(
                height: isDesktop ? 300 : isTablet ? 280 : 270,
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                    viewportFraction: isDesktop ? 0.25 : isTablet ? 0.45 : 0.7,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.3,
                    scrollPhysics: const BouncingScrollPhysics(),
                    enableInfiniteScroll: true,
                    padEnds: true,
                  ),
                  itemCount: section.sectionData?.length ?? 0,
                  itemBuilder: (context, index, realIndex) {
                    ItemModel? item = section.sectionData?[index];
                    return AnimatedOpacity(
                      opacity: realIndex == index ? 1.0 : 0.8,
                      duration: const Duration(milliseconds: 300),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.adDetailsScreen,
                            arguments: {"model": item},
                          );
                        },
                        child: Container(
                          width: isDesktop ? 320 : isTablet ? 280 : 240,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.surface,
                                Theme.of(context).colorScheme.primary.withOpacity(0.05),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor.withOpacity(0.15),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      item?.image ?? "",
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          height: 150,
                                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          child: const Center(child: CircularProgressIndicator()),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 150,
                                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                          child: const Icon(Icons.image_not_supported, size: 40),
                                        );
                                      },
                                    ),
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item?.name ?? "Item Name",
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          (item?.price ?? 0.0).currencyFormat,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                        ),
                                        AnimatedScale(
                                          scale: realIndex == index ? 1.0 : 0.9,
                                          duration: const Duration(milliseconds: 200),
                                          child: Icon(
                                            Icons.favorite_border,
                                            size: 20,
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        )
      : const SizedBox.shrink();
} else if (section.style == "style_2") {
  return section.sectionData!.isNotEmpty
      ? Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6),
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SectionHeader(
                    title: section.title ?? "Featured Collections",
                    buttonText: "Browse All",
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.sectionWiseItemsScreen,
                        arguments: {
                          "title": section.title,
                          "sectionId": section.sectionId,
                        },
                      );
                    },
                  ),
                ),
              SizedBox(
                height: isDesktop ? 340 : isTablet ? 320 : 300,
                child: CarouselSlider.builder(
                  options: CarouselOptions(
                    autoPlay: false,
                    viewportFraction: isDesktop ? 0.25 : isTablet ? 0.45 : 0.7,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.3,
                    scrollPhysics: const BouncingScrollPhysics(),
                    enableInfiniteScroll: true,
                    padEnds: true,
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  ),
                  itemCount: section.sectionData?.length ?? 0,
                  itemBuilder: (context, index, realIndex) {
                    ItemModel? item = section.sectionData?[index];
                    final animation = ModalRoute.of(context)?.animation;
                    return AnimatedOpacity(
                      opacity: realIndex == index ? 1.0 : 0.8,
                      duration: const Duration(milliseconds: 300),
                      child: animation != null
                          ? AnimatedBuilder(
                              animation: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              ),
                              builder: (context, child) {
                                return _buildItemCard(
                                  context: context,
                                  item: item,
                                  index: index,
                                  realIndex: realIndex,
                                  animationValue: animation.value,
                                );
                              },
                            )
                          : _buildItemCard(
                              context: context,
                              item: item,
                              index: index,
                              realIndex: realIndex,
                              animationValue: 1.0,
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        )
      : const SizedBox.shrink();
} else if (section.style == "style_3") {
  final items = section.sectionData ?? [];
  return items.isNotEmpty
    ? MasonryGridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: sidePadding, vertical: 8),
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCountStyle3,
        ),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ItemCard(
            item: items[index],
            width: cardWidthStyle3And4,
          );
        },
      )
    : const SizedBox.shrink();
}
else if (section.style == "style_4") {
      return section.sectionData!.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SectionHeader(
                    title: section.title ?? "",
                    buttonText: "Show All",
                    onTap: () {
                      Navigator.pushNamed(context, Routes.sectionWiseItemsScreen,
                          arguments: {
                            "title": section.title,
                            "sectionId": section.sectionId,
                          });
                    },
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: gridHeightStyle3),
                    child: GridListAdapter(
                      type: ListUiType.List,
                      height: gridHeightStyle3,
                      listAxis: Axis.horizontal,
                      listSeparator: (BuildContext p0, int p1) => SizedBox(
                        width: listSeparatorWidthStyle4,
                      ),
                      builder: (context, int index, bool) {
                        ItemModel? item = section.sectionData?[index];
                        return ItemCard(
                          item: item,
                          width: cardWidthStyle3And4,
                        );
                      },
                      total: section.sectionData?.length ?? 0,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink();
    } else {
      return Container();
    }
  }
}

class ItemCard extends StatefulWidget {
  final double? width;
  final double? height;
  final bool? bigCard;
  final ItemModel? item;

  const ItemCard({
    super.key,
    required this.item,
    this.width,
    this.height,
    this.bigCard,
  });

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final double likeButtonSize = 32;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.width ?? double.infinity;
    final cardHeight = widget.height;
    final bool isBig = widget.bigCard ?? false;
    final imageHeight = cardHeight != null
        ? cardHeight * (isBig ? 0.55 : 0.6)
        : (isBig ? 200.0 : 160.0);
    final nameFont = isBig ? context.font.larger : context.font.large;
    final priceFont = isBig ? context.font.large : context.font.small;
    final addressFont = isBig ? context.font.normal : context.font.smaller;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.adDetailsScreen, arguments: {"model": widget.item}),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        constraints: cardHeight == null ? BoxConstraints(minHeight: isBig ? 300 : 260) : null,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: SingleChildScrollView( // Add scrollable container to handle overflow
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      widget.item?.image ?? '',
                      width: double.infinity,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: imageHeight,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.image_not_supported, size: 40),
                        );
                      },
                    ),
                  ),
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: favButton(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      widget.item!.name!,
                      fontSize: nameFont,
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (widget.item?.price ?? 0.0).currencyFormat,
                      style: TextStyle(
                        fontSize: priceFont,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if ((widget.item?.address ?? "").isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          UiUtils.getSvg(AppIcons.location, width: 12, height: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: CustomText(
                              widget.item!.address!,
                              fontSize: addressFont,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.item?.cardFields != null && widget.item!.cardFields!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      _buildCardFieldsSection(context),
                    ],
                    Builder(builder: (context) {
                      final count = context.watch<ItemViewCountCubit>().counts[widget.item?.id] ?? widget.item?.views ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Row(
                          children: [
                            UiUtils.getSvg(AppIcons.eye, width: 12, height: 12),
                            const SizedBox(width: 4),
                            CustomText(
                              '$count',
                              fontSize: addressFont,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardFieldsSection(BuildContext context) {
    final fields = widget.item!.cardFields!;
    final theme = Theme.of(context);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: fields.map((field) => _buildModernCardField(context, field)).toList(),
    );
  }

  Widget _buildModernCardField(BuildContext context, ItemCardField field) {
    final theme = Theme.of(context);

    final backgroundColor = theme.colorScheme.surfaceVariant.withOpacity(0.85);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.light
                ? Colors.black.withOpacity(0.04)
                : Colors.black.withOpacity(0.13),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (field.icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Icon(
                IconMapper.map(field.icon),
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          Flexible(
            child: Text(
              field.value ?? '',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  

  Widget favButton() {
    bool isLike =
        context.read<FavoriteCubit>().isItemFavorite(widget.item!.id!);

    return BlocProvider(
        create: (context) => UpdateFavoriteCubit(FavoriteRepository()),
        child: BlocConsumer<FavoriteCubit, FavoriteState>(
            bloc: context.read<FavoriteCubit>(),
            listener: ((context, state) {
              if (state is FavoriteFetchSuccess) {
                isLike = context
                    .read<FavoriteCubit>()
                    .isItemFavorite(widget.item!.id!);
              }
            }),
            builder: (context, likeAndDislikeState) {
              return BlocConsumer<UpdateFavoriteCubit, UpdateFavoriteState>(
                  bloc: context.read<UpdateFavoriteCubit>(),
                  listener: ((context, state) {
                    if (state is UpdateFavoriteSuccess) {
                      if (state.wasProcess) {
                        context
                            .read<FavoriteCubit>()
                            .addFavoriteitem(state.item);
                      } else {
                        context
                            .read<FavoriteCubit>()
                            .removeFavoriteItem(state.item);
                      }
                    }
                  }),

                  builder: (context, state) {
                    return InkWell(
                      onTap: () {
                        UiUtils.checkUser(
                            onNotGuest: () {
                              context
                                  .read<UpdateFavoriteCubit>()
                                  .setFavoriteItem(
                                    item: widget.item!,
                                    type: isLike ? 0 : 1,
                                  );
                            },
                            context: context);
                      },
                      child: Container(
                        width: likeButtonSize,
                        height: likeButtonSize,
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow:
                              context.watch<AppThemeCubit>().state.appTheme ==
                                      AppTheme.dark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.grey[300]!,
                                        offset: const Offset(0, 2),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                      ),
                                    ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.none,
                          child: state is UpdateFavoriteInProgress
                              ? Center(child: UiUtils.progress())
                              : UiUtils.getSvg(
                                  isLike ? AppIcons.like_fill : AppIcons.like,
                                  width: 22,
                                  height: 22,
                                  color: context.color.territoryColor,
                                ),
                        ),
                      ),
                    );
                  });
            }));
  }
}

class ExpandableHomeItemCard extends StatefulWidget {
  final ItemModel? item;
  final double width;

  const ExpandableHomeItemCard({
    Key? key,
    required this.item,
    required this.width,
  }) : super(key: key);

  @override
  State<ExpandableHomeItemCard> createState() => _ExpandableHomeItemCardState();
}

class _ExpandableHomeItemCardState extends State<ExpandableHomeItemCard>
    with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: widget.width,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: UiUtils.getImage(
                item?.image ?? '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    item?.name ?? '',
                    fontSize: context.font.large,
                    fontWeight: FontWeight.w600,
                    maxLines: _expanded ? null : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (item?.price ?? 0.0).currencyFormat,
                    style: TextStyle(
                      fontSize: context.font.small,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if ((item?.address ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        UiUtils.getSvg(AppIcons.location, width: 12, height: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: CustomText(
                            item!.address!,
                            fontSize: context.font.smaller,
                            color:
                                Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            maxLines: _expanded ? null : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (item?.cardFields != null && item!.cardFields!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: item.cardFields!
                          .map((f) => _buildModernCardField(context, f))
                          .toList(),
                    ),
                  ],
                  Builder(builder: (context) {
                    final count = context.watch<ItemViewCountCubit>().counts[item?.id] ?? item?.views ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          UiUtils.getSvg(AppIcons.eye, width: 12, height: 12),
                          const SizedBox(width: 4),
                          CustomText(
                            '$count',
                            fontSize: context.font.smaller,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ],
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCardField(BuildContext context, ItemCardField field) {
    final theme = Theme.of(context);

    final backgroundColor =
        theme.colorScheme.surfaceVariant.withOpacity(0.85);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.light
                ? Colors.black.withOpacity(0.04)
                : Colors.black.withOpacity(0.13),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (field.icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Icon(
                IconMapper.map(field.icon),
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
          Flexible(
            child: Text(
              field.value ?? '',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
