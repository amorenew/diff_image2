@TestOn('vm')

import 'package:diff_image/src/helper_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';

void main() {
  group('Test for helper functions', () {
    late Uri flutterLogoUrl, badUrl, anotherLogoUrl;

    setUp(() {
      // A real image
      flutterLogoUrl = Uri.parse(
          'https://seeklogo.com/images/F/flutter-logo-5086DD11C5-seeklogo.com.png');
      // Not an image
      badUrl = Uri.parse('https://seeklogo.com');
      // Image with different size with respect to flutterLogoUrl
      anotherLogoUrl = Uri.parse(
          'https://2.bp.blogspot.com/-L6CW4iuyCLE/TpQy4VCHJJI/AAAAAAAAAQs/Z40P6pqkfqA/s1600/dart-logo-banner1-348x196.jpg');
    });

    test('Get image from url', () async {
      var first = await getImg(
        imgSrc: flutterLogoUrl,
      );
      expect(first, isA<Image>());
      expect(
        () async {
          await getImg(
            imgSrc: badUrl,
          );
        },
        throwsException,
      );
    });

    test('Compare images size', () async {
      var img1 = await getImg(
        imgSrc: flutterLogoUrl,
      );
      var areEquals = haveSameSize(
        firstImg: img1,
        secondImg: img1,
      );
      expect(areEquals, isTrue);

      var img2 = await getImg(
        imgSrc: anotherLogoUrl,
      );
      areEquals = haveSameSize(
        firstImg: img1,
        secondImg: img2,
      );
      expect(areEquals, isFalse);
    });
  });
}
