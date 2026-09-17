import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

final _sessionId = UuidValue('00000000-0000-0000-0000-000000000000');

class _FakeFFI implements FFI {
  @override
  UuidValue get sessionId => _sessionId;

  @override
  late final FfiModel ffiModel = FfiModel(WeakReference(this));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('the quality monitor names the WebRTC transport only on web', () {
    final ffi = _FakeFFI();
    ffi.ffiModel.cachedPeerData.streamType = 'WebRTC';
    final model = QualityMonitorModel(WeakReference(ffi));
    // Off the web the session tab's tooltip already names the transport.
    expect(isWeb, isFalse);
    expect(model.webrtcTransport, isNull);
  });

  test('the codec row keeps the bitstream name and a decode-path suffix', () {
    final ffi = _FakeFFI();
    final model = QualityMonitorModel(WeakReference(ffi));
    model.updateQualityStatus({
      'codec_format': 'H264',
      'decode_path': 'PRIME',
    });
    expect(model.data.codecFormat, 'H264');
    expect(model.data.decodePath, 'PRIME');
    model.updateQualityStatus({
      'codec_format': 'VP9',
      'decode_path': '',
    });
    expect(model.data.codecFormat, 'VP9');
    expect(model.data.decodePath, isNull);
    model.updateQualityStatus({'delay': '12'});
    expect(model.data.decodePath, isNull);
    expect(model.data.codecFormat, 'VP9');
  });
}
