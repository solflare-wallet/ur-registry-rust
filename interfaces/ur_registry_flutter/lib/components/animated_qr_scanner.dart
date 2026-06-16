import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/ur_decoder.dart';

abstract class _State {}

class _InitialState extends _State {}

typedef SuccessCallback = void Function(NativeObject);
typedef FailureCallback = void Function(String);

class _Cubit extends Cubit<_State> {
  late final SupportedType target;
  final SuccessCallback onSuccess;
  final FailureCallback onFailed;
  final Widget? overlay;
  URDecoder urDecoder = URDecoder();
  bool succeed = false;

  _Cubit(
    this.target,
    this.onSuccess,
    this.onFailed, {
    this.overlay,
  }) : super(_InitialState());

  void receiveQRCode(String? code) {
    try {
      if (code != null) {
        urDecoder.receive(code);
        if (urDecoder.isComplete()) {
          final NativeObject result = urDecoder.resolve(target);
          if (!succeed) {
            onSuccess(result);
            succeed = true;
          }
        }
      }
    } catch (e, stackTrace) {
      // Route the real exception through FlutterError so the host app's
      // error reporting (FlutterError.onError, e.g. Crashlytics) records
      // it; the failure callback gets a stable message instead of a raw
      // toString that would leak decoder internals into UI copy.
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        stack: stackTrace,
        library: 'ur_registry_flutter',
        context: ErrorDescription('while receiving an animated UR QR frame'),
      ));
      onFailed('Failed to decode QR code');
      reset();
    }
  }

  void reset() {
    urDecoder = URDecoder();
    succeed = false;
  }
}

class AnimatedQRScanner extends StatelessWidget {
  final SupportedType target;
  final SuccessCallback onSuccess;
  final FailureCallback onFailed;
  final Widget? overlay;

  const AnimatedQRScanner({super.key, required this.target, required this.onSuccess, required this.onFailed, this.overlay});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<_Cubit>(
      create: (BuildContext context) => _Cubit(target, onSuccess, onFailed, overlay: overlay),
      child: _AnimatedQRScanner(),
    );
  }
}

class _AnimatedQRScanner extends StatefulWidget {
  @override
  _AnimatedQRScannerState createState() => _AnimatedQRScannerState();
}

class _AnimatedQRScannerState extends State<_AnimatedQRScanner> {
  final MobileScannerController controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  late final _Cubit _cubit;

  @override
  void initState() {
    _cubit = BlocProvider.of(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: controller,
      // mobile_scanner 7.x replaced overlay with overlayBuilder.
      overlayBuilder: (BuildContext context, BoxConstraints constraints) => _cubit.overlay ?? const SizedBox.shrink(),
      onDetect: (BarcodeCapture capture) {
        for (final Barcode barcode in capture.barcodes) {
          _cubit.receiveQRCode(barcode.rawValue);
        }
      },
    );
  }

  @override
  void dispose() {
    // mobile_scanner 7.x dispose is async; fire-and-forget is sufficient here.
    unawaited(controller.dispose());
    super.dispose();
  }
}
