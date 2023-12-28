import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

const String _libName = 'flutter_opencc';
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('libopencc.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

final _openPtr =
    _dylib.lookup<NativeFunction<Pointer<Void> Function(Pointer<Utf8>)>>(
        'opencc_open');
final _open = _openPtr.asFunction<Pointer<Void> Function(Pointer<Utf8>)>();

final _closePtr =
    _dylib.lookup<NativeFunction<Void Function(Pointer<Void>)>>('opencc_close');
final _close = _closePtr.asFunction<void Function(Pointer<Void>)>();

final _covertPtr = _dylib.lookup<
    NativeFunction<
        Pointer<Utf8> Function(
            Pointer<Void>, Pointer<Utf8>, Int32)>>('opencc_convert_utf8');
final _covert = _covertPtr
    .asFunction<Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, int)>();

final _freeUTF8Ptr =
    _dylib.lookup<NativeFunction<Void Function(Pointer<Utf8>)>>(
        'opencc_convert_utf8_free');
final _freeUTF8 = _freeUTF8Ptr.asFunction<void Function(Pointer<Utf8>)>();

enum ConverType {
  s2t,
  t2s,
  s2tw,
  tw2s,
  s2hk,
  hk2s,
  s2twp,
  tw2sp,
  t2tw,
  hk2t,
  t2jp,
  jp2t,
  tw2t
}

class FlutterOpenCC {
  Pointer<Void>? _opencc;

  Future<void> init(ConverType type) async {
    if (_opencc != null) {
      _close(_opencc!);
    }
    final documentsDir = (await getApplicationDocumentsDirectory()).path;
    final dir = '$documentsDir/opencc';
    final d = Directory(dir);
    if (!d.existsSync()) {
      await Directory(dir).create(recursive: true);
    }
    final configFileName = [
      'hk2s',
      'hk2t',
      'jp2t',
      's2hk',
      's2t',
      's2tw',
      's2twp',
      't2hk',
      't2jp',
      't2s',
      't2tw',
      'tw2s',
      'tw2sp',
      'tw2t'
    ];
    for (var e in configFileName) {
      final name = '$e.json';
      final file = File('$dir/$name');
      if (!file.existsSync()) {
        final data = await rootBundle
            .load('packages/flutter_opencc/assets/config/$name');
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        file.writeAsBytesSync(bytes);
        log('$name 文件不存在，已创建', name: 'OpenCC');
      }
    }
    final dictFileName = [
      'HKVariants',
      'HKVariantsRev',
      'HKVariantsRevPhrases',
      'JPShinjitaiCharacters',
      'JPShinjitaiPhrases',
      'JPVariants',
      'JPVariantsRev',
      'STCharacters',
      'STPhrases',
      'TSCharacters',
      'TSPhrases',
      'TWPhrases',
      'TWPhrasesRev',
      'TWVariants',
      'TWVariantsRev',
      'TWVariantsRevPhrases',
    ];
    for (var e in dictFileName) {
      final name = '$e.ocd2';
      final file = File('$dir/$name');
      if (!file.existsSync()) {
        final data = await rootBundle
            .load('packages/flutter_opencc/assets/dictionary/$name');
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        file.writeAsBytesSync(bytes);
        log('$name 文件不存在，已创建', name: 'OpenCC');
      }
    }

    final path = '$dir/${type.name}.json';
    try {
      _opencc = _open(path.toNativeUtf8());
      log('初始化完成 $type', name: 'OpenCC');
    } catch (e) {
      log('初始化出错', name: 'OpenCC');
    }
  }

  String covert(String input) {
    if (_opencc == null) return input;
    final i = input.toNativeUtf8();
    final output = _covert(_opencc!, i, i.length);
    try {
      final str = output.toDartString();
      _freeUTF8(output);
      return str;
    } catch (e) {
      log('转换失败: $input', name: 'OpenCC');
      return '';
    }
  }
}
