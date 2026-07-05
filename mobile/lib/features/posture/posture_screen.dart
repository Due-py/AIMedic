import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import 'posture_rules.dart';

/// Live posture check. Pose detection runs entirely on-device (ML Kit);
/// no frame ever leaves the phone — see CLAUDE.md §6 privacy requirement.
class PostureScreen extends StatefulWidget {
  const PostureScreen({super.key});

  @override
  State<PostureScreen> createState() => _PostureScreenState();
}

class _PostureScreenState extends State<PostureScreen> {
  CameraController? _camera;
  PoseDetector? _detector;
  bool _unavailable = false;
  bool _busy = false;
  PostureStatus _status = const PostureStatus(detected: false);

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.low, // pose detection needs no more; saves battery
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await controller.initialize();
      _detector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
      );
      await controller.startImageStream(_onFrame);
      if (mounted) setState(() => _camera = controller);
    } catch (e) {
      debugPrint('Posture camera unavailable: $e');
      if (mounted) setState(() => _unavailable = true);
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_busy || _detector == null) return;
    _busy = true;
    try {
      final input = _toInputImage(image);
      if (input == null) return;
      final poses = await _detector!.processImage(input);
      final status = poses.isEmpty
          ? const PostureStatus(detected: false)
          : evaluatePosture(_toLandmarks(
              poses.first,
              image.width.toDouble(),
              image.height.toDouble(),
            ));
      if (mounted) setState(() => _status = status);
    } catch (e) {
      debugPrint('Pose frame error: $e');
    } finally {
      _busy = false;
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    final camera = _camera;
    if (camera == null) return null;
    // With nv21 the frame arrives as a single plane.
    if (image.planes.length != 1) return null;
    final rotation = InputImageRotationValue.fromRawValue(
      camera.description.sensorOrientation,
    );
    if (rotation == null) return null;
    return InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  PostureLandmarks _toLandmarks(Pose pose, double width, double height) {
    NormalizedPoint? point(PoseLandmarkType type) {
      final lm = pose.landmarks[type];
      if (lm == null) return null;
      return NormalizedPoint(
        lm.x / width,
        lm.y / height,
        confidence: lm.likelihood,
      );
    }

    return PostureLandmarks(
      leftEar: point(PoseLandmarkType.leftEar),
      rightEar: point(PoseLandmarkType.rightEar),
      leftShoulder: point(PoseLandmarkType.leftShoulder),
      rightShoulder: point(PoseLandmarkType.rightShoulder),
    );
  }

  @override
  void dispose() {
    _camera?.dispose();
    _detector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_camera?.value.isInitialized ?? false)
            Center(child: CameraPreview(_camera!))
          else if (_unavailable)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.postureUnavailable,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.postureTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            l10n.postureSubtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (!_unavailable)
                  PostureStatusPanel(status: _status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom overlay with the three gentle checks — separate widget so it can
/// be widget-tested without a camera.
class PostureStatusPanel extends StatelessWidget {
  const PostureStatusPanel({super.key, required this.status});

  final PostureStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(24),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!status.detected)
              Row(
                children: [
                  const Text('👀', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l10n.postureNotDetected)),
                ],
              )
            else ...[
              Text(
                status.allGood ? l10n.postureAllGood : l10n.postureAdjust,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: status.allGood ? AppTheme.mint : AppTheme.sunny,
                ),
              ),
              const SizedBox(height: 10),
              _CheckRow(
                label: l10n.postureCheckNeck,
                tip: l10n.postureNeckTip,
                check: status.neckStraight,
              ),
              _CheckRow(
                label: l10n.postureCheckShoulders,
                tip: l10n.postureShouldersTip,
                check: status.shouldersLevel,
              ),
              _CheckRow(
                label: l10n.postureCheckDistance,
                tip: l10n.postureDistanceTip,
                check: status.goodDistance,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.tip,
    required this.check,
  });

  final String label;
  final String tip;
  final PostureCheck check;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (check) {
      PostureCheck.good => (Icons.check_circle_rounded, AppTheme.mint),
      PostureCheck.bad => (Icons.error_rounded, AppTheme.sunny),
      PostureCheck.unknown => (Icons.remove_circle_outline, Colors.white38),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          if (check == PostureCheck.bad)
            Flexible(
              child: Text(
                tip,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                textAlign: TextAlign.end,
              ),
            ),
        ],
      ),
    );
  }
}
