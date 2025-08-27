import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/recipe_entity.dart';
import '../../providers/recipe_provider.dart';
import '../common/authenticated_image.dart';

class RecipeCard extends StatelessWidget {
  final RecipeEntity recipe;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _buildGridCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recipe Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),
                  if (recipe.rating != null && recipe.rating! > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _buildRatingBadge(context),
                    ),
                ],
              ),
            ),
            // Recipe Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe Name
                    Text(
                      recipe.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Categories
                    if (recipe.categories.isNotEmpty)
                      Text(
                        recipe.categories.map((c) => c.name).join(' • '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const Spacer(),

                    // Time and Difficulty
                    Row(
                      children: [
                        if (recipe.totalTime != null) ...[
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              recipe.totalTime!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Always try to load an image since the API might be lying about availability
    return Hero(
      tag: 'recipe-image-${recipe.id}',
      child: AuthenticatedImage(
        imageUrl: recipe.imageUrl ?? '',
        fit: BoxFit.cover,
        placeholderBuilder: () => _buildPlaceholderImage(showProgress: true),
        errorBuilder: (error) {
          return _buildPlaceholderImage();
        },
      ),
    );
  }

  Widget _buildPlaceholderImage({bool showProgress = false}) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: showProgress
            ? const CircularProgressIndicator()
            : Icon(
                Icons.restaurant_menu,
                size: 48,
                color: Colors.grey[400],
              ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: recipe.isFavorite
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurfaceVariant,
          size: 24,
        ),
        onPressed: () {
          context.read<RecipeProvider>().toggleFavorite(recipe.id);
        },
        constraints: const BoxConstraints.tightFor(
          width: 36,
          height: 36,
        ),
        padding: EdgeInsets.zero,
        tooltip:
            recipe.isFavorite ? 'Remove from favorites' : 'Add to favorites',
      ),
    );
  }

  Widget _buildRatingBadge(BuildContext context) {
    return Container(
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
            size: 14,
            color: Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            '${recipe.rating}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
