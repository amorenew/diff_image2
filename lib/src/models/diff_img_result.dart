import 'package:image/image.dart';

/// Model to encapsulate the results of a difference between images
/// query.
class DiffImgResult {
  DiffImgResult({
    required this.diffImage,
    required this.diffValue,
  });

  final Image diffImage;
  final num diffValue;
}
