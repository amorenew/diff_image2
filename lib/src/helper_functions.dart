import 'package:http/http.dart' as http;
import 'package:image/image.dart';

/// Through http get request to [imgSrc] obtains the bytes
/// that make up an image. Can throw an [Exception].
Future<Image> getImg({required Uri imgSrc}) async {
  Image? img;

  var response = await http.get(imgSrc);
  if (response.statusCode != 200) {
    throw Exception(
      'imgSrc: $imgSrc has StatusCode http ${response.statusCode}',
    );
  }

  img = decodeImage(response.bodyBytes);
  if (img == null) {
    throw Exception(
      'imgSrc: $imgSrc is not returning an Image',
    );
  }

  return img;
}

/// Check if [firstImage] and [secondImage] have the same width and height.
bool haveSameSize({
  required Image firstImage,
  required Image secondImage,
}) {
  return firstImage.width == secondImage.width &&
      firstImage.height == secondImage.height;
}

/// Returns a red color if and only if two RGB pixels are different.
/// If one of the pixels is black, the resulting color will be the
/// other pixel but more transparent.
Color selectColor({
  required num diffAtPixel,
  required Pixel firstPixel,
  required Pixel secondPixel,
}) {
  Color result;

  var fRed = firstPixel.r.toInt();
  var fGreen = firstPixel.g.toInt();
  var fBlue = firstPixel.b.toInt();
  var sRed = secondPixel.r.toInt();
  var sGreen = secondPixel.g.toInt();
  var sBlue = secondPixel.b.toInt();

  if (diffAtPixel == 0) {
    result = ColorFloat16.rgba(
      fRed,
      fGreen,
      fBlue,
      50,
    );
  } else if (fRed == 0 && fGreen == 0 && fBlue == 0) {
    result = ColorFloat16.rgba(
      sRed,
      sGreen,
      sBlue,
      50,
    );
  } else if (sRed == 0 && sGreen == 0 && sBlue == 0) {
    result = ColorFloat16.rgba(
      fRed,
      fGreen,
      fBlue,
      50,
    );
  } else {
    var alpha = 255, red = 255, green = 0, blue = 0;
    result = ColorFloat16.rgba(
      red,
      green,
      blue,
      alpha,
    );
  }

  return result;
}
