@TestOn('browser')

import 'package:diff_image2/diff_image2.dart';
import 'package:diff_image2/src/helper_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test when dart:html is supported', () {
    late Uri flutterLogoUrl, dartLogoUrl, androidLogoUrl;

    setUp(() {
      // A real image
      flutterLogoUrl = Uri.parse(
          'https://seeklogo.com/images/F/flutter-logo-5086DD11C5-seeklogo.com.png');
      // Image with different size with respect to flutterLogoUrl
      dartLogoUrl = Uri.parse(
          'https://www.extremetech.com/wp-content/uploads/2011/10/dart-logo-banner1-348x196.jpg');
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
      expect(diff.diffValue, 34.83905183744361);

      diff = await DiffImage.compareFromUrl(
        flutterLogoUrl,
        androidLogoUrl,
        ignoreAlpha: false,
      );
      expect(diff.diffValue, 35.67169421487167);

      diff = await DiffImage.compareFromUrl(
        flutterLogoUrl,
        androidLogoUrl,
        asPercentage: false,
      );
      expect(diff.diffValue, 0.34839051837443613);

      diff = await DiffImage.compareFromUrl(
        flutterLogoUrl,
        androidLogoUrl,
        ignoreAlpha: false,
        asPercentage: false,
      );
      expect(diff.diffValue, 0.3567169421487167);
    });

    test('Save image showing differences', () async {
      var diff = await DiffImage.compareFromUrl(
        flutterLogoUrl,
        androidLogoUrl,
      );
      expect(diff.diffValue, 34.83905183744361);

      expect(
        () async {
          await DiffImage.saveImage(
            image: diff.diffImage,
            name: 'imageName',
            directory: '',
          );
        },
        throwsException,
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
      expect(diff.diffValue, 34.83905183744361);
    });
  });
}
