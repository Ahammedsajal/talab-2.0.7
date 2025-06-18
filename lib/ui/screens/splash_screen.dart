import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:Talab/app/routes.dart';
import 'package:Talab/data/cubits/system/fetch_language_cubit.dart';
import 'package:Talab/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:Talab/data/cubits/system/language_cubit.dart';
import 'package:Talab/data/cubits/favorite/favorite_cubit.dart';
import 'package:Talab/data/cubits/chat/blocked_users_list_cubit.dart';
import 'package:Talab/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:Talab/data/cubits/slider_cubit.dart';
import 'package:Talab/data/cubits/category/fetch_category_cubit.dart';
import 'package:Talab/data/cubits/home/fetch_home_all_items_cubit.dart';
import 'package:Talab/data/cubits/home/fetch_home_screen_cubit.dart';
import 'package:Talab/data/model/system_settings_model.dart';
import 'package:Talab/ui/screens/widgets/errors/no_internet.dart';
import 'package:Talab/utils/constant.dart';
import 'package:Talab/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({this.itemSlug, super.key});
  final String? itemSlug;

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool isTimerCompleted = false;
  bool isSettingsLoaded = false;
  bool isLanguageLoaded = false;
  bool isHomeDataLoaded = false;
  bool _startedHomeFetch = false;
  late StreamSubscription<List<ConnectivityResult>> subscription;
  bool hasInternet = true;

  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _hasNavigated = false; // Prevents double navigation

  @override
  void initState() {
    super.initState();

    // Initialize the video player controller
    _videoController = VideoPlayerController.asset('assets/splash_video/splash_video_talab.mp4')
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _videoController.play(); // Auto-play the video
        _videoController.setLooping(false); // No loop, play once
      }).catchError((error) {
        log("Error initializing video: $error");
        setState(() {
          _isVideoInitialized = false;
        });
      });

    // When the video ends, mark timer as completed (so you don't wait forever if logic is done)
    _videoController.addListener(() {
      if (_videoController.value.position >= _videoController.value.duration - const Duration(milliseconds: 200) &&
          _videoController.value.isInitialized &&
          !_hasNavigated) {
        isTimerCompleted = true;
        if (mounted) setState(() {});
        navigateCheck();
      }
    });

    // Connectivity logic
    subscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        hasInternet = (!result.contains(ConnectivityResult.none));
      });
      if (hasInternet) {
        context.read<FetchSystemSettingsCubit>().fetchSettings(forceRefresh: true);
        startTimer();
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    _videoController.dispose();
    super.dispose();
  }

  Future getDefaultLanguage(String code) async {
    try {
      if (HiveUtils.getLanguage() == null || HiveUtils.getLanguage()?['data'] == null) {
        context.read<FetchLanguageCubit>().getLanguage(code);
      } else if (HiveUtils.isUserFirstTime() == true && code != HiveUtils.getLanguage()?['code']) {
        context.read<FetchLanguageCubit>().getLanguage(code);
      } else {
        isLanguageLoaded = true;
        setState(() {});
        navigateCheck();
      }
    } catch (e) {
      log("Error while loading default language $e");
    }
  }

  void startHomeDataFetch() {
    if (_startedHomeFetch) return;
    _startedHomeFetch = true;
    // Prefetch home screen related data
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
  }

  bool _checkHomeDataLoaded() {
    final sliderLoaded = context.read<SliderCubit>().state is SliderFetchSuccess ||
        context.read<SliderCubit>().state is SliderFetchFailure;
    final categoryLoaded =
        context.read<FetchCategoryCubit>().state is FetchCategorySuccess ||
            context.read<FetchCategoryCubit>().state is FetchCategoryFailure;
    final homeScreenLoaded =
        context.read<FetchHomeScreenCubit>().state is FetchHomeScreenSuccess ||
            context.read<FetchHomeScreenCubit>().state is FetchHomeScreenFail;
    final homeItemsLoaded = context.read<FetchHomeAllItemsCubit>().state is FetchHomeAllItemsSuccess ||
        context.read<FetchHomeAllItemsCubit>().state is FetchHomeAllItemsFail;

    return sliderLoaded && categoryLoaded && homeScreenLoaded && homeItemsLoaded;
  }

  Future<void> startTimer() async {
    // Minimum display time for splash, or can be tied to video
    Timer(const Duration(milliseconds: 500), () {
      isTimerCompleted = true;
      if (mounted) setState(() {});
      navigateCheck();
    });
  }

  void navigateCheck() {
    if (_hasNavigated) return;
    // Only navigate when all are true and video finished
    if (isTimerCompleted && isSettingsLoaded && isLanguageLoaded && isHomeDataLoaded) {
      _hasNavigated = true;
      navigateToScreen();
    }
  }

  void navigateToScreen() async {
    if (context.read<FetchSystemSettingsCubit>().getSetting(SystemSetting.maintenanceMode) == "1") {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.maintenanceMode);
        }
      });
    } else if (HiveUtils.isUserFirstTime() == true) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.onboarding);
        }
      });
    } else if (HiveUtils.isUserAuthenticated()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.main, arguments: {'from': "main", "slug": widget.itemSlug});
        }
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          if (HiveUtils.isUserSkip() == true) {
            Navigator.of(context).pushReplacementNamed(Routes.main, arguments: {'from': "main"});
          } else {
            Navigator.of(context).pushReplacementNamed(Routes.login);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    navigateCheck();
    return hasInternet
        ? MultiBlocListener(
            listeners: [
              BlocListener<FetchLanguageCubit, FetchLanguageState>(
                listener: (context, state) {
                  if (state is FetchLanguageSuccess) {
                    Map<String, dynamic> map = state.toMap();
                    var data = map['file_name'];
                    map['data'] = data;
                    map.remove("file_name");
                    HiveUtils.storeLanguage(map);
                    context.read<LanguageCubit>().changeLanguages(map);
                    isLanguageLoaded = true;
                    setState(() {});
                    navigateCheck();
                  }
                },
              ),
              BlocListener<FetchSystemSettingsCubit, FetchSystemSettingsState>(
                listener: (context, state) {
                  if (state is FetchSystemSettingsSuccess) {
                    Constant.isDemoModeOn = context.read<FetchSystemSettingsCubit>().getSetting(SystemSetting.demoMode);
                    getDefaultLanguage(state.settings['data']['default_language']);
                    isSettingsLoaded = true;
                    setState(() {});
                    navigateCheck();
                    startHomeDataFetch();
                  }
                },
              ),
              BlocListener<SliderCubit, SliderState>(
                listener: (context, state) {
                  if (state is SliderFetchSuccess || state is SliderFetchFailure) {
                    isHomeDataLoaded = _checkHomeDataLoaded();
                    navigateCheck();
                  }
                },
              ),
              BlocListener<FetchCategoryCubit, FetchCategoryState>(
                listener: (context, state) {
                  if (state is FetchCategorySuccess || state is FetchCategoryFailure) {
                    isHomeDataLoaded = _checkHomeDataLoaded();
                    navigateCheck();
                  }
                },
              ),
              BlocListener<FetchHomeScreenCubit, FetchHomeScreenState>(
                listener: (context, state) {
                  if (state is FetchHomeScreenSuccess || state is FetchHomeScreenFail) {
                    isHomeDataLoaded = _checkHomeDataLoaded();
                    navigateCheck();
                  }
                },
              ),
              BlocListener<FetchHomeAllItemsCubit, FetchHomeAllItemsState>(
                listener: (context, state) {
                  if (state is FetchHomeAllItemsSuccess || state is FetchHomeAllItemsFail) {
                    isHomeDataLoaded = _checkHomeDataLoaded();
                    navigateCheck();
                  }
                },
              ),
            ],
            child: AnnotatedRegion(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.black,
              ),
              child: Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: _isVideoInitialized
                      ? SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _videoController.value.size.width,
                              height: _videoController.value.size.height,
                              child: VideoPlayer(_videoController),
                            ),
                          ),
                        )
                      : Container(),
                ),
              ),
            ),
          )
        : NoInternet(
            onRetry: () {
              setState(() {});
            },
          );
  }
}