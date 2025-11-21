import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../../../core/utils/responsive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/exercise.dart';

/// Widget pour afficher un exercice dans une liste (style ListTile)
class ExerciseListItem extends StatelessWidget {
  const ExerciseListItem({super.key, required this.exercise, this.onTap});

  final Exercise exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.padding(context).left,
          vertical: Responsive.spacing(context, 12),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Image de l'exercice (static - no animation)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child:
                    exercise.gifUrl.isNotEmpty
                        ? _StaticGifImage(
                          gifUrl: exercise.gifUrl,
                          width: 80,
                          height: 80,
                        )
                        : Icon(
                          Icons.fitness_center,
                          color: AppTheme.lightBlue,
                          size: 32,
                        ),
              ),
            ),

            SizedBox(width: Responsive.spacing(context, 12)),

            // Informations de l'exercice
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nom de l'exercice
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: Responsive.spacing(context, 4)),

                  // Tags (Body Parts et Equipment)
                  if (exercise.bodyParts.isNotEmpty ||
                      exercise.equipments.isNotEmpty)
                    Wrap(
                      spacing: Responsive.spacing(context, 6),
                      runSpacing: Responsive.spacing(context, 4),
                      children: [
                        if (exercise.bodyParts.isNotEmpty)
                          ...exercise.bodyParts
                              .take(2)
                              .map(
                                (bodyPart) => _buildTag(
                                  context,
                                  bodyPart,
                                  AppTheme.lightBlue,
                                ),
                              ),
                        if (exercise.equipments.isNotEmpty)
                          ...exercise.equipments
                              .take(1)
                              .map(
                                (equipment) => _buildTag(
                                  context,
                                  equipment,
                                  AppTheme.lightPurple,
                                ),
                              ),
                      ],
                    ),
                ],
              ),
            ),

            // Icône de flèche
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Widget pour afficher un GIF comme image statique (première frame uniquement)
/// Télécharge le GIF, décode la première frame et l'affiche comme image statique
class _StaticGifImage extends StatefulWidget {
  const _StaticGifImage({
    required this.gifUrl,
    required this.width,
    required this.height,
  });

  final String gifUrl;
  final double width;
  final double height;

  @override
  State<_StaticGifImage> createState() => _StaticGifImageState();
}

class _StaticGifImageState extends State<_StaticGifImage> {
  ui.Image? _staticImage;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isFromCache = false; // Track if image is from cache

  // Static cache to avoid re-downloading the same GIFs
  static final Map<String, ui.Image> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _loadFirstFrame();
  }

  Future<void> _loadFirstFrame() async {
    try {
      // Check cache first
      if (_imageCache.containsKey(widget.gifUrl)) {
        if (mounted) {
          setState(() {
            _staticImage = _imageCache[widget.gifUrl];
            _isFromCache = true; // Mark as from cache
            _isLoading = false;
          });
        }
        return;
      }

      // Download the GIF
      final response = await http.get(Uri.parse(widget.gifUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load GIF: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;

      // Decode the GIF using image package (returns first frame)
      final gifImage = img.decodeGif(bytes);

      if (gifImage == null) {
        throw Exception('Failed to decode GIF');
      }

      // Get the first frame (the image itself is already the first frame)
      // Convert to PNG bytes (PNG is lossless, so quality is always maximum)
      final pngBytes = img.encodePng(gifImage);

      // Convert to ui.Image preserving original dimensions for high quality
      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(pngBytes),
        targetWidth: gifImage.width,
        targetHeight: gifImage.height,
        allowUpscaling: false,
      );
      final frame = await codec.getNextFrame();

      // Cache the image
      _imageCache[widget.gifUrl] = frame.image;

      if (mounted) {
        setState(() {
          _staticImage = frame.image;
          _isFromCache = false; // Not from cache, newly created
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Only dispose if the image is not from cache (shared images shouldn't be disposed)
    if (!_isFromCache && _staticImage != null) {
      _staticImage!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_hasError || _staticImage == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: Icon(Icons.fitness_center, color: AppTheme.lightBlue, size: 32),
      );
    }

    // Display the static first frame using CustomPaint with validation
    // Validate image before using it
    if (_staticImage!.width <= 0 || _staticImage!.height <= 0) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: Icon(Icons.fitness_center, color: AppTheme.lightBlue, size: 32),
      );
    }

    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: _StaticImagePainter(_staticImage!),
    );
  }
}

/// Custom painter to draw the static image
class _StaticImagePainter extends CustomPainter {
  final ui.Image image;

  _StaticImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    // Validate image dimensions before drawing
    if (image.width <= 0 || image.height <= 0) {
      return;
    }

    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    try {
      final paint = Paint()..filterQuality = FilterQuality.high;
      final srcRect = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);

      // Ensure rectangles have valid dimensions
      if (srcRect.width > 0 &&
          srcRect.height > 0 &&
          dstRect.width > 0 &&
          dstRect.height > 0) {
        canvas.drawImageRect(image, srcRect, dstRect, paint);
      }
    } catch (e) {
      // Silently handle drawing errors
      debugPrint('Error drawing image: $e');
    }
  }

  @override
  bool shouldRepaint(_StaticImagePainter oldDelegate) => false;
}
