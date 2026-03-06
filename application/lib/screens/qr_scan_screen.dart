import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key, required this.expectedCode});

  final String expectedCode;

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final codes = capture.barcodes;
    if (codes.isEmpty) return;

    final raw = (codes.first.rawValue ?? '').trim();
    if (raw.isEmpty) return;

    _handled = true;
    await _controller.stop();
    if (!mounted) return;
    Navigator.of(context).pop(raw);
  }

  Future<void> _finishScanForTesting() async {
    if (_handled) return;
    _handled = true;
    await _controller.stop();
    if (!mounted) return;
    Navigator.of(context).pop(widget.expectedCode);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scan',
            style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _finishScanForTesting,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text(
                  'TEST: QR-Scan abschliessen',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


