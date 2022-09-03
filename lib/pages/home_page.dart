import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'camera_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    const spacing = SizedBox(height: 12);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          shrinkWrap: true,
          scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 0,
                          color: const Color(0x70EFEFEF),
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Text(
                                  'Scan Qr Code',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Color(0xD00A0A0A),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Fastest Qr & Barcode Scanner',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0x80050505),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Flexible(child: Image(image: AssetImage('images/landing.png'))),
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const CameraPickerPage(),
                            ));
                          },
                          label: const Text(
                            'Scan Now',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          icon: const Icon(Icons.camera, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.deepPurpleAccent,
                          ),
                        ),
                        spacing,
                        ElevatedButton.icon(
                          onPressed: () {
                            launchUrl(Uri.parse('market://details?id=com.scannerme.barcode'));
                          },
                          label: const Text('Rate App'),
                          icon: const Icon(Icons.favorite),
                        ),
                        spacing,
                        ElevatedButton.icon(
                          onPressed: () {
                            launchUrl(Uri.parse('https://sites.google.com/view/qrbarcodebarcodescanner/accueil'));
                          },
                          label: const Text('Privacy Policy'),
                          icon: const Icon(Icons.policy),
                        ),
                        spacing,
                        ElevatedButton.icon(
                          onPressed: () {
                            launchUrl(Uri.parse('https://play.google.com/store/apps/developer?id=CartoonME+Editor'));
                          },
                          label: const Text('More apps'),
                          icon: const Icon(Icons.apps),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
