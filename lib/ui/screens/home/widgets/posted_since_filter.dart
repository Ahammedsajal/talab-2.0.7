
import 'package:Talab/ui/screens/filter_screen.dart';
import 'package:Talab/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/custom_text.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class PostedSinceFilterScreen extends StatefulWidget {
  final List<PostedSinceItem> list;
  final String postedSince;
  final Function update;

  const PostedSinceFilterScreen({
    Key? key,
    required this.list,
    required this.postedSince,
    required this.update,
  }) : super(key: key);

  @override
  State<PostedSinceFilterScreen> createState() => _PostedSinceFilterState();

  static Route route(RouteSettings routeSettings) {
    Map? args = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => PostedSinceFilterScreen(
        list: args?['list'],
        postedSince: args?['postedSince'],
        update: args?['update'],
      ),
    );
  }
}

class _PostedSinceFilterState extends State<PostedSinceFilterScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth <= 1200;
    final isDesktop = screenWidth > 1200;

    // Responsive parameters
    final topPadding = isDesktop ? 8.0 : isTablet ? 6.0 : 5.0;
    final fontSize = isDesktop ? 18.0 : isTablet ? 17.0 : context.font.normal;
    final dividerThickness = isDesktop ? 1.5 : isTablet ? 1.3 : 1.2;
    final listPadding = isDesktop ? 16.0 : isTablet ? 12.0 : 0.0;

    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: "postedSinceLbl".translate(context),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Container(
          color: context.color.secondaryColor,
          child: ListView.separated(
            itemCount: widget.list.length,
            padding: EdgeInsets.symmetric(horizontal: listPadding),
            separatorBuilder: (context, index) {
              return Divider(
                thickness: dividerThickness,
                height: 10,
              );
            },
            itemBuilder: (context, index) {
              return ListTile(
                title: CustomText(
                  widget.list[index].status,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  color: context.color.textDefaultColor,
                  fontSize: fontSize,
                  fontWeight: index == 0 ? FontWeight.w600 : FontWeight.w500,
                ),
                onTap: () {
                  widget.update(widget.list[index].value);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
