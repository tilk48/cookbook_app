import 'package:flutter/material.dart';

class RecipeEditPage extends StatelessWidget {
  final String recipeSlug;
  
  const RecipeEditPage({super.key, required this.recipeSlug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit: $recipeSlug')),
      body: Center(
        child: Text('Recipe Edit - Coming Soon'),
      ),
    );
  }
}