import 'package:flutter_test/flutter_test.dart';
import 'package:temani/core/theme/app_colors.dart';
import 'package:temani/core/theme/contrast.dart';

void main() {
  test('normal text pairs reach 4.5:1', () {
    final pairs = {
      'ink/yellow50': [AppColors.ink, AppColors.yellow50],
      'ink/yellow100': [AppColors.ink, AppColors.yellow100],
      'ink/surface': [AppColors.ink, AppColors.surface],
      'ink/primary': [AppColors.ink, AppColors.primary],
      'inkSoft/yellow50': [AppColors.inkSoft, AppColors.yellow50],
      'inkSoft/surface': [AppColors.inkSoft, AppColors.surface],
      'yellow700/yellow50': [AppColors.yellow700, AppColors.yellow50],
      'error/yellow50': [AppColors.error, AppColors.yellow50],
    };
    pairs.forEach((name, p) {
      expect(contrastRatio(p[0], p[1]), greaterThanOrEqualTo(4.5), reason: name);
    });
  });

  test('icon/large pairs reach 3:1', () {
    expect(contrastRatio(AppColors.yellow600, AppColors.yellow50), greaterThanOrEqualTo(3));
    expect(contrastRatio(AppColors.ink, AppColors.yellow200), greaterThanOrEqualTo(3));
  });

  test('white on primary yellow is NOT used (documented failure)', () {
    expect(contrastRatio(AppColors.surface, AppColors.primary), lessThan(3));
  });
}
