import 'package:Talab/app/app_theme.dart';
import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/favorite/favorite_cubit.dart';
import 'package:Talab/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:Talab/data/cubits/system/app_theme_cubit.dart';
import 'package:Talab/data/model/home/home_screen_section.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/repositories/favourites_repository.dart';
import 'package:Talab/ui/screens/home/home_screen.dart';
import 'package:Talab/ui/screens/home/widgets/banner_section_widget.dart';
import 'package:Talab/ui/screens/home/widgets/grid_list_adapter.dart';
import 'package:Talab/ui/screens/widgets/promoted_widget.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/extensions/lib/currency_formatter.dart';
import 'package:Talab/utils/ui_utils.dart';
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
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      child: Stack(
                        children: [
                          Image.network(
                            item?.image ?? "",
                            height: 125,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 125,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 125,
                                color: Colors.grey[200],
                                child: Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item?.name ?? "Item Name",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (item?.price ?? 0.0).currencyFormat, // Updated to use currencyFormat
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star, size: 11, color: Colors.blueAccent),
                                    SizedBox(width: 1),
                                    Text(
                                      "4.8",
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 7,
                  top: 7,
                  child: AnimatedOpacity(
                    opacity: realIndex == index ? 1.0 : 0.7,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 15,
                        color: Colors.redAccent,
                      ),
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
  @override
  Widget build(BuildContext context) {
    if (section.filter == 'banner') {
      return BannerSectionWidget(section: section);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;
    final gridHeightStyle3 = isDesktop ? 280.0 : isTablet ? 255.0 : 255.0;
    final crossAxisCountStyle3 = isDesktop ? 4 : isTablet ? 2 : 2;
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.surface,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Text(
                          section.title ?? "Trending Items",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      GestureDetector(
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "See All",
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: isDesktop ? 300 : isTablet ? 280 : 260,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          section.title ?? "Featured Collections",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface,
                                letterSpacing: 0.4,
                              ),
                        ),
                      ],
                    ),
                    GestureDetector(
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Explore",
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
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
                  TitleHeader(
                    title: section.title ?? "",
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

class TitleHeader extends StatelessWidget {
  final String title;
  final Function() onTap;
  final bool? hideSeeAll;

  const TitleHeader({
    super.key,
    required this.title,
    required this.onTap,
    this.hideSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          top: 5, bottom: 5, start: sidePadding, end: sidePadding),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: CustomText(
              title,
              fontSize: context.font.large,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          if (!(hideSeeAll ?? false))
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: CustomText(
                  "seeAll".translate(context),
                  fontSize: context.font.smaller + 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class ItemCard extends StatefulWidget {
  final double? width;
  final bool? bigCard;
  final ItemModel? item;

  const ItemCard({
    super.key,
    required this.item,
    this.width,
    this.bigCard,
  });

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final double likeButtonSize = 32;
  final double imageHeight    = 165;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.width ?? 250.0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, Routes.adDetailsScreen, arguments: {"model": widget.item}),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 1,
            )
          ],
        ),
        child: Stack(
          children: [
            Column(
               mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: UiUtils.getImage(
                    widget.item?.image ?? "",
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

         
            
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      CustomText(
                        widget.item!.name!,
                        fontSize: context.font.large,
                        fontWeight: FontWeight.w600,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (widget.item?.price ?? 0.0).currencyFormat,
                        style: TextStyle(
                          fontSize: context.font.small,
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
                                fontSize: context.font.smaller,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
              
              ],
            ),

            // FAVORITE BUTTON
             favButton(),
          
          ],
        ),
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
                    return PositionedDirectional(
                      top: imageHeight - (likeButtonSize / 2) - 2,
                      end: 16,
                      child: InkWell(
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
                      ),
                    );
                  });
            }));
  }
}