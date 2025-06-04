import 'package:Talab/ui/screens/home/home_screen.dart';
import 'package:Talab/utils/custom_silver_grid_delegate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum ListUiType { Grid, List, Mixed }
class GridListAdapter extends StatelessWidget {
  final ListUiType type;
  final Widget Function(BuildContext, int, bool) builder;
  final Widget Function(BuildContext, int)? listSeparator;
  final int total;
  final int? crossAxisCount;
  final double? height;
  final Axis? listAxis;
  final ScrollController? controller;
  final bool? isNotSidePadding;
  final bool mixMode;

  const GridListAdapter({
    super.key,
    required this.type,
    required this.builder,
    required this.total,
    this.crossAxisCount,
    this.height,
    this.listAxis,
    this.listSeparator,
    this.controller,
    this.isNotSidePadding,
    this.mixMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveCrossAxisCount = crossAxisCount ?? (screenWidth < 768 ? 2 : (screenWidth < 1024 ? (2 + ((screenWidth - 768) / 256).round()) : 3));
    final responsiveHeight = height ?? (screenWidth < 768 ? 1.0 : (screenWidth < 1024 ? 1 + (screenWidth - 768) * 0.001 : 1.2));

    if (type == ListUiType.List) {
      return SizedBox(
        height: listAxis == Axis.horizontal ? height : null,
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(
              horizontal: isNotSidePadding != null ? 0 : sidePadding),
          scrollDirection: listAxis ?? Axis.vertical,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => builder(context, index, false),
          itemCount: total,
          separatorBuilder: listSeparator ?? ((c, i) => Container()),
        ),
      );
    } else if (type == ListUiType.Grid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: sidePadding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
            crossAxisCount: responsiveCrossAxisCount,
            height: responsiveHeight,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15),
        itemBuilder: (context, index) => builder(context, index, false),
        itemCount: total,
      );
    } else if (type == ListUiType.Mixed) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
            horizontal: sidePadding, vertical: 15 / 2),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
            crossAxisCount: responsiveCrossAxisCount,
            height: responsiveHeight,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15),
        itemBuilder: (context, index) => builder(context, index, true),
        itemCount: total,
      );
    } else {
      return Container();
    }
  }
}