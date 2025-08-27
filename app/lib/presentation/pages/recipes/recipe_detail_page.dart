import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mealie_api/mealie_api.dart';
import '../../../core/di/service_locator.dart';
import '../../providers/recipe_detail_provider.dart';
import '../../widgets/common/authenticated_image.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class RecipeDetailPage extends StatelessWidget {
  final String recipeSlug;

  const RecipeDetailPage({super.key, required this.recipeSlug});

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

class _RecipeDetailView extends StatefulWidget {
  final String recipeSlug;

  const _RecipeDetailView({required this.recipeSlug});

  @override
  State<_RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<_RecipeDetailView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeDetailProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.hasRecipe) {
          return const Scaffold(
            body: LoadingWidget(message: 'Loading recipe...'),
          );
        }

        if (provider.error != null && !provider.hasRecipe) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Recipe'),
            ),
            body: CustomErrorWidget(
              message: provider.error!,
              onRetry: () => provider.loadRecipe(widget.recipeSlug),
            ),
          );
        }

        if (!provider.hasRecipe) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Recipe'),
            ),
            body: const Center(
              child: Text('Recipe not found'),
            ),
          );
        }

        return _buildRecipeDetail(context, provider);
      },
    );
  }

  Widget _buildRecipeDetail(
      BuildContext context, RecipeDetailProvider provider) {
    final recipe = provider.recipe!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero App Bar with Image
          _buildSliverAppBar(context, provider),

          // Recipe Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe Header with Description
                _buildRecipeHeader(context, provider),

                // Recipe Stats (Time, Servings, etc.)
                if (_hasRecipeStats(provider))
                  _buildRecipeStats(context, provider),

                // Ingredients
                if (provider.ingredients.isNotEmpty)
                  _buildSection(
                    context,
                    'Ingredients (${provider.ingredients.length})',
                    Icons.list_alt,
                    _buildIngredients(context, provider),
                    headerWidget: provider.hasServingAdjustment
                        ? _buildServingAdjustment(context, provider)
                        : null,
                  ),

                // Instructions
                if (provider.instructions.isNotEmpty)
                  _buildSection(
                    context,
                    'Instructions',
                    Icons.format_list_numbered,
                    _buildInstructions(context, provider),
                    headerWidget: _buildInstructionProgress(context, provider),
                  ),

                // Nutrition Info
                if (provider.nutrition != null &&
                    _hasNutritionInfo(provider.nutrition!))
                  _buildSection(
                    context,
                    'Nutrition',
                    Icons.eco,
                    _buildNutrition(context, provider.nutrition!),
                  ),

                // Notes
                if (provider.notes.isNotEmpty)
                  _buildSection(
                    context,
                    'Notes',
                    Icons.note,
                    _buildNotes(context, provider),
                  ),

                // Bottom padding
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button for Favorite
      floatingActionButton: FloatingActionButton(
        onPressed: provider.toggleFavorite,
        child: Icon(
          provider.isFavorite ? Icons.favorite : Icons.favorite_border,
        ),
        tooltip:
            provider.isFavorite ? 'Remove from favorites' : 'Add to favorites',
      ),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, RecipeDetailProvider provider) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
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
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Hero Image
            Hero(
              tag: 'recipe-image-${provider.recipe!.id}',
              child: AuthenticatedImage(
                imageUrl: provider.buildImageUrl(),
                fit: BoxFit.cover,
                placeholderBuilder: () => _buildImagePlaceholder(),
                errorBuilder: (error) => _buildImagePlaceholder(),
              ),
            ),

            // Gradient Overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black38,
                    Colors.black54,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Rating in top right
      actions: [
        if (provider.rating != null && provider.rating! > 0)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.rating}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 64,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildRecipeHeader(
      BuildContext context, RecipeDetailProvider provider) {
    final recipe = provider.recipe!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories and Tags
          if (recipe.recipeCategory?.isNotEmpty == true ||
              recipe.tags?.isNotEmpty == true)
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                // Categories
                if (recipe.recipeCategory?.isNotEmpty == true)
                  ...recipe.recipeCategory!.map((category) => Chip(
                        label: Text(category.name),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      )),

                // Tags
                if (recipe.tags?.isNotEmpty == true)
                  ...recipe.tags!.map((tag) => Chip(
                        label: Text(tag.name),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        labelStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          fontSize: 12,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      )),
              ],
            ),

          // Description (without headline)
          if (recipe.description?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text(
              recipe.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.8),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  bool _hasRecipeStats(RecipeDetailProvider provider) {
    try {
      return (provider.totalTime?.isNotEmpty == true) ||
          (provider.prepTime?.isNotEmpty == true) ||
          (provider.cookTime?.isNotEmpty == true) ||
          (provider.recipeYield?.isNotEmpty == true);
    } catch (e) {
      print('DEBUG: Error checking recipe stats: $e');
      return false;
    }
  }

  Widget _buildRecipeStats(
      BuildContext context, RecipeDetailProvider provider) {
    try {
      final statTiles = <Widget>[];

      if (provider.totalTime?.isNotEmpty == true) {
        statTiles.add(_buildStatTile(
          context,
          Icons.access_time,
          'Total Time',
          provider.totalTime!,
        ));
      }

      if (provider.prepTime?.isNotEmpty == true) {
        statTiles.add(_buildStatTile(
          context,
          Icons.schedule,
          'Prep Time',
          provider.prepTime!,
        ));
      }

      if (provider.cookTime?.isNotEmpty == true) {
        statTiles.add(_buildStatTile(
          context,
          Icons.local_fire_department,
          'Cook Time',
          provider.cookTime!,
        ));
      }

      if (provider.recipeYield?.isNotEmpty == true) {
        statTiles.add(_buildStatTile(
          context,
          Icons.people,
          'Servings',
          provider.recipeYield!,
        ));
      }

      if (statTiles.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: statTiles.asMap().entries.map((entry) {
            final index = entry.key;
            final tile = entry.value;
            return Column(
              children: [
                tile,
                if (index < statTiles.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  ),
              ],
            );
          }).toList(),
        ),
      );
    } catch (e) {
      print('DEBUG: Error building recipe stats: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _buildStatTile(
      BuildContext context, IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(8),
          // border: Border.fromBorderSide(
          //   BorderSide(
          //     color: Colors.grey.withOpacity(0.3),
          //     width: 1,
          //   ),
          // ),
          ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, IconData icon, Widget content,
      {Widget? headerWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (headerWidget != null) headerWidget,
            ],
          ),
        ),
        content,
      ],
    );
  }

  Widget _buildIngredients(
      BuildContext context, RecipeDetailProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: provider.ingredients.asMap().entries.map((entry) {
          final index = entry.key;
          final ingredient = entry.value;
          final hasQuantity = provider.ingredientHasQuantity(ingredient);
          final formattedText =
              provider.getFormattedIngredient(ingredient, scaled: true);

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(
                bottom: index < provider.ingredients.length - 1 ? 12.0 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Quantity indicator
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: hasQuantity
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),

                // Ingredient text
                Expanded(
                  child: Text(
                    formattedText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: hasQuantity &&
                                  provider.currentServings !=
                                      provider.originalServings
                              ? FontWeight.w600
                              : FontWeight.w500,
                          height: 1.3,
                        ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInstructions(
      BuildContext context, RecipeDetailProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: provider.instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final instruction = entry.value;
          final isCompleted = provider.isStepCompleted(index);

          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(
                bottom: index < provider.instructions.length - 1 ? 16.0 : 0),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Number / Completion Button
                GestureDetector(
                  onTap: () => provider.toggleStepCompletion(index),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: isCompleted
                          ? null
                          : Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                              width: 1.5,
                            ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 22,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Instruction Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: AnimatedOpacity(
                      opacity: isCompleted ? 0.6 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (instruction.title?.isNotEmpty == true)
                            Text(
                              instruction.title!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          if (instruction.title?.isNotEmpty == true)
                            const SizedBox(height: 6),
                          Text(
                            instruction.text ?? 'No instruction provided',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor:
                                          Theme.of(context).colorScheme.outline,
                                      height: 1.4,
                                      fontWeight: FontWeight.w400,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _hasNutritionInfo(RecipeNutrition nutrition) {
    return nutrition.calories?.isNotEmpty == true ||
        nutrition.proteinContent?.isNotEmpty == true ||
        nutrition.fatContent?.isNotEmpty == true ||
        nutrition.carbohydrateContent?.isNotEmpty == true;
  }

  Widget _buildNutrition(BuildContext context, RecipeNutrition nutrition) {
    final nutritionItems = <MapEntry<String, String>>[];

    if (nutrition.calories?.isNotEmpty == true) {
      nutritionItems.add(MapEntry('Calories', nutrition.calories!));
    }
    if (nutrition.proteinContent?.isNotEmpty == true) {
      nutritionItems.add(MapEntry('Protein', nutrition.proteinContent!));
    }
    if (nutrition.fatContent?.isNotEmpty == true) {
      nutritionItems.add(MapEntry('Fat', nutrition.fatContent!));
    }
    if (nutrition.carbohydrateContent?.isNotEmpty == true) {
      nutritionItems.add(MapEntry('Carbs', nutrition.carbohydrateContent!));
    }
    if (nutrition.fiberContent?.isNotEmpty == true) {
      nutritionItems.add(MapEntry('Fiber', nutrition.fiberContent!));
    }
    if (nutrition.sugarContent?.isNotEmpty == true) {
      nutritionItems.add(MapEntry('Sugar', nutrition.sugarContent!));
    }
    if (nutrition.sodiumContent?.isNotEmpty == true) {
      nutritionItems.add(MapEntry('Sodium', nutrition.sodiumContent!));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: nutritionItems
            .map((item) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.key,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      Text(
                        item.value,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildNotes(BuildContext context, RecipeDetailProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.notes.length,
      itemBuilder: (context, index) {
        final note = provider.notes[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .tertiaryContainer
                .withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title?.isNotEmpty == true)
                Text(
                  note.title!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              if (note.title?.isNotEmpty == true) const SizedBox(height: 4),
              Text(
                note.text ?? 'No note content',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build serving size adjustment controls
  Widget _buildServingAdjustment(
      BuildContext context, RecipeDetailProvider provider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrease button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap:
                provider.currentServings > 1 ? provider.decreaseServings : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: provider.currentServings > 1
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: provider.currentServings > 1
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 12,
                color: provider.currentServings > 1
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Serving count display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${provider.currentServings} ',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                TextSpan(
                  text: '/ ${provider.originalServings}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Increase button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: provider.currentServings < 50
                ? provider.increaseServings
                : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: provider.currentServings < 50
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: provider.currentServings < 50
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 12,
                color: provider.currentServings < 50
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build instruction progress indicator
  Widget _buildInstructionProgress(
      BuildContext context, RecipeDetailProvider provider) {
    if (provider.instructions.isEmpty) return const SizedBox.shrink();

    final completedCount = provider.completedStepsCount;
    final totalCount = provider.instructions.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: progress == 1.0
            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: progress == 1.0
            ? Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          Container(
            width: 80,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: progress == 1.0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Progress text
          Text(
            '$completedCount/$totalCount',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: progress == 1.0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),

          // Reset button (only show if there are completed steps)
          if (completedCount > 0) ...[
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: provider.resetStepCompletions,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.refresh,
                    size: 18,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
