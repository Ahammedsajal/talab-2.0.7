// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';
import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/favorite/manage_fav_cubit.dart';
import 'package:Talab/ui/screens/settings/contact_us.dart';
import 'package:Talab/utils/app_icon.dart';

import 'package:Talab/data/cubits/category/fetch_category_cubit.dart';
import 'package:Talab/data/cubits/chat/blocked_users_list_cubit.dart';
import 'package:Talab/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:Talab/data/cubits/favorite/favorite_cubit.dart';
import 'package:Talab/data/cubits/home/fetch_home_all_items_cubit.dart';
import 'package:Talab/data/cubits/home/fetch_home_screen_cubit.dart';
import 'package:Talab/data/cubits/slider_cubit.dart';
import 'package:Talab/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:Talab/data/cubits/system/fetch_language_cubit.dart';
import 'package:Talab/data/cubits/system/language_cubit.dart';
import 'package:Talab/data/helper/designs.dart';
import 'package:Talab/data/helper/widgets.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/model/system_settings_model.dart';
import 'package:Talab/ui/screens/ad_banner_screen.dart';
import 'package:Talab/ui/screens/home/slider_widget.dart';
import 'package:Talab/ui/screens/home/widgets/category_widget_home.dart';
import 'package:Talab/ui/screens/home/widgets/home_search.dart';
import 'package:Talab/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:Talab/ui/screens/home/widgets/section_header.dart';
import 'package:Talab/ui/screens/home/widgets/home_shimmers.dart';
import 'package:Talab/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:Talab/ui/theme/theme.dart';
import 'package:Talab/utils/constant.dart';
import 'package:Talab/utils/extensions/extensions.dart';
import 'package:Talab/utils/extensions/lib/currency_formatter.dart';
import 'package:Talab/utils/hive_utils.dart';
import 'package:Talab/utils/notification/awsome_notification.dart';
import 'package:Talab/utils/notification/notification_service.dart';
import 'package:Talab/utils/ui_utils.dart';
import 'package:Talab/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';

const double sidePadding = 10;

class HomeScreen extends StatefulWidget {
  final String? from;

  const HomeScreen({super.key, this.from});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;

  List<ItemModel> itemLocalList = [];

  bool isCategoryEmpty = false;

  late final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    initializeSettings();
    addPageScrollListener();
    notificationPermissionChecker();
    LocalAwesomeNotification().init(context);
    NotificationService.init(context);
    if (context.read<SliderCubit>().state is! SliderFetchSuccess) {
      context.read<SliderCubit>().fetchSlider(context);
    }
    if (context.read<FetchCategoryCubit>().state is! FetchCategorySuccess) {
      context.read<FetchCategoryCubit>().fetchCategories();
    }
    if (context.read<FetchHomeScreenCubit>().state is! FetchHomeScreenSuccess) {
      context.read<FetchHomeScreenCubit>().fetch(
          city: HiveUtils.getCityName(),
          areaId: HiveUtils.getAreaId(),
          country: HiveUtils.getCountryName(),
          state: HiveUtils.getStateName(),
        );
    }
    if (context.read<FetchHomeAllItemsCubit>().state is! FetchHomeAllItemsSuccess) {
      context.read<FetchHomeAllItemsCubit>().fetch(
          city: HiveUtils.getCityName(),
          areaId: HiveUtils.getAreaId(),
          radius: HiveUtils.getNearbyRadius(),
          longitude: HiveUtils.getLongitude(),
          latitude: HiveUtils.getLatitude(),
          country: HiveUtils.getCountryName(),
          state: HiveUtils.getStateName(),
        );
    }

    if (HiveUtils.isUserAuthenticated()) {
      context.read<FavoriteCubit>().getFavorite();
      context.read<GetBuyerChatListCubit>().fetch();
      context.read<BlockedUsersListCubit>().blockedUsersList();
    }

