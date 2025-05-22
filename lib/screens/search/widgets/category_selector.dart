import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length + 1, // +1 para la opción "Todos"
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemBuilder: (context, index) {
              if (index == 0) {
                // Opción "Todos"
                return _buildCategoryChip(
                  context,
                  'Todos',
                  state.selectedCategory.isEmpty,
                  () => context.read<SearchCubit>().filterByCategory(''),
                );
              }

              final category = state.categories[index - 1];
              final isSelected = state.selectedCategory == category;

              return _buildCategoryChip(
                context,
                category,
                isSelected,
                () => context.read<SearchCubit>().filterByCategory(category),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String category,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2979FF) : Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
