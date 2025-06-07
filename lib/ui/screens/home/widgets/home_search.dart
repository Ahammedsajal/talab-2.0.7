import 'dart:async';

import 'package:Talab/data/cubits/category/fetch_category_cubit.dart';
import 'package:Talab/app/routes.dart';
import 'package:Talab/ui/screens/home/home_screen.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeSearchField extends StatefulWidget {
  const HomeSearchField({super.key});
  static double preferredHeight(BuildContext context) {
     final screenWidth = MediaQuery.of(context).size.width;
     final isTablet = screenWidth >= 600 && screenWidth <= 1200;
      final isDesktop = screenWidth > 1200;

     final containerHeight = isDesktop ? 64.0 : isTablet ? 60.0 : 56.0;
     final paddingVertical = isDesktop ? 20.0 : isTablet ? 18.0 : 15.0;
      return containerHeight + paddingVertical * 2;
   }
@override
  State<HomeSearchField> createState() => _HomeSearchFieldState();
}

class _HomeSearchFieldState extends State<HomeSearchField> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final categories = context.read<FetchCategoryCubit>().getCategories();
      if (categories.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % categories.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    // Responsive parameters
    final containerHeight = isDesktop ? 64.0 : isTablet ? 60.0 : 56.0;
    final paddingHorizontal = isDesktop ? sidePadding * 1.5 : isTablet ? sidePadding * 1.2 : sidePadding;
    final paddingVertical = isDesktop ? 20.0 : isTablet ? 18.0 : 15.0;
    final iconPadding = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final fontSize = isDesktop ? 18.0 : isTablet ? 16.0 : 14.0;
    final borderRadius = isDesktop ? 12.0 : isTablet ? 11.0 : 10.0;

    Widget buildSearchIcon() {
      return Padding(
          padding: EdgeInsetsDirectional.only(start: iconPadding, end: iconPadding),
          child: UiUtils.getSvg(
            AppIcons.search,
            color: context.color.territoryColor,
            width: isDesktop ? 24.0 : isTablet ? 22.0 : 20.0,
            height: isDesktop ? 24.0 : isTablet ? 22.0 : 20.0,
          ));
    }
 final categories = context.watch<FetchCategoryCubit>().getCategories();
    final hint = categories.isNotEmpty
        ? categories[_currentIndex % categories.length].name ?? ''
        : "searchHintLbl".translate(context);


    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.pushNamed(context, Routes.searchScreenRoute, arguments: {
            "autoFocus": true,
          });
        },
        child: AbsorbPointer(
          absorbing: true,
          child: Container(
              width: context.screenWidth,
              height: containerHeight,
              alignment: AlignmentDirectional.center,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: context.color.borderColor.darken(30)),
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                  color: context.color.secondaryColor),


             child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  final offset = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
                      .animate(animation);
                  return ClipRect(
                    child: SlideTransition(
                      position: offset,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                  );
                },
                child: TextFormField(
                    key: ValueKey(hint),
                    readOnly: true,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Theme.of(context).colorScheme.secondaryColor,
                      hintText: hint,
                      hintStyle: TextStyle(
                          fontSize: fontSize,
                          color: context.color.textDefaultColor.withValues(alpha: 0.5)),
                      prefixIcon: buildSearchIcon(),
                      prefixIconConstraints: const BoxConstraints(minHeight: 5, minWidth: 5),
                    ),
                    enableSuggestions: true,
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                    },
                    onTap: () {}),
              )),
        ),
      ),
    );
  }
}
