import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../presentation/pages/onboarding/splash_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/recipes/recipe_list_page.dart';
import '../../presentation/pages/recipes/recipe_detail_page.dart';
import '../../presentation/pages/recipes/recipe_create_page.dart';
import '../../presentation/pages/recipes/recipe_edit_page.dart';
import '../../presentation/pages/meal_plans/meal_plans_page.dart';
import '../../presentation/pages/shopping_lists/shopping_lists_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/profile/settings_page.dart';
import '../../presentation/providers/auth_provider.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String recipes = '/recipes';
  static const String recipeDetail = '/recipes/:slug';
  static const String recipeCreate = '/recipes/create';
  static const String recipeEdit = '/recipes/:slug/edit';
  static const String mealPlans = '/meal-plans';
  static const String shoppingLists = '/shopping-lists';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: splash,
      redirect: _redirect,
      routes: [
        // Splash & Onboarding
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),

        // Authentication
        GoRoute(
          path: login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterPage(),
        ),

        // Main App
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return HomePage(navigationShell: navigationShell);
          },
          branches: [
            // Recipes Branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: recipes,
                  builder: (context, state) => const RecipeListPage(),
                  routes: [
                    GoRoute(
                      path: 'create',
                      builder: (context, state) => const RecipeCreatePage(),
                    ),
                    GoRoute(
                      path: ':slug',
                      builder: (context, state) {
                        final slug = state.pathParameters['slug']!;
                        return RecipeDetailPage(recipeSlug: slug);
                      },
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (context, state) {
                            final slug = state.pathParameters['slug']!;
                            return RecipeEditPage(recipeSlug: slug);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Meal Plans Branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: mealPlans,
                  builder: (context, state) => const MealPlansPage(),
                ),
              ],
            ),

            // Shopping Lists Branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: shoppingLists,
                  builder: (context, state) => const ShoppingListsPage(),
                ),
              ],
            ),

            // Profile Branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: profile,
                  builder: (context, state) => const ProfilePage(),
                  routes: [
                    GoRoute(
                      path: 'settings',
                      builder: (context, state) => const SettingsPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authProvider = context.read<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    final isOnAuthPage = [login, register].contains(state.matchedLocation);
    final isOnOnboardingPage = state.matchedLocation == onboarding;
    final isOnSplashPage = state.matchedLocation == splash;

    // Always allow splash page to show initially
    if (isOnSplashPage) {
      return null;
    }

    // Check if user needs onboarding (first time setup)
    if (!authProvider.hasServerUrl && !isOnOnboardingPage && !isOnAuthPage) {
      return onboarding;
    }

    // If not logged in and not on auth pages, redirect to login
    if (!isLoggedIn && !isOnAuthPage && !isOnOnboardingPage) {
      return login;
    }

    // If logged in and on auth pages, redirect to recipes
    if (isLoggedIn && (isOnAuthPage || isOnOnboardingPage)) {
      return recipes;
    }

    return null; // No redirect needed
  }
}

// Navigation helper extensions
extension AppRouterExtension on BuildContext {
  void goToLogin() => go(AppRouter.login);
  void goToRegister() => go(AppRouter.register);
  void goToHome() => go(AppRouter.recipes);
  void goToRecipes() => go(AppRouter.recipes);
  void goToRecipeDetail(String slug) => go('/recipes/$slug');
  void goToRecipeCreate() => go('${AppRouter.recipes}/create');
  void goToRecipeEdit(String slug) => go('/recipes/$slug/edit');
  void goToMealPlans() => go(AppRouter.mealPlans);
  void goToShoppingLists() => go(AppRouter.shoppingLists);
  void goToProfile() => go(AppRouter.profile);
  void goToSettings() => go('${AppRouter.profile}/settings');
}