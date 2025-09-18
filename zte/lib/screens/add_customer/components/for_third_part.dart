import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eWarranty/models/categories_model.dart';
import 'package:video_player/video_player.dart';
import 'package:eWarranty/constants/config.dart';

class ForThirdPart {
  final BuildContext context;
  final ImagePicker picker;
  final Function(bool) setUploading;
  final Function(String, String?) updateTargetMap;
  final Function dismissKeyboard;
  final Future<String?> Function(File) uploadFile;
  final Future<bool> Function(String) deleteFile;
  final List<Video> videoList;

  VideoPlayerController? _currentController;
  Timer? _timeoutTimer;

  ForThirdPart({
    required this.context,
    required this.picker,
    required this.setUploading,
    required this.updateTargetMap,
    required this.dismissKeyboard,
    required this.uploadFile,
    required this.deleteFile,
    required this.videoList,
  });

  Map<String, Map<String, String>> get imageInfo {
    final video =
        videoList.isNotEmpty
            ? videoList[0]
            : Video(front: '', back: '', left: '', right: '');

    return {
      'invoiceImage': {
        'video': '${baseUrl}public/invoice.mp4',
        'text':
            '1. Please ensure the invoice is clearly visible and not folded. All details should be readable.',
      },
      'frontImage': {
        'video': '$baseUrl${video.front}',
        'text':
            '1. Capture the front view of the product clearly, ensuring the entire product is visible.',
      },
      'backImage': {
        'video': '$baseUrl${video.back}',
        'text':
            '1. Remove the back cover before capturing the image.\n2. Place the product on a flat surface and capture the back view clearly with no obstructions.',
      },
      'rightImage': {
        'video': '$baseUrl${video.right}',
        'text':
            '1. Remove the back cover before capturing the image.\n2. Take a clear photo of the right side of the product in good lighting conditions.',
      },
      'leftImage': {
        'video': '$baseUrl${video.left}',
        'text':
            '1. Remove the back cover before capturing the image.\n2. Take a clear photo of the left side of the product in good lighting conditions.',
      },
    };
  }

  // Add cleanup method
  void dispose() {
    _disposeCurrentController();
    _timeoutTimer?.cancel();
  }

  void _disposeCurrentController() {
    if (_currentController != null) {
      _currentController!.removeListener(_videoErrorListener);
      _currentController!.dispose();
      _currentController = null;
    }
  }

  void _videoErrorListener() {
    if (_currentController?.value.hasError == true) {
      print(
        "Video player error: ${_currentController?.value.errorDescription}",
      );
      // Safely handle the error
      _disposeCurrentController();
    }
  }

