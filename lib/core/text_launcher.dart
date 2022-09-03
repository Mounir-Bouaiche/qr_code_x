import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

const String _emailPattern =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
const String _urlPattern =
    r"(https?:\/\/(?:www\.|(?!www?))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})";
const String _phonePattern = r"^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$";

final Iterable<RegExp> _patterns = [
  _emailPattern,
  _urlPattern,
  _phonePattern,
].map((e) => RegExp(e));

class TextLauncher {
  final String text;
  const TextLauncher(this.text);

  Future<TestResult> canLaunch([BuildContext? context]) async {
    if (text.toLowerCase().startsWith('tel:') ||
        text.toLowerCase().startsWith('sms:') ||
        text.toLowerCase().startsWith('market:')) {
      return canLaunchUrlString(text.toLowerCase()).then((canLaunch) {
        return TestResult(canLaunch, text.toLowerCase());
      });
    }

    try {
      final regEx = _patterns.firstWhere((pattern) {
        return pattern.hasMatch(text);
      });

      late final String str;

      if (regEx.pattern == _emailPattern) {
        str = 'mailto:$text';
      } else if (regEx.pattern == _urlPattern) {
        str = text;
      } else if (regEx.pattern == _phonePattern) {
        if (context != null) {
          str = await showDialog<bool>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Do you want to make ...'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Call'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('SMS'),
                  ),
                ],
              );
            },
          ).then((value) {
            return '${value ?? false ? 'sms' : 'tel'}:$text';
          });
        } else {
          str = 'tel:$text';
        }
      }

      return canLaunchUrlString(str).then((canLaunch) {
        return TestResult(canLaunch, str);
      });
    } catch (e) {
      // ignored
    }

    return const TestResult(false);
  }

  Future<void> launch(TestResult result) async {
    if (result.canLaunch && result.launchString != null) {
      launchUrlString(result.launchString!);
    }
  }
}

class TestResult {
  final bool canLaunch;
  final String? launchString;

  const TestResult(this.canLaunch, [this.launchString]);
}
