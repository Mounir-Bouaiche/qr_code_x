import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:qr_code_x/ads/applovin_const.dart';
import 'package:qr_code_x/ads/applovin_init.dart';
import 'package:qr_code_x/core/text_launcher.dart';
import 'package:qr_code_x/main.dart';
import 'package:share_plus/share_plus.dart';

class ResultPage extends StatefulWidget {
  const ResultPage(this.result, {super.key});

  final Result result;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final AppLovinProvider? _appLovinProvider;
  late final TextLauncher _textLauncher;
  final _launchTestResultCompleter = Completer<TestResult>();

  @override
  void initState() {
    super.initState();
    AppLovin().initializeInterstitialAds();
    _textLauncher = TextLauncher(text);

    _textLauncher.canLaunch(context).then(_launchTestResultCompleter.complete);

    _launch(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appLovinProvider = AppLovinProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        centerTitle: true,
        toolbarHeight: 90,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18.0),
              child: Text(result.text),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text)).then((value) {
                      AppLovin().showInterstitial(() {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Text saved to clipboard successfully')),
                        );
                      });
                    });
                  },
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: const StadiumBorder(),
                  height: 48,
                  minWidth: 48,
                  padding: const EdgeInsets.all(24),
                  child: const Icon(Icons.copy),
                ),
                FutureBuilder<TestResult>(
                  future: _launchTestResultCompleter.future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && (snapshot.data?.canLaunch ?? false)) {
                      return MaterialButton(
                        onPressed: () => _textLauncher.launch(snapshot.requireData),
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        shape: const StadiumBorder(),
                        height: 48,
                        minWidth: 48,
                        padding: const EdgeInsets.all(24),
                        child: const Icon(Icons.open_in_new_rounded),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
                MaterialButton(
                  onPressed: () => Share.share(text),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  shape: const StadiumBorder(),
                  height: 48,
                  minWidth: 48,
                  padding: const EdgeInsets.all(24),
                  child: const Icon(Icons.share),
                ),
              ],
            ),
          ),
          const MaxAdView(
            adUnitId: AppLovinConst.bannerUnitId,
            adFormat: AdFormat.banner,
          ),
        ],
      ),
    );
  }

  void _launch([bool withMessage = false]) {
    _launchTestResultCompleter.future.then((value) {
      if (value.canLaunch) {
        _textLauncher.launch(value);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot launch this result')),
        );
      }
    });
  }

  Result get result => widget.result;
  String get text => result.text;
}