  Future<void> showDisclaimerAndPickImage(
    String key,
    Map<String, dynamic> targetMap,
  ) async {
    final info = imageInfo[key];
    if (info == null) {
      print("WARNING: No entry found for key '$key'.");
      return;
    }

    final String videoUrl = info['video'] ?? '';
    final String text = info['text'] ?? 'Disclaimer';

    // Ensure any previous controller is disposed
    _disposeCurrentController();

    bool? proceed;

    try {
      proceed = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true, // Allow dismissal
        barrierLabel:
            'Close dialog', // Required for accessibility when barrierDismissible is true
        barrierColor: Colors.black.withOpacity(0.8),
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, _, __) {
          return _DialogContent(
            videoUrl: videoUrl,
            text: text,
            onControllerCreated: (controller) {
              _currentController = controller;
              _currentController?.addListener(_videoErrorListener);
            },
            onDispose: _disposeCurrentController,
          );
        },
      );
    } catch (e) {
      print("Error showing dialog: $e");
      _disposeCurrentController();
    }

    if (proceed == true) {
      await pickImage(key, targetMap);
    }
  }

  Future<VideoPlayerController?> initializeVideoWithFallback(
    String primaryUrl,
  ) async {
    try {
      if (!context.mounted) {
        return null;
      }

      var controller = await initializeNetworkVideo(primaryUrl);
      return controller;
    } catch (e) {
      print("Video initialization failed: $e");
      return null;
    }
  }

  Future<VideoPlayerController?> initializeNetworkVideo(String videoUrl) async {
    VideoPlayerController? controller;

    try {
      final uri = Uri.parse(videoUrl);
      print("Attempting to load video from: $videoUrl");

      controller = VideoPlayerController.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
        httpHeaders: {
          'User-Agent': 'Flutter-VideoPlayer/1.0',
          'Accept': 'video/*',
          'Connection': 'keep-alive',
        },
      );

      // Set up timeout timer
      _timeoutTimer?.cancel();
      _timeoutTimer = Timer(const Duration(seconds: 10), () {
        final currentController = controller;
        if (currentController != null &&
            !currentController.value.isInitialized) {
          print("⏰ Video initialization timeout");
          currentController.dispose();
          controller = null;
        }
      });

      await controller?.initialize();
      _timeoutTimer?.cancel();

      final finalController = controller;
      if (finalController != null && finalController.value.isInitialized) {
        await finalController.setLooping(true);
        await finalController.setVolume(0);
        await finalController.play();
        print("Video loaded successfully");
        return finalController;
      } else {
        print("Video controller not initialized");
        controller?.dispose();
        return null;
      }
    } catch (e) {
      print("Failed to load network video: $e");
      controller?.dispose();
      return null;
    } finally {
      _timeoutTimer?.cancel();
    }
  }

  Future<void> pickImage(String key, Map<String, dynamic> targetMap) async {
    print('keysss $key');
    try {
      dismissKeyboard();
      FocusScope.of(context).unfocus();

      // Wait a bit for keyboard to dismiss
      await Future.delayed(const Duration(milliseconds: 300));

      if (!context.mounted) return;

      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null && context.mounted) {
        setUploading(true);
        try {
          final originalFile = File(image.path);

          // Check if file exists
          if (!await originalFile.exists()) {
            throw Exception('Image file not found');
          }

          final directory = originalFile.parent;
          final String timestamp =
              DateTime.now().millisecondsSinceEpoch.toString();
          final String newFileName = '${key}_$timestamp.jpg';
          final File renamedFile = await originalFile.copy(
            '${directory.path}/$newFileName',
          );

          final uploadedUrl = await uploadFile(renamedFile);

          if (context.mounted) {
            setUploading(false);
            updateTargetMap(key, uploadedUrl);
          }

          // Clean up temporary file
          try {
            if (await renamedFile.exists()) {
              await renamedFile.delete();
            }
          } catch (e) {
            print("Warning: Could not delete temporary file: $e");
          }
        } catch (e) {
          if (context.mounted) {
            setUploading(false);
            _showErrorSnackBar('Error processing image: $e');
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        setUploading(false);
        _showErrorSnackBar('Error accessing camera: $e');
      }
    }
  }

  Future<void> deleteImage(String key, Map<String, dynamic> targetMap) async {
    final String? imageUrl = targetMap[key];
    if (imageUrl != null && context.mounted) {
      setUploading(true);
      try {
        final success = await deleteFile(imageUrl);
        if (context.mounted) {
          setUploading(false);
          if (success) {
            updateTargetMap(key, null);
          } else {
            _showErrorSnackBar('Failed to delete image');
          }
        }
      } catch (e) {
        if (context.mounted) {
          setUploading(false);
          _showErrorSnackBar('Error deleting image: $e');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

// Separate StatefulWidget for dialog content to better manage video controller
class _DialogContent extends StatefulWidget {
  final String videoUrl;
  final String text;
  final Function(VideoPlayerController) onControllerCreated;
  final VoidCallback onDispose;

  const _DialogContent({
    required this.videoUrl,
    required this.text,
    required this.onControllerCreated,
    required this.onDispose,
  });

  @override
  State<_DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent> {
  VideoPlayerController? controller;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl.isEmpty) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      return;
    }

    try {
      final uri = Uri.parse(widget.videoUrl);
      controller = VideoPlayerController.networkUrl(uri);

      final currentController = controller;
      if (currentController != null) {
        widget.onControllerCreated(currentController);

        await currentController.initialize().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Video load timeout');
          },
        );

        if (mounted && currentController.value.isInitialized) {
          await currentController.setLooping(true);
          await currentController.setVolume(0);
          await currentController.play();
          setState(() {
            isLoading = false;
            hasError = false;
          });
        }
      }
    } catch (e) {
      print("Video initialization error: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: screenWidth * 0.95,
          height: screenHeight * 0.8,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 224, 221, 221),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xff244D9C), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(
                  const Color.fromARGB(255, 126, 126, 124),
                ), // Thumb color
                thumbVisibility: WidgetStateProperty.all(true),
                trackVisibility: WidgetStateProperty.all(true),
                thickness: WidgetStateProperty.all(4.0),
                radius: Radius.circular(4),
                crossAxisMargin: 2.0,
                mainAxisMargin: 8.0, 
              ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // VIDEO SECTION
                      SizedBox(
                        width: double.infinity,
                        height: 540,
                        child: _buildVideoWidget(),
                      ),
                      const SizedBox(height: 16),
                      // TEXT SECTION
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          widget.text,
                          style: const TextStyle(
                            color: Color(0xff244D9C),
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // BUTTONS SECTION
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: SizedBox(
                          height: 45,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff244D9C),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "Proceed",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoWidget() {
    if (isLoading) {
      return _loadingPlaceholder();
    }

    final currentController = controller;
    if (hasError ||
        currentController == null ||
        !currentController.value.isInitialized) {
      return _videoUnavailable();
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: currentController.value.size.width,
        height: currentController.value.size.height,
        child: VideoPlayer(currentController),
      ),
    );
  }

  Widget _loadingPlaceholder() => Container(
    decoration: BoxDecoration(
      color: const Color(0xffffffff),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff244D9C)),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading preview...',
            style: TextStyle(
              color: Color(0xff244D9C),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _videoUnavailable() => Container(
    decoration: BoxDecoration(
      color: const Color(0xff2a2a2a),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined, color: Color(0xff244D9C), size: 48),
          SizedBox(height: 16),
          Text(
            'Preview unavailable',
            style: TextStyle(
              color: Color(0xff244D9C),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
