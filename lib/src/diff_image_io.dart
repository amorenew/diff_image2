import 'dart:io';

import 'package:image/image.dart';
import 'helper_functions.dart';
import 'models/diff_img_result.dart';

class DiffImage {
  /// Returns a single number representing the difference between two RGB pixels
  static num _diffBetweenPixels({
    required Pixel firstPixel,
    required bool ignoreAlpha,
    required Pixel secondPixel,
  }) {
    var fRed = firstPixel.r;
    var fGreen = firstPixel.g;
    var fBlue = firstPixel.b;
    var fAlpha = firstPixel.a;
    var sRed = secondPixel.r;
    var sGreen = secondPixel.g;
    var sBlue = secondPixel.b;
    var sAlpha = secondPixel.a;

    var diff =
        (fRed - sRed).abs() + (fGreen - sGreen).abs() + (fBlue - sBlue).abs();

    if (ignoreAlpha) {
      diff = (diff / 255) / 3;
    } else {
      diff += (fAlpha - sAlpha).abs();
      diff = (diff / 255) / 4;
    }

    return diff;
  }

  /// Computes the diffence between two images with the same width and heigth
  /// by receiving two URLs (one for each image). Retrieves both by using an
  /// HTTP request and returns a [DiffImgResult] containing two items:
  ///
  /// * An image showing the different pixels from both images.
  /// * The average difference between each pixel.
  ///
  /// Can throw an [Exception].
  static Future<DiffImgResult> compareFromUrl(
    dynamic firstImageSrc,
    dynamic secondImageSrc, {
    bool asPercentage = true,
    bool ignoreAlpha = true,
  }) async {
    var firstImage = await getImg(
      imgSrc: firstImageSrc,
    );
    var secondImage = await getImg(
      imgSrc: secondImageSrc,
    );

    return compareFromMemory(
      firstImage,
      secondImage,
      asPercentage: asPercentage,
      ignoreAlpha: ignoreAlpha,
    );
  }

  /// Computes the diffence between two images with the same width and heigth
  /// by receiving two [Image] objects (one for each image). Returns a
  /// [DiffImgResult] containing two items:
  ///
  /// * An image showing the different pixels from both images.
  /// * The average difference between each pixel.
  ///
  /// Can throw an [Exception].
  static DiffImgResult compareFromMemory(
    Image firstImage,
    Image secondImage, {
    bool asPercentage = true,
    bool ignoreAlpha = true,
  }) {
    var diff = 0.0;

    var imagesEqualSize = haveSameSize(
      firstImage: firstImage,
      secondImage: secondImage,
    );
    if (!imagesEqualSize) {
      throw UnsupportedError(
        'Currently we need images of same width and height',
      );
    }

    var width = firstImage.width;
    var height = firstImage.height;
    // Create an image to show the differences
    var diffImg = Image(width: width, height: height);

    for (var i = 0; i < width; i++) {
      num diffAtPixel;
      Pixel firstPixel, secondPixel;

      for (var j = 0; j < height; j++) {
        firstPixel = firstImage.getPixel(i, j);
        secondPixel = secondImage.getPixel(i, j);

        diffAtPixel = _diffBetweenPixels(
          firstPixel: firstPixel,
          ignoreAlpha: ignoreAlpha,
          secondPixel: secondPixel,
        );
        diff += diffAtPixel;

        // Shows in red the different pixels and in semitransparent the same ones
        diffImg.setPixel(
          i,
          j,
          selectColor(
            diffAtPixel: diffAtPixel,
            firstPixel: firstPixel,
            secondPixel: secondPixel,
          ),
        );
      }
    }

    diff /= height * width;

    if (asPercentage) diff *= 100;

    return DiffImgResult(
      diffImage: diffImg,
      diffValue: diff,
    );
  }

  /// Computes the diffence between two image files with the same width and heigth
  /// by receiving two [File] objects (one for each image). Returns a
  /// [DiffImgResult] containing two items:
  ///
  /// * An image showing the different pixels from both images.
  /// * The average difference between each pixel.
  ///
  /// Can throw an [Exception].
  static Future<DiffImgResult> compareFromFile(
    File firstImageFile,
    File secondImageFile, {
    bool asPercentage = true,
    bool ignoreAlpha = true,
  }) async {
    final isFirstImageExist = firstImageFile.existsSync();
    final isSecondImageExist = secondImageFile.existsSync();
    if (!isFirstImageExist) {
      throw FileSystemException(
        'diffImage2: compareFromFile first image not found',
        firstImageFile.path,
      );
    } else if (!isSecondImageExist) {
      throw FileSystemException(
        'diffImage2: compareFromFile second image not found',
        secondImageFile.path,
      );
    }

    final firstImage = await _convertFileToImage(firstImageFile);
    final secondImage = await _convertFileToImage(secondImageFile);

    return compareFromMemory(
      firstImage,
      secondImage,
      asPercentage: asPercentage,
      ignoreAlpha: ignoreAlpha,
    );
  }

  static Future<Image> _convertFileToImage(File picture) async {
    final imageBytes = await picture.readAsBytes();
    return decodePng(imageBytes)!;
  }

  /// Function to store an [Image] object as PNG in local storage.
  /// Not supported on web.
  static Future<File> saveImage({
    required Image image,
    required String name,
    String directory = '',
  }) async {
    if (directory.isNotEmpty && !directory.endsWith('/')) {
      directory = '$directory/';
    }
    final resultFile = await File('$directory$name').create(recursive: true);

    return await resultFile.writeAsBytes(encodePng(image), flush: true);
  }
}
