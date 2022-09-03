// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';

import 'package:applovin_max/applovin_max.dart';
import 'package:applovin_max/src/ad_classes.dart' show MaxAd, MaxError;
import 'package:flutter/widgets.dart';

import 'applovin_const.dart';

class AppLovin {
  static AppLovin? _instance;

  factory AppLovin() {
    return _instance ??= AppLovin._(
      AppLovinConst.sdkKey,
      nativeUnitKey: AppLovinConst.nativeUnitId,
      bannerUnitKey: AppLovinConst.bannerUnitId,
      interstitialUnitKey: AppLovinConst.interstitialUnitId,
    );
  }

  AppLovin._(
    this.sdkKey, {
    this.nativeUnitKey,
    this.bannerUnitKey,
    this.interstitialUnitKey,
  });

  final String sdkKey;
  final String? nativeUnitKey;
  final String? interstitialUnitKey;
  final String? bannerUnitKey;
  Map<dynamic, dynamic>? _config;
  Map<dynamic, dynamic>? get config => _config!;
  bool get initialized => _config != null;
  VoidCallback? _onDone;

  Future<Map<dynamic, dynamic>?> initialize() async {
    return _config = await AppLovinMAX.initialize(sdkKey);
  }

  var _interstitialRetryAttempt = 0;

  void initializeInterstitialAds({
    FutureOr<void> Function(MaxAd ad)? onAdDisplayedCallback,
    FutureOr<void> Function(MaxAd ad, MaxError err)? onAdDisplayFailedCallback,
    FutureOr<void> Function(MaxAd ad)? onAdClickedCallback,
    FutureOr<void> Function(MaxAd ad)? onAdHiddenCallback,
    FutureOr<void> Function(MaxAd ad)? onAdLoadedCallback,
    FutureOr<void> Function(String unitId, MaxError err)? onAdLoadFailedCallback,
  }) {
    if (interstitialUnitKey == null) {
      return;
    }

    final key = interstitialUnitKey!;

    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        // Interstitial ad is ready to be shown. AppLovinMAX.isInterstitialReady(_interstitial_ad_unit_id) will now return 'true'
        print('Interstitial ad loaded from ${ad.networkName}');

        // Reset retry attempt
        _interstitialRetryAttempt = 0;

        onAdLoadedCallback?.call(ad);
      },
      onAdLoadFailedCallback: (adUnitId, error) async {
        // Interstitial ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        _interstitialRetryAttempt = _interstitialRetryAttempt + 1;

        int retryDelay = pow(2, min(6, _interstitialRetryAttempt)).toInt();

        print('Interstitial ad failed to load with code ${error.code} - retrying in ${retryDelay}s');

        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          AppLovinMAX.loadInterstitial(key);
        });

        await onAdLoadFailedCallback?.call(adUnitId, error);
      },
      onAdDisplayedCallback: (ad) async {
        await onAdDisplayedCallback?.call(ad);
      },
      onAdDisplayFailedCallback: (ad, error) async {
        await onAdDisplayFailedCallback?.call(ad, error);
        _callOnDone();
      },
      onAdClickedCallback: (ad) async {
        await onAdClickedCallback?.call(ad);
      },
      onAdHiddenCallback: (ad) async {
        await onAdHiddenCallback?.call(ad);
        _callOnDone();
      },
    ));

    // Load the first interstitial
    AppLovinMAX.loadInterstitial(key);
  }

  void showInterstitial([VoidCallback? onDone]) {
    _onDone = onDone;

    if (interstitialUnitKey == null) {
      _callOnDone();
      return;
    }

    final key = interstitialUnitKey!;

    AppLovinMAX.isInterstitialReady(key).then((initialized) {
      if (initialized ?? false) {
        AppLovinMAX.showInterstitial(key);
      } else {
        _callOnDone();
      }
    });
  }

  void _callOnDone() {
    if (_onDone != null) {
      _onDone?.call();
      _onDone = null;
    }
  }

  // Banner functions
  void initializeBanner() {
    if (bannerUnitKey == null) return;

    final key = bannerUnitKey!;

    AppLovinMAX.createBanner(key, AdViewPosition.bottomCenter);
  }

  void showBanner() {
    if (bannerUnitKey == null) return;

    AppLovinMAX.showBanner(bannerUnitKey!);
  }

  void hideBanner() {
    if (bannerUnitKey == null) return;

    AppLovinMAX.hideBanner(bannerUnitKey!);
  }
}
