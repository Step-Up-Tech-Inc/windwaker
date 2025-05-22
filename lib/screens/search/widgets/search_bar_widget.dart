import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/search_cubit.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialQuery;

  const SearchBarWidget({super.key, this.initialQuery});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Buscar tiendas o productos',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12, right: 8),
              child: Icon(Icons.search, color: Colors.grey, size: 22),
            ),
            suffixIcon:
                _controller.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                        size: 22,
                      ),
                      onPressed: () {
                        _controller.clear();
                        context.read<SearchCubit>().clearFilters();
                      },
                    )
                    : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            filled: true,
            fillColor: Colors.transparent,
            isDense: true,
          ),
          onChanged: (value) {
            setState(() {}); // Para actualizar el icono de borrar
            context.read<SearchCubit>().searchStores(value);
          },
        ),
      ),
    );
  }
}
