import 'package:aimedic/features/posture/posture_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PostureLandmarks upright({
    double earSpread = 0.20,
    double neckDx = 0.0,
    double shoulderTiltY = 0.0,
  }) {
    // Symmetric person centred in frame, ears above shoulders.
    final earY = 0.35;
    final shoulderY = 0.55;
    return PostureLandmarks(
      leftEar: NormalizedPoint(0.5 - earSpread / 2 + neckDx, earY),
      rightEar: NormalizedPoint(0.5 + earSpread / 2 + neckDx, earY),
      leftShoulder: NormalizedPoint(0.35, shoulderY),
      rightShoulder: NormalizedPoint(0.65, shoulderY + shoulderTiltY),
    );
  }

  test('upright posture passes all checks', () {
    final status = evaluatePosture(upright());
    expect(status.detected, isTrue);
    expect(status.neckStraight, PostureCheck.good);
    expect(status.shouldersLevel, PostureCheck.good);
    expect(status.goodDistance, PostureCheck.good);
    expect(status.allGood, isTrue);
  });

  test('head bent far forward fails the neck check', () {
    // Ears shifted far sideways relative to shoulders → big tilt angle.
    final status = evaluatePosture(upright(neckDx: 0.15));
    expect(status.neckStraight, PostureCheck.bad);
    expect(status.allGood, isFalse);
  });

  test('uneven shoulders fail the level check', () {
    final status = evaluatePosture(upright(shoulderTiltY: 0.09));
    expect(status.shouldersLevel, PostureCheck.bad);
  });

  test('face filling the frame fails the distance check', () {
    final status = evaluatePosture(upright(earSpread: 0.45));
    expect(status.goodDistance, PostureCheck.bad);
  });

  test('nobody in frame reports not detected', () {
    final status = evaluatePosture(const PostureLandmarks());
    expect(status.detected, isFalse);
  });

  test('low-confidence landmarks are ignored', () {
    final status = evaluatePosture(PostureLandmarks(
      leftEar: const NormalizedPoint(0.4, 0.35, confidence: 0.2),
      rightEar: const NormalizedPoint(0.6, 0.35, confidence: 0.2),
      leftShoulder: const NormalizedPoint(0.35, 0.55),
      rightShoulder: const NormalizedPoint(0.65, 0.55),
    ));
    expect(status.detected, isFalse);
  });

  test('single visible side still evaluates the neck', () {
    final status = evaluatePosture(const PostureLandmarks(
      leftEar: NormalizedPoint(0.45, 0.35),
      leftShoulder: NormalizedPoint(0.44, 0.55),
    ));
    expect(status.detected, isTrue);
    expect(status.neckStraight, PostureCheck.good);
    expect(status.shouldersLevel, PostureCheck.unknown);
    expect(status.goodDistance, PostureCheck.unknown);
    expect(status.allGood, isTrue); // unknown never counts against the kid
  });
}
