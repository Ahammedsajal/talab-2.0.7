
import 'package:Talab/app/routes.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/hive_keys.dart';
import 'package:Talab/utils/hive_utils.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    // Responsive parameters
    final containerSize = isDesktop ? 48.0 : isTablet ? 44.0 : 40.0;
    final spacing = isDesktop ? 14.0 : isTablet ? 12.0 : 10.0;
    final fontSize = isDesktop ? 14.0 : isTablet ? 13.0 : context.font.small;
    final iconSize = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final borderRadius = isDesktop ? 12.0 : isTablet ? 11.0 : 10.0;

    return FittedBox(
      fit: BoxFit.none,
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.pushNamed(context, Routes.countriesScreen,
                  arguments: {"from": "home"});
            },
            child: Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                  color: context.color.secondaryColor,
                  borderRadius: BorderRadius.circular(borderRadius)),
              child: UiUtils.getSvg(
                AppIcons.location,
                fit: BoxFit.none,
                color: context.color.territoryColor,
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),
          SizedBox(width: spacing),
          ValueListenableBuilder(
              valueListenable: Hive.box(HiveKeys.userDetailsBox).listenable(),
              builder: (context, value, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "locationLbl".translate(context),
                      color: context.color.textColorDark,
                      fontSize: fontSize,
                    ),
                    CustomText(
                      [
                        HiveUtils.getAreaName(),
                        HiveUtils.getCityName(),
                        HiveUtils.getStateName(),
                        HiveUtils.getCountryName()
                      ]
                              .where((element) =>
                                  element != null && element.isNotEmpty)
                              .join(", ")
                              .isEmpty
                          ? "------"
                          : [
                              HiveUtils.getAreaName(),
                              HiveUtils.getCityName(),
                              HiveUtils.getStateName(),
                              HiveUtils.getCountryName()
                            ]
                              .where((element) =>
                                  element != null && element.isNotEmpty)
                              .join(", "),
                      maxLines: 1,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      color: context.color.textColorDark,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
