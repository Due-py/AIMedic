// Pure posture geometry, separated from the camera/ML Kit plumbing so it
// can be unit-tested with synthetic landmarks.
//
// All inputs are normalized image coordinates (0..1, y grows downward).
// Thresholds are deliberately forgiving: this is a gentle coach, not a
// clinical instrument, and estimates from a phone camera are approximate.

import 'dart:math' as math;

class NormalizedPoint {
  const NormalizedPoint(this.x, this.y, {this.confidence = 1.0});

  final double x;
  final double y;
  final double confidence;
}

class PostureLandmarks {
  const PostureLandmarks({
    this.leftEar,
    this.rightEar,
    this.leftShoulder,
    this.rightShoulder,
  });

  final NormalizedPoint? leftEar;
  final NormalizedPoint? rightEar;
  final NormalizedPoint? leftShoulder;
  final NormalizedPoint? rightShoulder;
}

enum PostureCheck { good, bad, unknown }

class PostureStatus {
  const PostureStatus({
    required this.detected,
    this.neckStraight = PostureCheck.unknown,
    this.shouldersLevel = PostureCheck.unknown,
    this.goodDistance = PostureCheck.unknown,
  });

  /// False when no person is confidently in frame.
  final bool detected;
  final PostureCheck neckStraight;
  final PostureCheck shouldersLevel;
  final PostureCheck goodDistance;

  bool get allGood =>
      detected &&
      neckStraight != PostureCheck.bad &&
      shouldersLevel != PostureCheck.bad &&
      goodDistance != PostureCheck.bad;
}

const _minConfidence = 0.5;

/// Neck tilt beyond this angle from vertical reads as "head bent forward".
const maxNeckTiltDegrees = 27.0;

/// Shoulder height difference beyond this fraction of shoulder width
/// reads as "leaning/uneven".
const maxShoulderTiltRatio = 0.18;

/// Ear-to-ear spread beyond this fraction of the frame width reads as
/// "face too close to the screen" (~under 35-40 cm on typical phones).
const maxEarSpreadRatio = 0.34;

bool _ok(NormalizedPoint? p) => p != null && p.confidence >= _minConfidence;

PostureStatus evaluatePosture(PostureLandmarks landmarks) {
  final shoulders = [landmarks.leftShoulder, landmarks.rightShoulder]
      .where(_ok)
      .cast<NormalizedPoint>()
      .toList();
  final ears = [landmarks.leftEar, landmarks.rightEar]
      .where(_ok)
      .cast<NormalizedPoint>()
      .toList();

  if (shoulders.isEmpty || ears.isEmpty) {
    return const PostureStatus(detected: false);
  }

  // Neck tilt: angle of the ear→shoulder line from vertical, averaged over
  // whichever sides are visible.
  var neck = PostureCheck.unknown;
  final tilts = <double>[];
  for (final (ear, shoulder) in [
    (landmarks.leftEar, landmarks.leftShoulder),
    (landmarks.rightEar, landmarks.rightShoulder),
  ]) {
    if (_ok(ear) && _ok(shoulder)) {
      final dx = (ear!.x - shoulder!.x).abs();
      final dy = (shoulder.y - ear.y).abs();
      tilts.add(math.atan2(dx, dy) * 180 / math.pi);
    }
  }
  if (tilts.isNotEmpty) {
    final avg = tilts.reduce((a, b) => a + b) / tilts.length;
    neck = avg > maxNeckTiltDegrees ? PostureCheck.bad : PostureCheck.good;
  }

  // Shoulder levelness relative to shoulder width.
  var level = PostureCheck.unknown;
  if (shoulders.length == 2) {
    final width = (shoulders[0].x - shoulders[1].x).abs();
    if (width > 0.02) {
      final tilt = (shoulders[0].y - shoulders[1].y).abs() / width;
      level = tilt > maxShoulderTiltRatio ? PostureCheck.bad : PostureCheck.good;
    }
  }

  // Screen distance proxy: how much of the frame the head spans.
  var distance = PostureCheck.unknown;
  if (ears.length == 2) {
    final spread = (ears[0].x - ears[1].x).abs();
    distance =
        spread > maxEarSpreadRatio ? PostureCheck.bad : PostureCheck.good;
  }

  return PostureStatus(
    detected: true,
    neckStraight: neck,
    shouldersLevel: level,
    goodDistance: distance,
  );
}
