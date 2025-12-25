// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:distimall/data/repositories/banner_repository.dart';
import 'package:distimall/data/repositories/category_repository.dart';
import 'package:distimall/data/repositories/product_repository.dart';
import 'package:distimall/data/services/api_client.dart';
import 'package:distimall/main.dart';
import 'package:distimall/providers/banner_provider.dart';
import 'package:distimall/providers/category_provider.dart';
import 'package:distimall/providers/product_provider.dart';

void main() {
  testWidgets('Home screen loads', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ApiClient>(create: (_) => ApiClient()),
          Provider<BannerRepository>(
            create: (context) => BannerRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
          Provider<CategoryRepository>(
            create: (context) => CategoryRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
          Provider<ProductRepository>(
            create: (context) => ProductRepository(
              apiClient: context.read<ApiClient>(),
            ),
          ),
          ChangeNotifierProvider<BannerProvider>(
            create: (context) => BannerProvider(
              repository: context.read<BannerRepository>(),
            ),
          ),
          ChangeNotifierProvider<CategoryProvider>(
            create: (context) => CategoryProvider(
              repository: context.read<CategoryRepository>(),
            ),
          ),
          ChangeNotifierProvider<ProductProvider>(
            create: (context) => ProductProvider(
              repository: context.read<ProductRepository>(),
            ),
          ),
        ],
        child: const DistyMallApp(),
      ),
    );

    // Verify key UI text is visible.
    expect(find.text('DISTY MALL'), findsOneWidget);
    expect(find.text('PRODUK UNGGULAN'), findsOneWidget);
  });
}
