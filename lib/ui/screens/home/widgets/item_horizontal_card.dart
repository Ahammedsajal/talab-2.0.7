// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Talab/app/app_theme.dart';
import 'package:Talab/data/cubits/favorite/favorite_cubit.dart';
import 'package:Talab/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:Talab/data/cubits/system/app_theme_cubit.dart';
import 'package:Talab/data/model/item/item_card_field.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/repositories/favourites_repository.dart';
import 'package:Talab/ui/screens/widgets/promoted_widget.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/extensions/lib/currency_formatter.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:Talab/utils/icon_mapper.dart';
import 'package:Talab/data/cubits/item/item_view_count_cubit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemHorizontalCard extends StatelessWidget {
  final ItemModel item;
  final List<Widget>? addBottom;
  final double? additionalHeight;
  final StatusButton? statusButton;
  final bool? useRow;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;
  final double? cardWidth;
  final double? cardHeight;

  const ItemHorizontalCard(
      {super.key,
      required this.item,
      this.useRow,
      this.addBottom,
      this.additionalHeight,
      this.statusButton,
      this.onDeleteTap,
      this.showLikeButton,
      this.additionalImageWidth,
      this.cardWidth,
      this.cardHeight});

  Widget favButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final buttonSize = isDesktop ? 40.0 : isTablet ? 36.0 : 32.0;
    final iconSize = isDesktop ? 26.0 : isTablet ? 24.0 : 22.0;

    bool isLike = context.read<FavoriteCubit>().isItemFavorite(item.id!);
    return BlocProvider(
        create: (context) => UpdateFavoriteCubit(FavoriteRepository()),
        child: BlocConsumer<FavoriteCubit, FavoriteState>(
            bloc: context.read<FavoriteCubit>(),
            listener: ((context, state) {
              if (state is FavoriteFetchSuccess) {
                isLike = context.read<FavoriteCubit>().isItemFavorite(item.id!);
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
                                    item: item,
                                    type: isLike ? 0 : 1,
                                  );
                            },
                            context: context);
                      },
                      child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          shape: BoxShape.circle,
                          boxShadow:
                              context.watch<AppThemeCubit>().state.appTheme ==
                                      AppTheme.dark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Color.fromARGB(12, 0, 0, 0),
                                        offset: Offset(0, 2),
                                        blurRadius: 10,
                                        spreadRadius: 4,
                                      )
                                    ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.none,
                          child: state is UpdateFavoriteInProgress
                              ? Center(child: UiUtils.progress())
                              : UiUtils.getSvg(
                                  isLike ? AppIcons.like_fill : AppIcons.like,
                                  width: iconSize,
                                  height: iconSize,
                                  color: context.color.territoryColor,
                                ),
                        ),
                      ),
                    );
                  });
            }));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    // Responsive parameters
    final statusButtonHeight = isDesktop ? 34.0 : isTablet ? 32.0 : 30.0;
    final containerHeight =
        cardHeight ?? (isDesktop ? 150.0 : isTablet ? 137.0 : 124.0);
    final imageWidth = isDesktop ? 120.0 : isTablet ? 110.0 : 100.0;
    final imageHeight = containerHeight -
        (statusButton != null ? statusButtonHeight + 4.0 : 2.0);
    final paddingVertical = isDesktop ? 6.0 : isTablet ? 5.0 : 4.5;
    final paddingHorizontal = isDesktop ? 15.0 : isTablet ? 13.0 : 12.0;
    final fontSizePrice = isDesktop ? 18.0 : isTablet ? 17.0 : context.font.large;
    final fontSizeName = isDesktop ? 16.0 : isTablet ? 15.0 : context.font.normal;
    final fontSizeAddress = isDesktop ? 14.0 : isTablet ? 13.0 : context.font.smaller;
    final iconSize = isDesktop ? 18.0 : isTablet ? 16.0 : 15.0;
    final borderRadius = isDesktop ? 18.0 : isTablet ? 16.0 : 15.0;
    final statusButtonWidth = isDesktop ? 100.0 : isTablet ? 90.0 : 80.0;
    final statusButtonFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : context.font.small;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: paddingVertical),
      child: Container(
        width: cardWidth ?? double.infinity,
        height: addBottom == null ? containerHeight : (containerHeight + (additionalHeight ?? 0)),
        decoration: BoxDecoration(
            border: Border.all(color: context.color.borderColor.darken(50)),
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(borderRadius),
                                child: SizedBox(
                                  width: imageWidth + (additionalImageWidth ?? 0),
                                  height: imageHeight,
                                  child: UiUtils.getImage(
                                    item.image ?? "",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (item.isFeature ?? false)
                                const PositionedDirectional(
                                    start: 5,
                                    top: 5,
                                    child: PromotedCard(type: PromoteCardType.icon)),
                            ],
                          ),
                          if (statusButton != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: statusButton!.color,
                                    borderRadius: BorderRadius.circular(4)),
                                width: statusButtonWidth,
                                height: statusButtonHeight,
                                child: Center(
                                    child: CustomText(
                                        statusButton!.lable,
                                        fontSize: statusButtonFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: statusButton?.textColor ?? Colors.black)),
                              ),
                            )
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(
                            top: 0,
                            start: paddingHorizontal,
                            bottom: 5,
                            end: paddingHorizontal,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: CustomText(
                                    (item.price ?? 0.0).currencyFormat,
                                    fontSize: fontSizePrice,
                                    color: context.color.territoryColor,
                                    fontWeight: FontWeight.w700,
                                  )),
                                  if (showLikeButton ?? true) favButton(context)
                                ],
                              ),
                              CustomText(
                                (item.translatedName ?? item.name ?? '')
                                    .firstUpperCase(),
                                fontSize: fontSizeName,
                                color: context.color.textDefaultColor,
                                maxLines: 2,
                              ),
                              if (item.address != "")
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: iconSize,
                                      color: context.color.textDefaultColor
                                          .withValues(alpha: 0.5),
                                    ),
                                    Expanded(
                                        child: CustomText(
                                      item.address?.trim() ?? "",
                                      fontSize: fontSizeAddress,
                                      color: context.color.textDefaultColor
                                          .withValues(alpha: 0.5),
                                      maxLines: 1,
                                    ))
                                  ],
                                ),
                              if (item.cardFields != null && item.cardFields!.isNotEmpty)
                                 _buildCardFieldsSection(context),
                              Builder(builder: (context) {
                                final count = context.watch<ItemViewCountCubit>().counts[item.id] ?? item.views ?? 0;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(AppIcons.eye,
                                          width: iconSize,
                                          height: iconSize,
                                          colorFilter: ColorFilter.mode(
                                              context.color.textDefaultColor.withValues(alpha: 0.5),
                                              BlendMode.srcIn)),
                                      const SizedBox(width: 4),
                                      CustomText(
                                        '$count',
                                        fontSize: fontSizeAddress,
                                        color: context.color.textDefaultColor.withValues(alpha: 0.5),
                                      )
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (useRow == false || useRow == null) ...addBottom ?? [],
                if (useRow == true) ...{Row(children: addBottom ?? [])}
              ],
            ),
          ],
        ),
      ),
    );
  }
   Widget _buildCardFieldsSection(BuildContext context) {
    final fields = item.cardFields!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children:
            fields.map((field) => _buildModernCardField(context, field)).toList(),
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

class StatusButton {
  final String lable;
  final Color color;
  final Color? textColor;

  StatusButton({
    required this.lable,
    required this.color,
    this.textColor,
  });
}
