import 'dart:async';
import 'dart:math' as math;

import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/slider_cubit.dart';
import 'package:Talab/data/helper/widgets.dart';
import 'package:Talab/data/model/category_model.dart';
import 'package:Talab/data/model/data_output.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/repositories/item/item_repository.dart';
import 'package:Talab/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget({Key? key}) : super(key: key);

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget>
    with AutomaticKeepAliveClientMixin {
  // ────────────────── Controller & timers ───────────────────
  late PageController _pageController;
  Timer? _autoSlideTimer;

  // ─────────────────────── State ────────────────────────────
  int _currentPage = 0;

  // ─────────────────── Break‑point helper ───────────────────
  bool isTablet(BuildContext ctx) => MediaQuery.of(ctx).size.shortestSide >= 600;

  // ───────────────────── Lifecycle ──────────────────────────
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Build with the right viewport straight away
   _pageController = PageController(viewportFraction: 0.90, initialPage: 0);
   // _startAutoSlide();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hot‑reload / rotation may cross break‑points
    final double desiredVp = isTablet(context) ? 0.60 : 0.90;
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

  // ───────────────── Layout helpers ─────────────────────────
  double _sliderHeight(BuildContext ctx) {
    final size = MediaQuery.of(ctx).size;
    if (isTablet(ctx)) return math.min(420, size.height * .28);
    return size.height * .35;
  }

  double _dotSize(BuildContext ctx) => isTablet(ctx) ? 10.0 : MediaQuery.of(ctx).size.width * 0.025;

  // ──────────────── Auto‑slide logic ────────────────────────
  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final state = context.read<SliderCubit>().state;
      if (state is SliderFetchSuccess) {
        if (_currentPage < state.sliderlist.length - 1) {
          _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutQuint);
        } else {
          _pageController.animateToPage(0, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutQuint);
        }
      }
    });
  }

  // ─────────────────── Dot indicator ────────────────────────
  Widget _buildDotIndicator(int total, int current) {
    final d = _dotSize(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) => Container(
        width: d,
        height: d,
        margin: EdgeInsets.symmetric(horizontal: d * .4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: i == current ? Theme.of(context).primaryColor : Colors.grey.shade300,
        ),
      )),
    );
  }

  // ─────────────────────── Build ────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return BlocConsumer<SliderCubit, SliderState>(
      listener: (_, s) {},
      builder: (ctx, state) {
        if (state is SliderFetchSuccess && state.sliderlist.isNotEmpty) {
          // Shared builder to avoid duplication
          Widget pageView() => PageView.builder(
                controller: _pageController,
                clipBehavior: Clip.none, // allow peek outside bounds
                itemCount: state.sliderlist.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (ctx, i) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (ctx, child) {
                      double v = 0;
                      if (_pageController.position.haveDimensions) {
                        v = i - (_pageController.page ?? 0);
                        v = (v * 0.05).clamp(-1, 1);
                      }
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002)
                          ..rotateY(math.pi * v * 0.5)
                          ..scale(1 - v.abs() * 0.1),
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () => _handleSliderItemTap(context, state.sliderlist[i]),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: w * 0.015),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(w * 0.05),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15 + v.abs() * 0.05),
                                  blurRadius: w * 0.03,
                                  spreadRadius: w * 0.005,
                                  offset: Offset(0, w * 0.015),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(w * 0.05),
                              child: Transform.translate(
                                offset: Offset(v * 20, 0),
                                child: CachedNetworkImage(
                                  imageUrl: state.sliderlist[i].image ?? "",
                                  fit: BoxFit.contain,
                                  placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: Colors.white70)),
                                  errorWidget: (_, __, ___) => const Icon(Icons.error, color: Colors.redAccent, size: 40),
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
              isTablet(context)
                  ? SizedBox(height: _sliderHeight(context), child: pageView())
                  : AspectRatio(aspectRatio: 16 / 9, child: SizedBox(height: h * 0.35, child: pageView())),
              SizedBox(height: h * 0.025),
              _buildDotIndicator(state.sliderlist.length, _currentPage),
            ],
          );
        } else if (state is SliderFetchInProgress) {
          return const Center(child: CircularProgressIndicator());
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ─────────────── on‑tap navigation logic ──────────────────
  void _handleSliderItemTap(BuildContext ctx, dynamic sliderItem) async {
    if (sliderItem.thirdPartyLink != null && sliderItem.thirdPartyLink!.isNotEmpty) {
      await launchUrl(Uri.parse(sliderItem.thirdPartyLink!), mode: LaunchMode.externalApplication);
    } else if (sliderItem.modelType!.contains("Category")) {
      if (sliderItem.model!.subCategoriesCount! > 0) {
        Navigator.pushNamed(ctx, Routes.subCategoryScreen, arguments: {
          "categoryList": <CategoryModel>[],
          "catName": sliderItem.model!.name,
          "catId": sliderItem.modelId,
          "categoryIds": [sliderItem.model!.parentCategoryId.toString(), sliderItem.modelId.toString()],
        });
      } else {
        Navigator.pushNamed(ctx, Routes.itemsList, arguments: {
          'catID': sliderItem.modelId.toString(),
          'catName': sliderItem.model!.name,
          "categoryIds": [sliderItem.modelId.toString()],
        });
      }
    } else {
      try {
        final repo = ItemRepository();
        Widgets.showLoader(ctx);
        final data = await repo.fetchItemFromItemId(sliderItem.modelId!);
        Widgets.hideLoder(ctx);
        Navigator.pushNamed(ctx, Routes.adDetailsScreen, arguments: {"model": data.modelList[0]});
      } catch (e) {
        Widgets.hideLoder(ctx);
        HelperUtils.showSnackBarMessage(ctx, e.toString());
      }
    }
  }
}
