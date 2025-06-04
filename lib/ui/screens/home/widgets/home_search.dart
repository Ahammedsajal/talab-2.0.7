
import 'package:Talab/app/routes.dart';
import 'package:Talab/ui/screens/home/home_screen.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

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
              child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    fillColor: Theme.of(context).colorScheme.secondaryColor,
                    hintText: "searchHintLbl".translate(context),
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
                  onTap: () {})),
        ),
      ),
    );
  }
}
