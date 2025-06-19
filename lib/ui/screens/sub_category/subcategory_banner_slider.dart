import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/banner_cubit.dart';
import 'package:Talab/data/model/banner_model.dart';
import 'package:Talab/data/model/data_output.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/repositories/item/item_repository.dart';
import 'package:Talab/utils/helper_utils.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/data/helper/widgets.dart';

class SubCategoryBannerSlider extends StatefulWidget {
  final int categoryId;
  const SubCategoryBannerSlider({super.key, required this.categoryId});

  @override
  State<SubCategoryBannerSlider> createState() => _SubCategoryBannerSliderState();
}

class _SubCategoryBannerSliderState extends State<SubCategoryBannerSlider>
    with AutomaticKeepAliveClientMixin {
  late PageController _controller;
  Timer? _timer;
  int _current = 0;

  @override
  bool get wantKeepAlive => true;

  bool _isTablet(BuildContext ctx) => MediaQuery.of(ctx).size.shortestSide >= 600;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.90, initialPage: 0);
    context.read<BannerCubit>().fetchBanners(categoryId: widget.categoryId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoSlide(int count) {
    if (count <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_controller.hasClients) {
        if (_current < count - 1) {
          _controller.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeInOutQuint);
        } else {
          _controller.animateToPage(0, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutQuint);
        }
      }
    });
  }

  double _sliderHeight(BuildContext ctx) {
    final size = MediaQuery.of(ctx).size;
    if (_isTablet(ctx)) return math.min(420, size.height * 0.28);
    return size.height * 0.35;
  }

  double _dotSize(BuildContext ctx) => _isTablet(ctx) ? 10.0 : MediaQuery.of(ctx).size.width * 0.025;

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
            color: i == _current ? Theme.of(context).primaryColor : Colors.grey.shade300,
          ),
        );
      }),
    );
  }

  Future<void> _onBannerTap(BannerModel banner) async {
    final type = banner.linkType;
    final target = banner.linkTarget;
    try {
      if (type == 'custom_url' && target != null) {
        await launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication);
      } else if (type == 'create_ad') {
        Navigator.pushNamed(context, Routes.selectCategoryScreen);
      } else if (type == 'category' && target != null) {
        Navigator.pushNamed(context, Routes.subCategoryScreen, arguments: {
          'categoryList': <dynamic>[],
          'catName': '',
          'catId': int.tryParse(target) ?? 0,
          'categoryIds': [target]
        });
      } else if (type == 'item' && target != null) {
        try {
          Widgets.showLoader(context);
          final repo = ItemRepository();
          final DataOutput<ItemModel> data = await repo.fetchItemFromItemId(int.parse(target));
          Widgets.hideLoder(context);
          Navigator.pushNamed(context, Routes.adDetailsScreen, arguments: {'model': data.modelList.first});
        } catch (e) {
          Widgets.hideLoder(context);
          HelperUtils.showSnackBarMessage(context, e.toString());
        }
      }
    } catch (e) {
      HelperUtils.showSnackBarMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return BlocConsumer<BannerCubit, BannerState>(
      listener: (_, state) {
        if (state is BannerSuccess) _startAutoSlide(state.banners.length);
      },
      builder: (ctx, state) {
        if (state is BannerSuccess && state.banners.isNotEmpty) {
          final banners = state.banners;
          Widget pageView() => PageView.builder(
                controller: _controller,
                clipBehavior: Clip.none,
                itemCount: banners.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (ctx, i) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (ctx, child) {
                      double v = 0;
                      if (_controller.position.haveDimensions) {
                        v = i - (_controller.page ?? 0);
                        v = (v * 0.05).clamp(-1, 1);
                      }
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.002)
                          ..rotateY(math.pi * v * 0.5)
                          ..scale(1 - v.abs() * 0.1),
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () => _onBannerTap(banners[i]),
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
                                  imageUrl: banners[i].image ?? '',
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
              _isTablet(context)
                  ? SizedBox(height: _sliderHeight(context), child: pageView())
                  : AspectRatio(aspectRatio: 16 / 9, child: SizedBox(height: h * 0.35, child: pageView())),
              SizedBox(height: h * 0.025),
              _buildDotIndicator(banners.length),
            ],
          );
        } else if (state is BannerLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const SizedBox.shrink();
      },
    );
  }
}
