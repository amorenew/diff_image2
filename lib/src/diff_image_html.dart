import 'dart:html';

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
      Pixel firstPixel, secondPixel;
      num diffAtPixel;

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
  static DiffImgResult compareFromFile(
    File firstImage,
    File secondImage, {
    bool asPercentage = true,
    bool ignoreAlpha = true,
  }) {
    // TODO Define if can compare image files
    throw UnsupportedError(
      "Currently we can't compare image files on web.",
    );
  }

  /// Function to store an [Image] object as PNG in local storage.
  /// Not supported on web.
  static Future<void> saveImage({
    required Image image,
    required String name,
    String directory = '',
  }) async {
    // TODO Define if can download image file or just show
    throw UnsupportedError(
      "Currently we can't save images on web.",
    );
  }
}
