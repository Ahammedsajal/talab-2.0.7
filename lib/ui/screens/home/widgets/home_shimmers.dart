import 'package:Talab/ui/screens/home/home_screen.dart';
import 'package:Talab/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class SliderShimmer extends StatelessWidget {
  const SliderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final height = isDesktop ? 160.0 : isTablet ? 145.0 : 130.0;
    final paddingHorizontal = isDesktop ? sidePadding * 1.5 : isTablet ? sidePadding * 1.2 : sidePadding;
    final spacing = isDesktop ? 15.0 : isTablet ? 12.0 : 10.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: Column(
        children: [
          SizedBox(height: spacing),
          CustomShimmer(
            height: height,
            width: context.screenWidth,
          ),
          SizedBox(height: spacing),
        ],
      ),
    );
  }
}

class PromotedItemsShimmer extends StatelessWidget {
  const PromotedItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final height = isDesktop ? 320.0 : isTablet ? 296.0 : 272.0;
    final width = isDesktop ? 300.0 : isTablet ? 275.0 : 250.0;
    final itemCount = isDesktop ? 7 : isTablet ? 6 : 5;
    final paddingHorizontal = isDesktop ? sidePadding * 1.5 : isTablet ? sidePadding * 1.2 : sidePadding;
    final itemSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : 8.0;

    return SizedBox(
        height: height,
        child: ListView.builder(
            itemCount: itemCount,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : itemSpacing),
                child: CustomShimmer(
                  height: height,
                  width: width,
                ),
              );
            }));
  }
}

class MostLikedItemsShimmer extends StatelessWidget {
  const MostLikedItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final crossAxisCount = isDesktop ? 4 : isTablet ? 3 : 2;
    final childAspectRatio = isDesktop ? 180 / 320 : isTablet ? 170 / 300 : 162 / 274;
    final mainAxisSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : 8.0;
    final crossAxisSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : 8.0;
    final paddingHorizontal = isDesktop ? sidePadding * 1.5 : isTablet ? sidePadding * 1.2 : sidePadding;
    final itemCount = isDesktop ? 8 : isTablet ? 6 : 5;

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          crossAxisCount: crossAxisCount),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: const CustomShimmer(),
        );
      },
    );
  }
}

class NearbyItemsShimmer extends StatelessWidget {
  const NearbyItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final height = isDesktop ? 240.0 : isTablet ? 220.0 : 200.0;
    final width = isDesktop ? 360.0 : isTablet ? 330.0 : 300.0;
    final itemCount = isDesktop ? 7 : isTablet ? 6 : 5;
    final paddingHorizontal = isDesktop ? sidePadding * 1.5 : isTablet ? sidePadding * 1.2 : sidePadding;
    final itemSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : 8.0;

    return SizedBox(
        height: height,
        child: ListView.builder(
            itemCount: itemCount,
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: index == 0 ? 0 : itemSpacing),
                child: CustomShimmer(
                  height: height,
                  width: width,
                ),
              );
            }));
  }
}

class MostViewdItemsShimmer extends StatelessWidget {
  const MostViewdItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final crossAxisCount = isDesktop ? 4 : isTablet ? 3 : 2;
    final childAspectRatio = isDesktop ? 180 / 320 : isTablet ? 170 / 300 : 162 / 274;
    final mainAxisSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : 15.0;
    final paddingHorizontal = isDesktop ? sidePadding * 1.5 : isTablet ? sidePadding * 1.2 : sidePadding;
    final itemCount = isDesktop ? 8 : isTablet ? 6 : 5;

    return GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: childAspectRatio,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisCount: crossAxisCount),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(mainAxisSpacing / 2),
            child: const CustomShimmer(),
          );
        });
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    final width = isDesktop ? 120.0 : isTablet ? 110.0 : 100.0;
    final height = isDesktop ? 52.0 : isTablet ? 48.0 : 44.0;
    final itemCount = isDesktop ? 6 : isTablet ? 5 : 4;
    final paddingHorizontal = isDesktop ? sidePadding * 1.5 : isTablet ? sidePadding * 1.2 : sidePadding;
    final marginEnd = isDesktop ? 15.0 : isTablet ? 12.0 : 10.0;

    return ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
        itemBuilder: (context, index) {
          return CustomShimmer(
            width: width,
            height: height,
            margin: EdgeInsetsDirectional.only(end: marginEnd, bottom: 5),
          );
        });
  }
}
