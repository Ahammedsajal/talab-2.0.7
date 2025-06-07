
import 'package:Talab/data/model/category_model.dart';
import 'package:Talab/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class SubCategoryFilterScreen extends StatefulWidget {
  final List<CategoryModel> selection;
  final List<CategoryModel> model;

  const SubCategoryFilterScreen(
      {super.key, required this.selection, required this.model});

  @override
  State<SubCategoryFilterScreen> createState() =>
      _SubCategoryFilterScreenState();

  static Route route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => SubCategoryFilterScreen(
        selection: args!["selection"],
        model: args["model"],
      ),
    );
  }
}

class _SubCategoryFilterScreenState extends State<SubCategoryFilterScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    // Responsive parameters
    final paddingHorizontal = isDesktop ? 24.0 : isTablet ? 21.0 : 18.0;
    final paddingVertical = isDesktop ? 24.0 : isTablet ? 21.0 : 18.0;
    final topPadding = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;
    final fontSizeTitle = isDesktop ? 18.0 : isTablet ? 17.0 : context.font.normal;
    final fontSizeItem = isDesktop ? 16.0 : isTablet ? 15.0 : context.font.normal;
    final iconContainerSize = isDesktop ? 48.0 : isTablet ? 44.0 : 40.0;
    final trailingIconSize = isDesktop ? 40.0 : isTablet ? 36.0 : 32.0;
    final dividerThickness = isDesktop ? 1.5 : isTablet ? 1.3 : 1.2;
    final borderRadius = isDesktop ? 24.0 : isTablet ? 22.0 : 20.0;
    final trailingBorderRadius = isDesktop ? 10.0 : isTablet ? 9.0 : 8.0;

    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: "classifieds".translate(context),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: SizedBox(
            width: context.screenWidth,
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Container(
                color: context.color.secondaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: paddingHorizontal, vertical: paddingVertical),
                      child: CustomText(
                        "allInClassified".translate(context),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        color: context.color.textDefaultColor,
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(
                      thickness: dividerThickness,
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: widget.model.length,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) {
                          return Divider(
                            thickness: dividerThickness,
                            height: 10,
                          );
                        },
                        itemBuilder: (context, index) {
                          CategoryModel category = widget.model[index];

                          return ListTile(
                            onTap: () {
                              widget.selection.add(category);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            leading: Container(
                                width: iconContainerSize,
                                height: iconContainerSize,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(borderRadius),
                                    color: context.color.territoryColor
                                        .withValues(alpha: 0.1)),
                                child: UiUtils.imageType(
                                  category.url!,
                                  color: context.color.territoryColor,
                                  fit: BoxFit.cover,
                                  width: isDesktop ? 32.0 : isTablet ? 28.0 : 24.0,
                                  height: isDesktop ? 32.0 : isTablet ? 28.0 : 24.0,
                                )),
                            title: CustomText(
                              category.name!,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              color: context.color.textDefaultColor,
                              fontSize: fontSizeItem,
                            ),
                            trailing: Container(
                                width: trailingIconSize,
                                height: trailingIconSize,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(trailingBorderRadius),
                                    color:
                                        context.color.borderColor.darken(10)),
                                child: Icon(
                                  Icons.chevron_right_outlined,
                                  color: context.color.textDefaultColor,
                                  size: isDesktop ? 24.0 : isTablet ? 22.0 : 20.0,
                                )),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
