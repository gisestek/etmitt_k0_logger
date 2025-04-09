import 'dart:math';

double calculateStandardDeviation(List<double> values) {
  if (values.isEmpty) return 0.0;

  final mean = values.reduce((a, b) => a + b) / values.length;
  final sumSquaredDifferences = values
      .map((v) => pow(v - mean, 2))
      .reduce((a, b) => a + b);

  return sqrt(sumSquaredDifferences / values.length);
}
