@TestOn('vm')

import 'package:diff_image2/diff_image2.dart';
import 'package:diff_image2/src/helper_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test when dart:io is supported', () {
    late Uri flutterLogoUrl, dartLogoUrl, androidLogoUrl;

    setUp(() {
      // A real image
      flutterLogoUrl = Uri.parse(
          'https://seeklogo.com/images/F/flutter-logo-5086DD11C5-seeklogo.com.png');
      // Image with different size with respect to flutterLogoUrl
      dartLogoUrl = Uri.parse(
          'https://2.bp.blogspot.com/-L6CW4iuyCLE/TpQy4VCHJJI/AAAAAAAAAQs/Z40P6pqkfqA/s1600/dart-logo-banner1-348x196.jpg');
      // Image with the same size as flutterLogoUrl
      androidLogoUrl = Uri.parse(
          'https://seeklogo.com/images/A/android-western-logo-8F117A7F00-seeklogo.com.png');
    });

    test('Compare the same image', () async {
      var diff = await DiffImage.compareFromUrl(
        flutterLogoUrl,
        flutterLogoUrl,
      );
      expect(diff.diffValue, 0);

      diff = await DiffImage.compareFromUrl(
        flutterLogoUrl,
        flutterLogoUrl,
        ignoreAlpha: false,
      );
      expect(diff.diffValue, 0);
    });

    test('Compare images with different size', () async {
      try {
        await DiffImage.compareFromUrl(
          flutterLogoUrl,
          dartLogoUrl,
        );
      } catch (e) {
        expect(e, isA<UnsupportedError>());
      }
    });

    test('Compare different images with same sizes', () async {
      var diff = await DiffImage.compareFromUrl(
        flutterLogoUrl,
        androidLogoUrl,
      );
      expect(diff.diffValue, 24.77654080915494);

      diff = await DiffImage.compareFromUrl(
        flutterLogoUrl,
        androidLogoUrl,
        ignoreAlpha: false,
      );
      expect(diff.diffValue, 28.124964889523056);

      diff = await DiffImage.compareFromUrl(
        flutterLogoUrl,
        androidLogoUrl,
        asPercentage: false,
      );
      expect(diff.diffValue, 0.2477654080915494);

      diff = await DiffImage.compareFromUrl(
        flutterLogoUrl,
        androidLogoUrl,
        ignoreAlpha: false,
        asPercentage: false,
      );
      expect(diff.diffValue, 0.2812496488952306);
    });

    test('Save image showing differences', () async {
      var diff = await DiffImage.compareFromUrl(
        flutterLogoUrl,
        androidLogoUrl,
      );
      expect(diff.diffValue, 24.77654080915494);

      expect(
        () async {
          await DiffImage.saveImage(
            image: diff.diffImage,
            name: 'imageName',
            directory: '',
          );
        },
        returnsNormally,
      );
    });

    test('Compare Image Files', () async {
      var firstImage = await getImg(
        imgSrc: flutterLogoUrl,
      );
      var secondImage = await getImg(
        imgSrc: androidLogoUrl,
      );

      var diff = await DiffImage.compareFromMemory(
        firstImage,
        secondImage,
      );
      expect(diff.diffValue, 24.77654080915494);
    });
  });
}
