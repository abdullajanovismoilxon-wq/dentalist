import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/specialization.dart';

class SpecializationChips extends StatelessWidget {
  final List<Specialization> specializations;
  final int? selectedId;
  final Function(int?) onSelected;

  const SpecializationChips({
    super.key,
    required this.specializations,
    this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _chip(null, 'Barchasi', selectedId == null),
        ),
        ...specializations.map((s) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _chip(s.id, s.name, selectedId == s.id),
        )),
      ],
    );
  }

  Widget _chip(int? id, String label, bool selected) {
    return GestureDetector(
      onTap: () => onSelected(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(AppColors.primary) : const Color(AppColors.background),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(AppColors.primary) : const Color(AppColors.border)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(AppColors.textSecondary),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
