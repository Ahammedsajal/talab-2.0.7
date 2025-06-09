import 'package:flutter/material.dart';
import 'package:Talab/ui/screens/widgets/animated_routes/fade_scale_route.dart';

/// Simple widget to show an image in a fullscreen hero view with a
/// fade and scale transition. This avoids heavy calculations and works
/// well with sliders or list sections.
class CustomImageHeroAnimation extends StatefulWidget {
  final Widget child;
  final CImageType type;
  final dynamic image;

  const CustomImageHeroAnimation({
    super.key,
    required this.child,
    required this.type,
    this.image,
  });

  @override
  State<CustomImageHeroAnimation> createState() => _CustomImageHeroAnimationState();
}

class _CustomImageHeroAnimationState extends State<CustomImageHeroAnimation> {
  late final String _tag;

  @override
  void initState() {
    super.initState();
    _tag = widget.image?.toString() ?? UniqueKey().toString();
  }

  ImageProvider _imageProvider() {
    switch (widget.type) {
      case CImageType.Asset:
        return AssetImage(widget.image);
      case CImageType.Network:
        return NetworkImage(widget.image);
      case CImageType.File:
        return FileImage(widget.image);
      case CImageType.Memory:
        return MemoryImage(widget.image);
    }
  }

  void _openPreview() {
    Navigator.of(context).push(
      FadeScaleRoute(
        page: _FullScreenImage(tag: _tag, imageProvider: _imageProvider()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openPreview,
      child: Hero(
        tag: _tag,
        child: widget.child,
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String tag;
  final ImageProvider imageProvider;

  const _FullScreenImage({required this.tag, required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: tag,
            child: InteractiveViewer(
              child: Image(image: imageProvider, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

enum CImageType { Asset, Network, File, Memory }