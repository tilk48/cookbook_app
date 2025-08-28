import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:cookbook_app/presentation/pages/recipes/recipe_detail_page.dart';
import '../test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecipeDetailPage golden', () {
    testGoldens('renders recipe detail screen', (tester) async {
      final fixture = _fixtureRecipe();

      final fakeClient = buildStubbedMealieClient(
        baseUrl: 'https://example.test',
        stubs: {fixture['slug']: fixture},
      );

      await pumpWidgetForGolden(
        tester,
        TestDiScope(
          mealieClient: fakeClient,
          child: const Material(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                width: 390,
                height: 844,
                child: RecipeDetailPage(
                  recipeSlug: 'herzhafte-franzbrotchen-mit-barlauch',
                ),
              ),
            ),
          ),
        ),
        themeMode: ThemeMode.dark,
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));

      await screenMatchesGolden(tester, 'recipe_detail_page_default');
    });
  });
}

Map<String, dynamic> _fixtureRecipe() {
  return {
    "id": "abc123",
    "name": "Test Recipe",
    "slug": "herzhafte-franzbrotchen-mit-barlauch",
    "description": "Leckere Brötchen mit Bärlauch.",
    "image":
        "https://mealie.ek3r7jer1e.xyz/api/media/recipes/996e0f71-faaa-402a-b17f-86719083e9fb/images/original.webp?rnd=1&version=no%20image",
    "recipeCategory": [
      {"id": "1", "name": "Backen", "slug": "backen"}
    ],
    "tags": [
      {"id": "t1", "name": "Vegan", "slug": "vegan"},
      {"id": "t2", "name": "Snack", "slug": "snack"}
    ],
    "recipeServings": 4.0,
    "totalTime": "PT30M",
    "prepTime": "PT10M",
    "cookTime": "PT20M",
    "recipeIngredient": [
      {
        "title": null,
        "note": null,
        "unit": {
          "id": "u1",
          "name": "g",
          "use_abbreviation": true,
          "abbreviation": "g"
        },
        "food": {"id": "f1", "name": "Mehl"},
        "disable_amount": false,
        "quantity": 250.0,
        "original_text": "250 g Mehl",
        "reference_id": "r1",
        "display": "250 g Mehl"
      },
      {
        "title": null,
        "note": null,
        "unit": {
          "id": "u2",
          "name": "ml",
          "use_abbreviation": true,
          "abbreviation": "ml"
        },
        "food": {"id": "f2", "name": "Wasser"},
        "disable_amount": false,
        "quantity": 150.0,
        "original_text": "150 ml Wasser",
        "reference_id": "r2",
        "display": "150 ml Wasser"
      }
    ],
    "recipeInstructions": [
      {"id": "i1", "title": "Mischen", "text": "Zutaten mischen"},
      {"id": "i2", "title": "Backen", "text": "20 Minuten backen"}
    ]
  };
}
