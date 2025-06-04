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
import 'package:Talab/data/helper/designs.dart';
import 'package:Talab/data/model/item/item_model.dart';
import 'package:Talab/data/model/system_settings_model.dart';
import 'package:Talab/ui/screens/ad_banner_screen.dart';
import 'package:Talab/ui/screens/home/slider_widget.dart';
import 'package:Talab/ui/screens/home/widgets/category_widget_home.dart';
import 'package:Talab/ui/screens/home/widgets/home_search.dart';
import 'package:Talab/ui/screens/home/widgets/home_sections_adapter.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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
    // Placeholder for future scroll listener logic if needed
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
           TextButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      ContactUs.route(RouteSettings(name: '/contact-us')),
    );
  },
  label: Text('Customer Support', style: TextStyle(color: Colors.black)),
  icon: Icon(Icons.headset_mic_outlined, color: Colors.black),
  
),


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
                          const HomeSearchField(),
                          const SliderWidget(),
                          const CategoryWidgetHome(),
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
                              state.error.contains("internet")
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
                const AllItemsWidget(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
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

/*
class AllItemsWidget extends StatelessWidget {
  const AllItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          "All Items",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      BlocBuilder<FetchHomeAllItemsCubit, FetchHomeAllItemsState>(
        builder: (context, state) {
          if (state is FetchHomeAllItemsSuccess) {
            if (state.items.isNotEmpty) {
              return Column(
                children: [
                  GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 3
                          : 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      return ItemCard(item: state.items[index]);
                    },
                  ),
                  if (state.isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              );
            } else {
              return Center(child: Text("No items available"));
            }
          }
          if (state is FetchHomeAllItemsFail) {
            return Center(child: Text("Something went wrong"));
          }
          return Center(child: CircularProgressIndicator());
        },
      )
    ]);
  }
}

*/
class AllItemsWidget extends StatelessWidget {
  const AllItemsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final crossCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;
    const spacing  = 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            "All Items",
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        // Grid
        BlocBuilder<FetchHomeAllItemsCubit, FetchHomeAllItemsState>(
          builder: (context, state) {
            if (state is FetchHomeAllItemsSuccess) {
              final items = state.items;
              if (items.isEmpty && !state.isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("No items available")),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 0.75,
                ),
                itemCount: items.length,
                itemBuilder: (ctx, i) => _ItemGridCard(item: items[i]),
              );
            }

            if (state is FetchHomeAllItemsFail) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text("Something went wrong")),
              );
            }

            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),

        // Load more spinner
        BlocBuilder<FetchHomeAllItemsCubit, FetchHomeAllItemsState>(
          builder: (context, state) {
            if (state is FetchHomeAllItemsSuccess && state.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}

class _ItemGridCard extends StatelessWidget {
  final ItemModel item;
  const _ItemGridCard({ Key? key, required this.item }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        Routes.adDetailsScreen,
        arguments: {"model": item},
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE + FAVORITE OVERLAY
            Expanded(
              child: Stack(
                children: [
                  UiUtils.getImage(
                    item.image ?? "",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  // favorite icon
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocBuilder<FavoriteCubit, FavoriteState>(
                      builder: (context, favState) {
                        final isFav = context
                            .read<FavoriteCubit>()
                            .isItemFavorite(item.id!);
                        return BlocConsumer<UpdateFavoriteCubit,
                            UpdateFavoriteState>(
                          listener: (context, upd) {
                            if (upd is UpdateFavoriteSuccess) {
                              if (upd.wasProcess) {
                                context
                                    .read<FavoriteCubit>()
                                    .addFavoriteitem(upd.item);
                              } else {
                                context
                                    .read<FavoriteCubit>()
                                    .removeFavoriteItem(upd.item);
                              }
                            }
                          },
                          builder: (context, updState) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav
                                      ? Colors.redAccent
                                      : Colors.grey[700],
                                ),
                                onPressed: () {
                                  context
                                      .read<UpdateFavoriteCubit>()
                                      .setFavoriteItem(
                                        item: item,
                                        type: isFav ? 0 : 1,
                                      );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // TITLE & PRICE
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (item.price ?? 0.0).currencyFormat,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Future<void> notificationPermissionChecker() async {
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.request();
  }
}