    _scrollController.addListener(() {
      if (_scrollController.isEndReached()) {
        if (context.read<FetchHomeAllItemsCubit>().hasMoreData()) {
          context.read<FetchHomeAllItemsCubit>().fetchMore(
                city: HiveUtils.getCityName(),
                areaId: HiveUtils.getAreaId(),
                radius: HiveUtils.getNearbyRadius(),
                longitude: HiveUtils.getLongitude(),
                latitude: HiveUtils.getLatitude(),
                country: HiveUtils.getCountryName(),
                stateName: HiveUtils.getStateName(),
              );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void initializeSettings() {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn =
          settingsCubit.getSetting(SystemSetting.demoMode) ?? false;
    }
  }

  void addPageScrollListener() {
    // Placeholder for future scroll listener logic if needed
  }

  Widget _iconButton({
    required String asset,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      height: 36,
      width: 36,
      alignment: AlignmentDirectional.centerEnd,
     
      child: InkWell(
        onTap: onTap,
        child: SvgPicture.asset(
          asset,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(
            color ?? context.color.territoryColor,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _languageToggle() {
    String currentLang = 'en';
    var langState = context.watch<LanguageCubit>().state;
    if (langState is LanguageLoader) {
      currentLang = langState.language['code'];
    }

    Widget buildButton(String code, String flag) {
      bool selected = currentLang == code;
      return InkWell(
        onTap: () {
          if (!selected) {
            context.read<FetchLanguageCubit>().getLanguage(code);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? context.color.territoryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(code.toUpperCase(),
                  style: TextStyle(
                      color: selected
                          ? context.color.buttonColor
                          : context.color.textDefaultColor)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: context.color.borderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          buildButton('en', '🇺🇸'),
          buildButton('ar', '🇶🇦'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: BlocListener<FetchLanguageCubit, FetchLanguageState>(
        listener: (context, state) {
          if (state is FetchLanguageInProgress) {
            Widgets.showLoader(context);
          }
          if (state is FetchLanguageSuccess) {
            Widgets.hideLoder(context);
            Map<String, dynamic> map = state.toMap();
            var data = map['file_name'];
            map['data'] = data;
            map.remove('file_name');
            HiveUtils.storeLanguage(map);
            context.read<LanguageCubit>().changeLanguages(map);
            context.read<FetchCategoryCubit>().fetchCategories();
          }
          if (state is FetchLanguageFailure) {
            Widgets.hideLoder(context);
          }
        },
        child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize:
                Size.fromHeight(HomeSearchField.preferredHeight(context)),
            child: const HomeSearchField(),
          ),
          actions: [
            _iconButton(
              asset: AppIcons.notification,
              onTap: () {
                UiUtils.checkUser(
                  onNotGuest: () {
                    Navigator.pushNamed(context, Routes.notificationPage);
                  },
                  context: context,
                );
              },
              color: context.color.textDefaultColor,
            ),
            const SizedBox(width: 10),
            _iconButton(
              asset: AppIcons.favorites,
              onTap: () {
                UiUtils.checkUser(
                  onNotGuest: () {
                    Navigator.pushNamed(context, Routes.favoritesScreen);
                  },
                  context: context,
                );
              },
              color: context.color.textDefaultColor,
            ),
            const SizedBox(width: 10),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  ContactUs.route(const RouteSettings(name: '/contact-us')),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: context.color.textDefaultColor,
              ),
              label: const Text('Customer Support'),
              icon: const Icon(Icons.headset_mic_outlined),
            ),
            const SizedBox(width: 10),
            _languageToggle(),
          ],
        ),
        backgroundColor: context.color.primaryColor,
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: context.color.territoryColor,
          onRefresh: () async {
            context.read<SliderCubit>().fetchSlider(context);
            context.read<FetchCategoryCubit>().fetchCategories();
            context.read<FetchHomeScreenCubit>().fetch(
                  city: HiveUtils.getCityName(),
                  areaId: HiveUtils.getAreaId(),
                  country: HiveUtils.getCountryName(),
                  state: HiveUtils.getStateName(),
                );
            context.read<FetchHomeAllItemsCubit>().fetch(
                  city: HiveUtils.getCityName(),
                  areaId: HiveUtils.getAreaId(),
                  radius: HiveUtils.getNearbyRadius(),
                  longitude: HiveUtils.getLongitude(),
                  latitude: HiveUtils.getLatitude(),
                  country: HiveUtils.getCountryName(),
                  state: HiveUtils.getStateName(),
                );
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            controller: _scrollController,
            child: Column(
              children: [
                BlocBuilder<FetchHomeScreenCubit, FetchHomeScreenState>(
                  builder: (context, state) {
                    if (state is FetchHomeScreenInProgress) {
                      return shimmerEffect();
                    }
                    if (state is FetchHomeScreenSuccess) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SliderWidget(),
                          const CategoryWidgetHome(),
                          const SectionHeader(
                            title: 'New This Week',
                            buttonText: '',
                            onTap: null,
                            centerTitle: true,
                            icon: const Text('✨', style: TextStyle(fontSize: 20)),
                          ),
                          ...state.sections.map((section) => HomeSectionsAdapter(
                                section: section,
                              )).toList(),
                          if (state.sections.isNotEmpty &&
                              Constant.isGoogleBannerAdsEnabled == "1")
                            Container(
                              padding: EdgeInsets.only(top: 5),
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: AdBannerWidget(),
                            )
                          else
                            SizedBox(height: 10),
                        ],
                      );
                    }
                    if (state is FetchHomeScreenFail) {
                      return Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            UiUtils.getSvg(
                              AppIcons.somethingWentWrong,
                              width: 80,
                              height: 80,
                            ),
                            SizedBox(height: 16),
                            Text(
                              (state.error is ApiException &&
                                      (state.error as ApiException)
                                              .errorMessage ==
                                          "no-internet") ||
                                      state.error
                                          .toString()
                                          .contains("internet")
                                  ? "noInternet".translate(context)
                                  : "errorLoadingSections".translate(context),
                              style: TextStyle(
                                fontSize: context.font.large,
                                color: context.color.textDefaultColor,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<FetchHomeScreenCubit>().fetch(
                                      city: HiveUtils.getCityName(),
                                      areaId: HiveUtils.getAreaId(),
                                      country: HiveUtils.getCountryName(),
                                      state: HiveUtils.getStateName(),
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: context.color.secondaryColor,
                                backgroundColor: context.color.territoryColor,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "retry".translate(context),
                                style: TextStyle(
                                  fontSize: context.font.normal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget shimmerEffect() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: defaultPadding,
        ),
        child: Column(
          children: [
            ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: CustomShimmer(height: 52, width: double.maxFinite),
            ),
            SizedBox(height: 12),
            ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: CustomShimmer(height: 170, width: double.maxFinite),
            ),
            SizedBox(height: 12),
            Container(
              height: 100,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 10,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8.0),
                    child: const Column(
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CustomShimmer(
                            height: 70,
                            width: 66,
                          ),
                        ),
                        SizedBox(height: 5),
                        CustomShimmer(
                          height: 10,
                          width: 48,
                        ),
                        SizedBox(height: 2),
                        CustomShimmer(
                          height: 10,
                          width: 60,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomShimmer(
                  height: 20,
                  width: 150,
                ),
              ],
            ),
            Container(
              height: 214,
              margin: EdgeInsets.only(top: 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 10.0),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CustomShimmer(
                            height: 147,
                            width: 250,
                          ),
                        ),
                        SizedBox(height: 8),
                        CustomShimmer(
                          height: 15,
                          width: 90,
                        ),
                        SizedBox(height: 8),
                        CustomShimmer(
                          height: 14,
                          width: 230,
                        ),
                        SizedBox(height: 8),
                        CustomShimmer(
                          height: 14,
                          width: 200,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: 16,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: CustomShimmer(
                          height: 147,
                        ),
                      ),
                      SizedBox(height: 8),
                      CustomShimmer(
                        height: 15,
                        width: 70,
                      ),
                      SizedBox(height: 8),
                      CustomShimmer(
                        height: 14,
                      ),
                      SizedBox(height: 8),
                      CustomShimmer(
                        height: 14,
                        width: 130,
                      ),
                    ],
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 215,
                  crossAxisCount: 2,
                  mainAxisSpacing: 15.0,
                  crossAxisSpacing: 15.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sliderWidget() {
    return BlocConsumer<SliderCubit, SliderState>(
      listener: (context, state) {
        if (state is SliderFetchSuccess) {
          setState(() {});
        }
      },
      builder: (context, state) {
        log('State is  $state');
        if (state is SliderFetchInProgress) {
          return const SliderShimmer();
        }
        if (state is SliderFetchFailure) {
          return Container();
        }
        if (state is SliderFetchSuccess) {
          if (state.sliderlist.isNotEmpty) {
            return const SliderWidget();
          }
        }
        return Container();
      },
    );
  }
}





Future<void> notificationPermissionChecker() async {
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.request();
  }
}
