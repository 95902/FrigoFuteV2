// ignore_for_file: avoid_print

import 'dart:io';

/// Coverage verification script for CI/CD pipeline
/// Usage: dart run tool/check_coverage.dart `lcov_file` `threshold`
/// Example: dart run tool/check_coverage.dart coverage/lcov.info 75
void main(List<String> args) {
  if (args.length != 2) {
    print('❌ Usage: dart check_coverage.dart <lcov_file> <threshold>');
    print('   Example: dart check_coverage.dart coverage/lcov.info 75');
    exit(1);
  }

  final lcovFilePath = args[0];
  final threshold = double.tryParse(args[1]);

  if (threshold == null || threshold < 0 || threshold > 100) {
    print('❌ Error: Threshold must be a number between 0 and 100');
    exit(1);
  }

  final lcovFile = File(lcovFilePath);

  if (!lcovFile.existsSync()) {
    print('❌ Error: Coverage file not found: $lcovFilePath');
    print('   Make sure to run "flutter test --coverage" first');
    exit(1);
  }

  final lines = lcovFile.readAsLinesSync();
  int totalLines = 0;
  int coveredLines = 0;

  // Parse LCOV format
  // DA:<line number>,<execution count>
  for (final line in lines) {
    if (line.startsWith('DA:')) {
      totalLines++;
      final parts = line.substring(3).split(',');
      if (parts.length >= 2) {
        final executionCount = int.tryParse(parts[1]);
        if (executionCount != null && executionCount > 0) {
          coveredLines++;
        }
      }
    }
  }

  if (totalLines == 0) {
    print('❌ Error: No coverage data found in $lcovFilePath');
    print('   The coverage file appears to be empty or invalid');
    exit(1);
  }

  final coverage = (coveredLines / totalLines) * 100;

  print('');
  print('📊 Code Coverage Report');
  print('━' * 50);
  print('Total lines:    $totalLines');
  print('Covered lines:  $coveredLines');
  print('Coverage:       ${coverage.toStringAsFixed(2)}%');
  print('Threshold:      ${threshold.toStringAsFixed(2)}%');
  print('━' * 50);

  if (coverage < threshold) {
    final missing = threshold - coverage;
    print(
      '❌ FAILED: Coverage ${coverage.toStringAsFixed(2)}% is below threshold ${threshold.toStringAsFixed(2)}%',
    );
    print('   Missing: ${missing.toStringAsFixed(2)}% coverage');
    print('');
    print('💡 Tip: Add more tests to increase coverage');
    exit(1);
  }

  print(
    '✅ PASSED: Coverage ${coverage.toStringAsFixed(2)}% meets threshold ${threshold.toStringAsFixed(2)}%',
  );
  print('');
  exit(0);
}
