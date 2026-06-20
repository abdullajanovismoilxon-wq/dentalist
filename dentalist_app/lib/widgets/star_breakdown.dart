import 'package:flutter/material.dart';
import '../core/constants.dart';

class StarBreakdown extends StatelessWidget {
  final Map<String, Map<String, dynamic>> breakdown;
  final int total;

  const StarBreakdown({super.key, required this.breakdown, required this.total});

  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return const Center(
        child: Text("Hali baho yo'q", style: TextStyle(fontSize: 14, color: Color(AppColors.textSecondary))),
      );
    }

    const amber = 0xFFFBBF24;
    return Column(
      children: List.generate(5, (i) {
        final star = (5 - i).toString();
        final data = breakdown[star];
        final count = (data?['count'] ?? 0) as int;
        final percentage = ((data?['percentage'] ?? 0.0) as num).toDouble();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Row(
                  children: [
                    Text(star, style: const TextStyle(fontSize: 13, color: Color(AppColors.textSecondary))),
                    const SizedBox(width: 2),
                    const Icon(Icons.star, size: 13, color: Color(amber)),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(amber),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text('$count', style: const TextStyle(fontSize: 12, color: Color(AppColors.textSecondary))),
              ),
              SizedBox(
                width: 45,
                child: Text('${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12, color: Color(AppColors.textSecondary))),
              ),
            ],
          ),
        );
      }),
    );
  }
}