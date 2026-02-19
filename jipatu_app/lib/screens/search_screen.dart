import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService _productService = ProductService();
  List<Product> _results = [];

  void _search(String query) async {
    final data = await _productService.searchProducts(query);
    setState(() => _results = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _search,
              decoration: const InputDecoration(
                hintText: 'Search product...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final product = _results[index];

                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('฿${product.price}'),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}