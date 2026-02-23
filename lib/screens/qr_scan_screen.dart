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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black.withValues(alpha: 0.55),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Text(
                'Scanne den QR Code bei der Station.\nErwarteter Test-Code: ${widget.expectedCode}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
