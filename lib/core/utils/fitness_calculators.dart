abstract class FitnessCalculators {
  static double completionRate({required int completed, required int total}) {
    if (total <= 0) return 0;
    return completed / total;
  }
}
