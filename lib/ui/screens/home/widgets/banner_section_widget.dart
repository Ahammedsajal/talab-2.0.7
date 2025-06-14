import 'dart:async';
import 'dart:math' as math;

import 'package:Talab/app/routes.dart';
import 'package:Talab/data/helper/widgets.dart';
import 'package:Talab/data/model/category_model.dart';
import 'package:Talab/data/model/data_output.dart';
import 'package:Talab/data/model/home/home_screen_section.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/model/home_slider.dart';
import 'package:Talab/data/repositories/item/item_repository.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/app_icon.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/helper_utils.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerSectionWidget extends StatefulWidget {
  final HomeScreenSection section;

  const BannerSectionWidget({
    Key? key,
    required this.section,
  }) : super(key: key);

  @override
  State<BannerSectionWidget> createState() => _BannerSectionWidgetState();
}

class _BannerSectionWidgetState extends State<BannerSectionWidget>
    with AutomaticKeepAliveClientMixin {
  // -------------------------------------------------------------------------
  late PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  // -------------------------------------------------------------------------
  @override
  bool get wantKeepAlive => true;

  bool _isTablet(BuildContext ctx) => MediaQuery.of(ctx).size.shortestSide >= 600;

  // -------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.90, initialPage: 0);
    _startAutoSlide();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final desiredVp = _isTablet(context) ? 0.60 : 0.90; // peeking carousel on tablets
    if (_pageController.viewportFraction != desiredVp) {
      final old = _currentPage;
      _pageController.dispose();
      _pageController = PageController(viewportFraction: desiredVp, initialPage: old);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  void _startAutoSlide() {
    if (widget.section.banners.length > 1) {
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_pageController.hasClients) {
          if (_currentPage < widget.section.banners.length - 1) {
            _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutQuint);
          } else {
            _pageController.animateToPage(0, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutQuint);
          }
        }
      });
    }
  }

  // -------------------------------------------------------------------------
  double _sliderHeight(BuildContext ctx) {
    final size = MediaQuery.of(ctx).size;
    if (_isTablet(ctx)) {
      return math.min(420, size.height * 0.32);
    }
    return size.height * 0.20; // original 20 % for mobiles
  }

  double _dotSize(BuildContext ctx) =>
      _isTablet(ctx) ? 6.0 : MediaQuery.of(ctx).size.width * 0.025;

  Widget _buildDotIndicator(int total) {
    final dot = _dotSize(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        return Container(
          width: dot,
          height: dot,
          margin: EdgeInsets.symmetric(horizontal: dot * .4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _currentPage ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final banners = widget.section.banners;
    if (banners.isEmpty) return const SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Widget pageViewBuilder() => PageView.builder(
          controller: _pageController,
          itemCount: banners.length,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (i) => setState(() => _currentPage = i),
          itemBuilder: (ctx, idx) {
            return AnimatedBuilder(
              animation: _pageController,
              builder: (ctx, child) {
                double value = 0.0;
                if (_pageController.position.haveDimensions) {
                  value = idx - (_pageController.page ?? 0);
                  value = (value * 0.05).clamp(-1, 1);
                }
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateY(math.pi * value * 0.5)
                    ..scale(1 - value.abs() * 0.1),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => _handleBannerItemTap(context, banners[idx]),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15 + value.abs() * 0.05),
                            blurRadius: screenWidth * 0.03,
                            spreadRadius: screenWidth * 0.005,
                            offset: Offset(0, screenWidth * 0.015),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Transform.translate(
                        offset: Offset(value * 20, 0),
                        child: CachedNetworkImage(
                          imageUrl: banners[idx].image ?? '',
                          fit: BoxFit.contain,
                          placeholder: (ctx, url) => const Center(
                            child: CircularProgressIndicator(color: Colors.white70),
                          ),
                          errorWidget: (ctx, url, err) => Container(
                            color: context.color.primaryColor.withOpacity(0.1),
                            child: Center(
                              child: UiUtils.getSvg(
                                AppIcons.somethingWentWrong,
                                width: 40,
                                height: 40,
                                color: context.color.textDefaultColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );

    return Column(
      children: [
        _isTablet(context)
            ? SizedBox(height: _sliderHeight(context), child: pageViewBuilder())
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: SizedBox(height: screenHeight * 0.20, child: pageViewBuilder()),
              ),
        SizedBox(height: screenHeight * 0.025),
        _buildDotIndicator(widget.section.banners.length),
      ],
    );
  }

  void _handleBannerItemTap(BuildContext ctx, HomeSlider banner) async {
    final modelType = banner.modelType ?? widget.section.modelType;
    final modelId = banner.modelId ??
        widget.section.linkItemId ??
        widget.section.linkCategoryId ??
        widget.section.modelId;

    if (banner.thirdPartyLink != null && banner.thirdPartyLink!.isNotEmpty) {
      await launchUrl(Uri.parse(banner.thirdPartyLink!), mode: LaunchMode.externalApplication);
    } else if (modelType != null && modelType.contains('Category')) {
      if (banner.model?.subCategoriesCount != null && banner.model!.subCategoriesCount! > 0) {
        Navigator.pushNamed(ctx, Routes.subCategoryScreen, arguments: {
          'categoryList': <CategoryModel>[],
          'catName': banner.model!.name,
          'catId': modelId,
          'categoryIds': [banner.model!.parentCategoryId.toString(), modelId.toString()],
        });
      } else {
        Navigator.pushNamed(ctx, Routes.itemsList, arguments: {
          'catID': modelId.toString(),
          'catName': banner.model!.name,
          'categoryIds': [modelId.toString()],
        });
      }
    } else if (modelId != null) {
      try {
        final repo = ItemRepository();
        Widgets.showLoader(ctx);
        final DataOutput<ItemModel> data = await repo.fetchItemFromItemId(modelId!);
        Widgets.hideLoder(ctx);
        Navigator.pushNamed(ctx, Routes.adDetailsScreen, arguments: {'model': data.modelList[0]});
      } catch (e) {
        Widgets.hideLoder(ctx);
        HelperUtils.showSnackBarMessage(ctx, e.toString());
      }
    }
  }
}
