import 'dart:async';
import 'dart:developer';
import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/system/fetch_language_cubit.dart';
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
import 'package:Talab/data/cubits/system/language_cubit.dart';
import 'package:Talab/data/helper/designs.dart';
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
import 'package:Talab/utils/custom_text.dart';
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
const Color bottomBarThemeColor = Color(0xFF26A69A); // Teal color from the image

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
  bool _isEnglish = true; // Local state to track toggle

  @override
  void initState() {
    super.initState();
    initializeSettings();
    addPageScrollListener();
    notificationPermissionChecker();
    LocalAwesomeNotification().init(context);
    NotificationService.init(context);
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
  }

  Widget _iconButton({
    required String asset,
    required VoidCallback onTap,
    Color? color = bottomBarThemeColor, // Default to bottom bar theme color
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

  // Enhanced Language Toggle Widget
  Widget _buildLanguageToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 36,
      width: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: bottomBarThemeColor.withOpacity(0.1),
        border: Border.all(
          color: bottomBarThemeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _toggleLanguage,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: bottomBarThemeColor,
                  ),
                  child: Text(
                    _isEnglish ? '🇺🇸' : '🇶🇦',
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: bottomBarThemeColor,
                  ),
                  child: Text(
                    _isEnglish ? 'EN' : 'ع',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleLanguage() async {
    final languageCubit = context.read<FetchLanguageCubit>();
    
    // Add haptic feedback for better UX
    try {
      // Show loading state with a subtle animation
      setState(() {
        _isEnglish = !_isEnglish;
      });
      
      // Perform the language change
      await languageCubit.getLanguage(_isEnglish ? 'en' : 'ar');
      
      // Optional: Show a brief success indicator
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEnglish ? 'Language changed to English' : 'تم تغيير اللغة إلى العربية',
              style: const TextStyle(fontSize: 14),
            ),
            duration: const Duration(milliseconds: 1500),
            backgroundColor: bottomBarThemeColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      
      // Update the app locale if needed (e.g., via MaterialApp or UiUtils)
      // Example: UiUtils.updateLocale(context, _isEnglish ? 'en_US' : 'ar_QA');
    } catch (e) {
      log(e.toString(), name: 'Toggle Language Error');
      // Revert the change on error
      if (mounted) {
        setState(() {
          _isEnglish = !_isEnglish; // Revert on error
        });
        
        // Show error message
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to change language. Please try again.'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<FetchLanguageCubit, FetchLanguageState>(
      builder: (context, languageState) {
        if (languageState is FetchLanguageSuccess) {
          _isEnglish = !languageState.rtl; // Sync with rtl flag
        }
        return BlocBuilder<FetchHomeScreenCubit, FetchHomeScreenState>(
          builder: (context, homeState) {
            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        ContactUs.route(const RouteSettings(name: '/contact-us')),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: bottomBarThemeColor,
                      padding: const EdgeInsets.all(8.0),
                    ),
                    label: CustomText(
                      '',
                      fontSize: context.font.small,
                      fontWeight: FontWeight.w500,
                      color: bottomBarThemeColor,
                    ),
                    icon: const Icon(Icons.headset_mic_outlined, size: 20, color: bottomBarThemeColor),
                  ),
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
                    ),
                    const SizedBox(width: 10),
                    // Enhanced Language Toggle
                    _buildLanguageToggle(),
                    const SizedBox(width: 15),
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
                                    icon: Text('✨', style: TextStyle(fontSize: 20)),
                                  ),
                                  ...state.sections.map((section) => HomeSectionsAdapter(
                                        section: section,
                                      )).toList(),
                                  if (state.sections.isNotEmpty &&
                                      Constant.isGoogleBannerAdsEnabled == "1")
                                    Container(
                                      padding: const EdgeInsets.only(top: 5),
                                      margin: const EdgeInsets.symmetric(vertical: 10),
                                      child:  AdBannerWidget(),
                                    )
                                  else
                                    const SizedBox(height: 10),
                                ],
                              );
                            }
                            if (state is FetchHomeScreenFail) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    UiUtils.getSvg(
                                      AppIcons.somethingWentWrong,
                                      width: 80,
                                      height: 80,
                                    ),
                                    const SizedBox(height: 16),
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
                                    const SizedBox(height: 16),
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
                                        padding: const EdgeInsets.symmetric(
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
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: const CustomShimmer(height: 52, width: double.maxFinite),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: const CustomShimmer(height: 170, width: double.maxFinite),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 10,
                physics: const NeverScrollableScrollPhysics(),
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
            const SizedBox(height: 18),
            const Row(
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
              margin: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                physics: const NeverScrollableScrollPhysics(),
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
              padding: const EdgeInsets.only(top: 20),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: 16,
                physics: const NeverScrollableScrollPhysics(),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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