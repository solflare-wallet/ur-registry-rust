// ignore_for_file: unused_element

import 'package:ur_registry_flutter/ffi/ffi_factory.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/registries/cardano/cardano_catalyst_signature.dart';
import 'package:ur_registry_flutter/registries/cardano/cardano_sign_data_signature.dart';
import 'package:ur_registry_flutter/registries/cardano/cardano_signature.dart';
import 'package:ur_registry_flutter/registries/crypto_account.dart';
import 'package:ur_registry_flutter/registries/crypto_hd_key.dart';
import 'package:ur_registry_flutter/registries/crypto_psbt.dart';
import 'package:ur_registry_flutter/registries/ethereum/eth_sign_request.dart';
import 'package:ur_registry_flutter/registries/ethereum/eth_signature.dart';
import 'package:ur_registry_flutter/registries/extend/crypto_multi_accounts.dart';
import 'package:ur_registry_flutter/registries/cardano/cardano_sign_cip8_data_signature.dart';
import 'package:ur_registry_flutter/registries/solana/sol_signature.dart';
import 'package:ur_registry_flutter/response.dart';

import 'registries/solana/sol_sign_request.dart';

const nativePrefix = "ur_decoder";

typedef NativeNew = Pointer<Response> Function();
typedef NativeReceive = Pointer<Response> Function(Pointer<Void>, Pointer<Utf8>);
typedef NativeResult = Pointer<Response> Function(Pointer<Void>);
typedef NativeIsComplete = Pointer<Response> Function(Pointer<Void>);
typedef NativeResolve = Pointer<Response> Function(Pointer<Void>, Pointer<Utf8>);

enum SupportedType {
  cryptoHDKey,
  cryptoAccount,
  cryptoPSBT,
  cryptoMultiAccounts,
  // sol
  solSignRequest,
  solSignature,
  // eth
  ethSignRequest,
  ethSignature,
  // cardano
  cardanoUTXO,
  cardanoSignRequest,
  cardanoSignature,
  cardanoCertKey,
  cardanoSignDataRequest,
  cardanoSignDataSignature,
  cardanoSignCip8DataRequest,
  cardanoSignCip8DataSignature,
  cardanoCatalystVotingRegistration,
  cardanoCatalystSignature,
}

const _cryptoHDKey = 'crypto-hdkey';
const _cryptoAccount = 'crypto-account';
const _cryptoPSBT = 'crypto-psbt';
const _cryptoMultiAccounts = 'crypto-multi-accounts';
const _solSignRequest = 'sol-sign-request';
const _solSignature = 'sol-signature';
const _ethSignRequest = 'eth-sign-request';
const _ethSignature = 'eth-signature';

const _cardanoUTXO = 'cardano-utxo';
const _cardanoSignRequest = 'cardano-sign-request';
const _cardanoSignature = 'cardano-signature';
const _cardanoCertKey = 'cardano-cert-key';
const _cardanoSignDataRequest = 'cardano-sign-data-request';
const _cardanoSignDataSignature = 'cardano-sign-data-signature';
const _cardanoSignCip8DataRequest = 'cardano-sign-cip8-data-request';
const _cardanoSignCip8DataSignature = 'cardano-sign-cip8-data-signature';
const _cardanoCatalystVotingRegistration = 'cardano-catalyst-voting-registration';
const _cardanoCatalystVotingRegistrationSignature = 'cardano-catalyst-voting-registration-signature';

class URDecoder extends NativeObject {
  late NativeNew nativeNew = lib.lookup<NativeFunction<NativeNew>>("${nativePrefix}_new").asFunction();
  late NativeReceive nativeReceive = lib.lookup<NativeFunction<NativeReceive>>("${nativePrefix}_receive").asFunction();
  late NativeIsComplete nativeIsComplete = lib.lookup<NativeFunction<NativeIsComplete>>("${nativePrefix}_is_complete").asFunction();
  late NativeResult nativeResult = lib.lookup<NativeFunction<NativeResult>>("${nativePrefix}_result").asFunction();
  late NativeResolve nativeResolve = lib.lookup<NativeFunction<NativeResolve>>("${nativePrefix}_resolve").asFunction();

  URDecoder() : super() {
    final response = nativeNew().ref;
    nativeObject = response.getObject();
  }

  void receive(String ur) {
    // Caller-owned input buffer: the native side reads it via
    // CStr::from_ptr and copies. Without the free, every scanned animated-QR
    // frame leaked its UR payload.
    final urPtr = ur.toNativeUtf8();
    try {
      final response = nativeReceive(nativeObject, urPtr).ref;
      response.throwIfPresent();
    } finally {
      malloc.free(urPtr);
    }
  }

  bool isComplete() {
    final response = nativeIsComplete(nativeObject).ref;
    return response.getBoolean();
  }

  String result() {
    final response = nativeResult(nativeObject).ref;
    return response.getString();
  }

  NativeObject resolve(SupportedType type) {
    switch (type) {
      case SupportedType.cryptoHDKey:
        return CryptoHDKey(_resolveObject(_cryptoHDKey));
      case SupportedType.cryptoAccount:
        return CryptoAccount(_resolveObject(_cryptoAccount));
      case SupportedType.cryptoPSBT:
        return CryptoPSBT(_resolveObject(_cryptoPSBT));
      case SupportedType.cryptoMultiAccounts:
        return CryptoMultiAccounts(_resolveObject(_cryptoMultiAccounts));
      // sol
      case SupportedType.solSignRequest:
        return SolSignRequest(_resolveObject(_solSignRequest));
      case SupportedType.solSignature:
        return SolSignature(_resolveObject(_solSignature));
      // eth
      case SupportedType.ethSignRequest:
        return EthSignRequest(_resolveObject(_ethSignRequest));
      case SupportedType.ethSignature:
        return EthSignature(_resolveObject(_ethSignature));
      case SupportedType.cardanoSignature:
        return CardanoSignature(_resolveObject(_cardanoSignature));
      case SupportedType.cardanoSignDataSignature:
        return CardanoSignDataSignature(_resolveObject(_cardanoSignDataSignature));
      case SupportedType.cardanoSignCip8DataSignature:
        return CardanoSignCip8DataSignature(_resolveObject(_cardanoSignCip8DataSignature));
      case SupportedType.cardanoCatalystSignature:
        return CardanoCatalystSignature(_resolveObject(_cardanoCatalystVotingRegistrationSignature));
      default:
        throw Exception("type $type is not supported");
    }
  }

  /// Resolve the decoded UR into the native registry object for
  /// [registryType], freeing the caller-owned type-string buffer.
  ///
  /// The native side reads the string via CStr::from_ptr and copies.
  Pointer<Void> _resolveObject(String registryType) {
    final typePtr = registryType.toNativeUtf8();
    try {
      final response = nativeResolve(nativeObject, typePtr).ref;
      return response.getObject();
    } finally {
      malloc.free(typePtr);
    }
  }
}
