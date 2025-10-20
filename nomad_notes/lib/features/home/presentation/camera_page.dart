import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _error = 'No cameras found';
        });
        return;
      }

      _controller = CameraController(
        _cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Camera error: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final image = await _controller!.takePicture();

      // Copy to temporary location
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File imageFile = File(image.path);
      final File savedImage = await imageFile.copy(filePath);

      if (!mounted) return;

      Navigator.of(context).pop(savedImage);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Photo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            )
          : !_isInitialized
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Stack(
                  children: [
                    // Camera preview
                    Center(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),

                    // Controls overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        color: Colors.black54,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Cancel button
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close, color: Colors.white, size: 32),
                              tooltip: 'Cancel',
                            ),

                            // Capture button
                            GestureDetector(
                              onTap: _takePicture,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),

                            // Switch camera button (if multiple cameras)
                            _cameras.length > 1
                                ? IconButton(
                                    onPressed: () async {
                                      final currentIndex = _cameras.indexOf(_controller!.description);
                                      final nextIndex = (currentIndex + 1) % _cameras.length;

                                      await _controller?.dispose();

                                      _controller = CameraController(
                                        _cameras[nextIndex],
                                        ResolutionPreset.high,
                                        enableAudio: false,
                                      );

                                      await _controller!.initialize();

                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                                    tooltip: 'Switch Camera',
                                  )
                                : const SizedBox(width: 48),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
