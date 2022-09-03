import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';
import 'package:qr_code_x/pages/result_page.dart';
import 'package:camera/camera.dart';

class CameraPickerPage extends StatefulWidget {
  const CameraPickerPage({
    Key? key,
    this.initialTypeCamera,
  }) : super(key: key);

  final TypeCamera? initialTypeCamera;

  @override
  State<CameraPickerPage> createState() => _CameraPickerPageState();
}

class _CameraPickerPageState extends State<CameraPickerPage> {
  late final QRCodeDartScanController _controller;
  late TypeCamera _typeCamera;
  final _isFlashOn = ValueNotifier<bool>(false);
  final _isFrontCamera = ValueNotifier<bool>(false);
  bool _scanComplete = false;
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = QRCodeDartScanController();
    _typeCamera = widget.initialTypeCamera ?? TypeCamera.back;
    _isFlashOn.addListener(() {
      final isOn = _isFlashOn.value;

      _controller.setFlashMode(isOn ? FlashMode.torch : FlashMode.off);
    });

    _isFrontCamera.addListener(() {
      setState(() {
        final isFront = _isFrontCamera.value;
        _controller.setScanEnabled(false);
        print('Switch to ${isFront ? 'Front' : 'Back'}');
        _typeCamera = isFront ? TypeCamera.front : TypeCamera.back;
      });
      _controller.setScanEnabled(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              bottom: 72,
              left: 24,
              right: 24,
              top: 24,
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                margin: EdgeInsets.zero,
                elevation: 8,
                child: QRCodeDartScanView(
                  key: _key,
                  scanInvertedQRCode: true,
                  typeScan: TypeScan.live,
                  controller: _controller,
                  typeCamera: _typeCamera,
                  onCapture: (Result result) async {
                    if (!_scanComplete) {
                      _scanComplete = true;
                      _controller.setScanEnabled(false);

                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => ResultPage(result)),
                      );
                    }
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Center(
                    child: FloatingActionButton(
                      tooltip: 'Flash mode',
                      onPressed: () => _isFlashOn.value = !_isFlashOn.value,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isFlashOn,
                        builder: (context, value, child) {
                          return value ? const Icon(Icons.flash_on_rounded) : const Icon(Icons.flash_off_rounded);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
