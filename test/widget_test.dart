import 'package:diyetsel/app/theme/app_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('primary brand color is orange', () {
    expect(AppColors.primary.toARGB32(), 0xFFFF6B00);
  });
}
