import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mealie_api/mealie_api.dart';
import '../../../core/di/service_locator.dart';
import '../../providers/recipe_detail_provider.dart';
import '../../widgets/common/authenticated_image.dart';
import 'widgets/recipe_header.dart';
import 'widgets/recipe_stats.dart';
import 'widgets/serving_adjustment.dart';
import 'widgets/ingredients_list.dart';
import 'widgets/instructions_progress.dart';
import 'widgets/instructions_list.dart';
import 'widgets/recipe_section.dart';
import 'widgets/recipe_actions_menu.dart';

class RecipeDetailPage extends StatelessWidget {
  final String recipeSlug;

  const RecipeDetailPage({
    super.key,
    required this.recipeSlug,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeDetailProvider>(
      create: (_) => RecipeDetailProvider(
        mealieClient: sl<MealieClient>(),
      )..loadRecipe(recipeSlug),
      child: _RecipeDetailView(recipeSlug: recipeSlug),
    );
  }
}

class _RecipeDetailView extends StatelessWidget {
  final String recipeSlug;

  const _RecipeDetailView({
    required this.recipeSlug,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeDetailProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadRecipe(recipeSlug),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final recipe = provider.recipe;
        if (recipe == null) {
          return const Scaffold(
            body: Center(child: Text('Recipe not found')),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Hero Image Header
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(
                    left: 16,
                    bottom: 16,
                    right: 16,
                    top: 10,
                  ),
                  title: Text(
                    provider.recipe!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3.0,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  background: Hero(
                    tag: 'recipe-image-${recipe.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AuthenticatedImage(
                          imageUrl: provider.buildImageUrl(),
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black38,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  RecipeActionsMenu(provider: provider),
                ],
              ),

              // Content
              SliverList(
                delegate: SliverChildListDelegate([
                  // Recipe Header with Description
                  RecipeHeader(provider: provider),

                  // Recipe Stats (Time, Servings, etc.)
                  RecipeStats(provider: provider),

                  // Ingredients Section
                  if (provider.ingredients.isNotEmpty)
                    RecipeSection(
                      title: 'Ingredients (${provider.ingredients.length})',
                      icon: Icons.list_alt,
                      content: IngredientsList(provider: provider),
                      headerWidget: provider.hasServingAdjustment
                          ? ServingAdjustment(provider: provider)
                          : null,
                    ),

                  // Instructions Section
                  if (provider.instructions.isNotEmpty)
                    RecipeSection(
                      title: 'Instructions',
                      icon: Icons.format_list_numbered,
                      content: InstructionsList(provider: provider),
                      headerWidget: InstructionsProgress(provider: provider),
                    ),

                  // Bottom padding
                  const SizedBox(height: 120),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
