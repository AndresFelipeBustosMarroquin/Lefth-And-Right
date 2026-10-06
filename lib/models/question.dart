class Question {
  final String category;
  final String text;
  final List<String> options;
  final int weight;

  const Question({
    required this.category,
    required this.text,
    required this.options,
    this.weight = 1,
  });
}
