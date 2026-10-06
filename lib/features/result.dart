import 'dart:math';

import 'package:flutter/material.dart';
import 'package:left_and_right/features/test.dart';
import 'package:left_and_right/models/question.dart';

class ResultScreen extends StatelessWidget {
  final List<Question> questions;
  final List<int> scores;

  const ResultScreen({
    super.key,
    required this.questions,
    required this.scores,
  });

  int get totalScore {
    if (scores.isEmpty) {
      return 0;
    }

    return scores.reduce((a, b) => a + b);
  }

  int get percentage {
    final maxScore = questions.fold<int>(
      0,
      (total, question) => total + question.weight * 2,
    );

    return (((totalScore + maxScore) / (maxScore * 2)) * 100).round().clamp(
      0,
      100,
    );
  }

  String get position {
    return _positionFor(percentage);
  }

  String _positionFor(num value) {
    if (value < 40) {
      return 'Izquierda';
    }

    if (value > 60) {
      return 'Derecha';
    }

    return 'Centro';
  }

  Map<String, double> get categoryScores {
    final Map<String, int> categoryTotals = {};
    final Map<String, int> categoryWeights = {};

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      categoryTotals.update(
        question.category,
        (total) => total + scores[i],
        ifAbsent: () => scores[i],
      );
      categoryWeights.update(
        question.category,
        (total) => total + question.weight,
        ifAbsent: () => question.weight,
      );
    }

    final Map<String, double> result = {};

    categoryTotals.forEach((category, total) {
      final weightedAverage = total / categoryWeights[category]!;
      result[category] = ((weightedAverage + 2) / 4) * 100;
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final categories = categoryScores;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const Text(
                    'Resultado',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 48),
                ],
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Tu ubicación en el',
                  style: TextStyle(fontSize: 17, color: Color(0xFF687386)),
                ),
              ),

              const Center(
                child: Text(
                  'espectro político',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: Text(
                  '$position ${percentage}%',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF315BEA),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0E5EC)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Izquierda',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Centro',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Derecha',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final positionX =
                            constraints.maxWidth * (percentage / 100);

                        return SizedBox(
                          height: 30,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                height: 8,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF5C78FF),
                                      Color(0xFF9AA4B2),
                                      Color(0xFFEF7070),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: max(
                                  0,
                                  min(positionX - 9, constraints.maxWidth - 18),
                                ),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFF315BEA),
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                '¿Qué influyó en tu resultado?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 8),

              const Text(
                'Estas son las áreas consideradas en tu análisis.',
                style: TextStyle(fontSize: 14, color: Color(0xFF687386)),
              ),

              const SizedBox(height: 20),

              ...categories.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _positionFor(entry.value),
                            style: const TextStyle(
                              color: Color(0xFF142B42),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _CategorySpectrumBar(percentage: entry.value),
                      const SizedBox(height: 4),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Izquierda',
                            style: TextStyle(
                              color: Color(0xFF687386),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            'Centro',
                            style: TextStyle(
                              color: Color(0xFF687386),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            'Derecha',
                            style: TextStyle(
                              color: Color(0xFF687386),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF315BEA)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Este resultado es orientativo. '
                        'No representa una definición absoluta '
                        'de tu ideología política.',
                        style: TextStyle(height: 1.4, color: Color(0xFF38445A)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TestScreen(),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Iniciar otro test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF142B42),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySpectrumBar extends StatelessWidget {
  const _CategorySpectrumBar({required this.percentage});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const markerSize = 14.0;
        final markerPosition =
            (constraints.maxWidth * percentage / 100 - markerSize / 2)
                .clamp(0.0, constraints.maxWidth - markerSize)
                .toDouble();

        return SizedBox(
          height: 20,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 7,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF5C78FF),
                      Color(0xFF9AA4B2),
                      Color(0xFFEF7070),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: markerPosition,
                child: Container(
                  width: markerSize,
                  height: markerSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF315BEA),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
