import 'package:flutter/material.dart';

import 'ads/applovin_init.dart';
import 'pages/home_page.dart';

class AppLovinProvider extends InheritedWidget {
  AppLovinProvider(
    this.appLovin, {
    super.key,
    required super.child,
  }) {
    initialized.value = appLovin.initialized;

    _listenForInitialization(appLovin, initialized);
  }

  final AppLovin appLovin;
  final ValueNotifier<bool> initialized = ValueNotifier(false);

  static AppLovinProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppLovinProvider>();
  }

  static void _listenForInitialization(
    AppLovin appLovin,
    ValueNotifier<bool> initialized,
  ) {
    if (!appLovin.initialized) {
      appLovin.initialize().then((value) {
        initialized.value = appLovin.initialized;
      });
    }
  }

  @override
  bool updateShouldNotify(AppLovinProvider oldWidget) {
    bool shouldNotify = appLovin != oldWidget.appLovin;
    if (shouldNotify) initialized.value = false;
    return shouldNotify;
  }
}

final appLovin = AppLovin();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(AppLovinProvider(
    appLovin,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qr Code Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: Typography.material2021().black.apply(fontFamily: 'Noto'),
        useMaterial3: true,
      ).copyWith(),
      themeMode: ThemeMode.light,
      home: const HomePage(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                minimumSize: Size(
                  MediaQuery.of(context).size.shortestSide * .60,
                  48,
                ),
                primary: Theme.of(context).colorScheme.primaryContainer,
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontFamily: 'Noto',
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
