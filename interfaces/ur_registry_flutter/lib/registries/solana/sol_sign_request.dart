import 'package:ur_registry_flutter/ffi/ffi_factory.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/response.dart';
import 'package:ur_registry_flutter/ur_encoder.dart';
import 'package:uuid/uuid.dart';
import 'package:convert/convert.dart';

const nativePrefix = "solana_sign_request";

typedef NativeConstruct = Pointer<Response> Function(
    Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Uint32, Pointer<Utf8>, Pointer<Utf8>, Uint32);
typedef Construct = Pointer<Response> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, int, Pointer<Utf8>, Pointer<Utf8>, int);
typedef NativeGetUREncoder = Pointer<Response> Function(Pointer<Void>);

typedef NativeGetRequestId = Pointer<Response> Function(Pointer<Void>);

typedef NativeNew = Pointer<Response> Function();

class SolSignRequest extends NativeObject {
  static int transaction = 1;
  static int message = 2;
  late Construct nativeConstruct = lib.lookup<NativeFunction<NativeConstruct>>("${nativePrefix}_construct").asFunction<Construct>();
  late NativeGetUREncoder nativeGetUREncoder =
      lib.lookup<NativeFunction<NativeGetUREncoder>>("${nativePrefix}_get_ur_encoder").asFunction();
  late NativeNew nativeNew = lib.lookup<NativeFunction<NativeNew>>("${nativePrefix}_new").asFunction();
  late NativeGetRequestId nativeGetRequestId =
      lib.lookup<NativeFunction<NativeGetRequestId>>("${nativePrefix}_get_request_id").asFunction();

  late String uuid;

  SolSignRequest(Pointer<Void> object) : super() {
    nativeObject = object;
    final response = nativeGetRequestId(nativeObject).ref;
    final uuidBuffer = response.getString();
    uuid = Uuid.unparse(hex.decode(uuidBuffer));
  }

  // SolSignRequest._internal(): super() {
  //   final response = nativeNew().ref;
  //   nativeInstance = response.getObject();
  // }

  SolSignRequest.factory(List<int> signData, String path, String xfp, List<int> pubkey, String origin, int signType) : super() {
    uuid = const Uuid().v4();
    final buffer = Uuid.parse(uuid);
    final uuidBufferStr = hex.encode(buffer);
    final signDataStr = hex.encode(signData);
    final pubkeyStr = hex.encode(pubkey);
    final xfpInt = int.parse(xfp, radix: 16);

    // The native side reads these via CStr::from_ptr and copies; it never
    // takes ownership, so the Dart-allocated buffers are caller-owned and
    // must be freed here.
    final uuidPtr = uuidBufferStr.toNativeUtf8();
    final signDataPtr = signDataStr.toNativeUtf8();
    final pathPtr = path.toNativeUtf8();
    final pubkeyPtr = pubkeyStr.toNativeUtf8();
    final originPtr = origin.toNativeUtf8();
    try {
      final response = nativeConstruct(uuidPtr, signDataPtr, pathPtr, xfpInt, pubkeyPtr, originPtr, signType).ref;
      nativeObject = response.getObject();
    } finally {
      malloc.free(uuidPtr);
      malloc.free(signDataPtr);
      malloc.free(pathPtr);
      malloc.free(pubkeyPtr);
      malloc.free(originPtr);
    }
  }

  UREncoder toUREncoder() {
    final response = nativeGetUREncoder(nativeObject).ref;
    return UREncoder(response.getObject());
  }
}
