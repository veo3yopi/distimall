import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/models/category_item.dart';
import 'data/models/product_item.dart';
import 'data/repositories/banner_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/services/api_client.dart';
import 'providers/banner_provider.dart';
import 'providers/category_provider.dart';
import 'providers/product_provider.dart';

void main() {
  runApp(
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
}

class DistyMallApp extends StatelessWidget {
  const DistyMallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Disty Mall',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF5E8E6F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E8E6F),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ).apply(fontFamily: 'Georgia'),
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;
  String? _productsQuery;
  int? _categoryId;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onSearchSubmitted: (query) {
          setState(() {
            _productsQuery = query;
            _categoryId = null;
            _currentIndex = 1;
          });
        },
        onCategorySelected: (categoryId) {
          setState(() {
            _categoryId = categoryId;
            _productsQuery = null;
            _currentIndex = 1;
          });
        },
      ),
      ProductsPage(
        initialQuery: _productsQuery,
        categoryId: _categoryId,
      ),
      const _PlaceholderPage(title: 'Keranjang'),
      const _PlaceholderPage(title: 'Profil'),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF5A876A),
          border: Border(
            top: BorderSide(color: Color(0x55FFFFFF)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomNavItem(
              icon: Icons.home_filled,
              label: 'Home',
              isActive: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _BottomNavItem(
              icon: Icons.inventory_2_outlined,
              label: 'Produk',
              isActive: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _BottomNavItem(
              icon: Icons.shopping_bag_outlined,
              label: 'Keranjang',
              isActive: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _BottomNavItem(
              icon: Icons.person_outline,
              label: 'Profil',
              isActive: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onSearchSubmitted,
    required this.onCategorySelected,
  });

  final ValueChanged<String> onSearchSubmitted;
  final ValueChanged<int> onCategorySelected;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    final bannerProvider = context.read<BannerProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final productProvider = context.read<ProductProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      bannerProvider.loadBanners();
      categoryProvider.loadCategories();
      productProvider.loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          final query = value.trim();
                          if (query.isEmpty) {
                            return;
                          }
                          widget.onSearchSubmitted(query);
                          _searchController.clear();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Cari di Disty Mall..',
                          hintStyle: TextStyle(
                            color: Color(0xFF7A9D86),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF3F3F3F),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white, size: 26),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0x77FFFFFF),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    Column(
                      children: [
                        Icon(Icons.diamond_outlined,
                            color: Colors.white, size: 64),
                        const SizedBox(height: 10),
                        Text(
                          'DISTY MALL',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tampil Syar\'i Gaya Masa Kini',
                          style: TextStyle(
                            color: Color(0xFFE7F0EA),
                            fontSize: 12,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 110,
                      child: Consumer<BannerProvider>(
                        builder: (context, provider, _) {
                          final items = provider.banners;
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return _PromoCard(
                                imageUrl: item.imageUrl,
                                color: item.backgroundColor ??
                                    const Color(0xFF7DA283),
                              );
                            },
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemCount: items.length,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 88,
                      child: Consumer<CategoryProvider>(
                        builder: (context, provider, _) {
                          final items = provider.categories;
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return _CategoryItem(
                                label: item.name,
                                iconUrl: item.iconUrl,
                                onTap: () {
                                  final id = item.id;
                                  if (id != null) {
                                    widget.onCategorySelected(id);
                                  }
                                },
                              );
                            },
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 14),
                            itemCount: items.length,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'PRODUK UNGGULAN',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Consumer<ProductProvider>(
                        builder: (context, provider, _) {
                          final items = provider.featuredProducts;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return _ProductCard(
                                title: item.name,
                                price: _formatPrice(item.price),
                                oldPrice: null,
                                tag: item.category?.name ?? '',
                                imageUrl: item.thumbnailUrl,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          ProductDetailPage(product: item),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key, this.initialQuery, this.categoryId});

  final String? initialQuery;
  final int? categoryId;

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _selectedCategory = 'Semua';
  _SortOption _sortOption = _SortOption.newest;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final productProvider = context.read<ProductProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final query = widget.initialQuery?.trim() ?? '';
      if (widget.categoryId != null) {
        _selectedCategory = 'Semua';
        productProvider.filterByCategoryId(widget.categoryId);
      } else if (query.isNotEmpty) {
        productProvider.searchProducts(query);
      } else {
        productProvider.loadProducts();
      }
      categoryProvider.loadCategories();
    });
  }

  @override
  void didUpdateWidget(covariant ProductsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newQuery = widget.initialQuery?.trim() ?? '';
    final oldQuery = oldWidget.initialQuery?.trim() ?? '';
    final newCategoryId = widget.categoryId;
    final oldCategoryId = oldWidget.categoryId;
    if (newCategoryId != oldCategoryId || newQuery != oldQuery) {
      _searchController.text = newQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        if (newCategoryId != null) {
          if (_selectedCategory != 'Semua') {
            setState(() => _selectedCategory = 'Semua');
          }
          context.read<ProductProvider>().filterByCategoryId(newCategoryId);
        } else if (newQuery.isNotEmpty) {
          context.read<ProductProvider>().searchProducts(newQuery);
        } else {
          context.read<ProductProvider>().loadProducts();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'DAFTAR PRODUK',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ProductSearchBar(
                controller: _searchController,
                onSearch: (query) {
                  context.read<ProductProvider>().searchProducts(query);
                  if (query.trim().isNotEmpty) {
                    setState(() => _selectedCategory = 'Semua');
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _CategoryFilter(
                      value: _selectedCategory,
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  _SortFilter(
                    value: _sortOption,
                    onChanged: (value) {
                      setState(() => _sortOption = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, _) {
                  final items = _applyFilters(
                    provider.products,
                    selectedCategory: _selectedCategory,
                    sortOption: _sortOption,
                  );
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _ProductCard(
                        title: item.name,
                        price: _formatPrice(item.price),
                        oldPrice: null,
                        tag: item.category?.name ?? '',
                        imageUrl: item.thumbnailUrl,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ProductDetailPage(product: item),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;
  static const CategoryItem _emptyCategory = CategoryItem(name: '');

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        final categories = [
          'Semua',
          ...provider.categories.map((item) => item.name).where((name) {
            return name.trim().isNotEmpty;
          }),
        ];
        final selectedValue =
            categories.contains(value) ? value : categories.first;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: Color(0xFF3F3F3F)),
              style: const TextStyle(color: Color(0xFF3F3F3F), fontSize: 12),
              items: categories
                  .map((item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3F3F3F),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                  if (value != 'Semua') {
                    final category = provider.categories.firstWhere(
                      (item) => item.name == value,
                      orElse: () => _emptyCategory,
                    );
                    if (category.id != null) {
                      context
                          .read<ProductProvider>()
                          .filterByCategoryId(category.id);
                    }
                  } else {
                    context.read<ProductProvider>().loadProducts();
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _SortFilter extends StatelessWidget {
  const _SortFilter({required this.value, required this.onChanged});

  final _SortOption value;
  final ValueChanged<_SortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_SortOption>(
          value: value,
          icon: const Icon(Icons.swap_vert, color: Color(0xFF3F3F3F)),
          style: const TextStyle(color: Color(0xFF3F3F3F), fontSize: 12),
          items: const [
            DropdownMenuItem(
              value: _SortOption.newest,
              child: Text(
                'Terbaru',
                style: TextStyle(fontSize: 12, color: Color(0xFF3F3F3F)),
              ),
            ),
            DropdownMenuItem(
              value: _SortOption.nameAsc,
              child: Text(
                'Nama A-Z',
                style: TextStyle(fontSize: 12, color: Color(0xFF3F3F3F)),
              ),
            ),
            DropdownMenuItem(
              value: _SortOption.priceLow,
              child: Text(
                'Harga Terendah',
                style: TextStyle(fontSize: 12, color: Color(0xFF3F3F3F)),
              ),
            ),
            DropdownMenuItem(
              value: _SortOption.priceHigh,
              child: Text(
                'Harga Tertinggi',
                style: TextStyle(fontSize: 12, color: Color(0xFF3F3F3F)),
              ),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

class _ProductSearchBar extends StatefulWidget {
  const _ProductSearchBar({
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  @override
  State<_ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<_ProductSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: widget.controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => widget.onSearch(value),
        decoration: InputDecoration(
          hintText: 'Cari produk..',
          hintStyle: const TextStyle(
            color: Color(0xFF7A9D86),
            fontSize: 14,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 6),
            child: Icon(Icons.search, color: Color(0xFF3F3F3F), size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF7A9D86)),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(
          color: Color(0xFF3F3F3F),
          fontSize: 14,
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final ProductItem product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final Future<ProductItem> _detailFuture;

  @override
  void initState() {
    super.initState();
    final repository = context.read<ProductRepository>();
    _detailFuture = widget.product.id != null
        ? repository.fetchProductDetail(widget.product.id!)
        : Future.value(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<ProductItem>(
          future: _detailFuture,
          builder: (context, snapshot) {
            final detail = snapshot.data ?? widget.product;
            final images = _resolveImages(detail);
            return Column(
              children: [
                _DetailAppBar(title: 'Product Detail Page'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _DetailImageGallery(images: images),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                detail.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Color(0xFFF2C94C), size: 16),
                                const Icon(Icons.star,
                                    color: Color(0xFFF2C94C), size: 16),
                                const Icon(Icons.star,
                                    color: Color(0xFFF2C94C), size: 16),
                                const Icon(Icons.star,
                                    color: Color(0xFFF2C94C), size: 16),
                                const Icon(Icons.star_half,
                                    color: Color(0xFFF2C94C), size: 16),
                                const SizedBox(width: 6),
                                const Text(
                                  '4.9',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          detail.category?.name ?? 'Disty',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE7F0EA),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatPrice(detail.price),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if ((detail.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _stripHtml(detail.description ?? ''),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE7F0EA),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        _HighlightsSection(highlights: detail.highlights),
                        const SizedBox(height: 16),
                        _ReviewSection(
                          title: 'Ulasan',
                          review:
                              'Alhamdulillah, suka banget! Kainnya adem dan jahitan rapi.',
                        ),
                      ],
                    ),
                  ),
                ),
                _DetailBottomBar(
                  onAddToCart: () {},
                  onBuy: () {},
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailAppBar extends StatelessWidget {
  const _DetailAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F0EA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFD1C6)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: const Color(0xFF5E8E6F),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF3F3F3F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.shopping_cart_outlined, color: Color(0xFF5E8E6F)),
          const SizedBox(width: 12),
          const Icon(Icons.chat_bubble_outline, color: Color(0xFF5E8E6F)),
        ],
      ),
    );
  }
}

class _DetailImageGallery extends StatefulWidget {
  const _DetailImageGallery({required this.images});

  final List<String> images;

  @override
  State<_DetailImageGallery> createState() => _DetailImageGalleryState();
}

class _DetailImageGalleryState extends State<_DetailImageGallery> {
  late final PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return Column(
      children: [
        Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1EEE9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: images.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _showFullImage(context, images[_currentIndex]);
                    },
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final isActive = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection({required this.highlights});

  final List<String>? highlights;

  @override
  Widget build(BuildContext context) {
    final items = highlights ?? [];
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Highlights',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '•',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Color(0xFFE7F0EA),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.title, required this.review});

  final String title;
  final String review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFEFE6DD),
                child: Icon(Icons.person, color: Color(0xFF9FA3A0)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.star,
                            color: Color(0xFFF2C94C), size: 12),
                        Icon(Icons.star,
                            color: Color(0xFFF2C94C), size: 12),
                        Icon(Icons.star,
                            color: Color(0xFFF2C94C), size: 12),
                        Icon(Icons.star,
                            color: Color(0xFFF2C94C), size: 12),
                        Icon(Icons.star_half,
                            color: Color(0xFFF2C94C), size: 12),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF3F3F3F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailBottomBar extends StatelessWidget {
  const _DetailBottomBar({required this.onAddToCart, required this.onBuy});

  final VoidCallback onAddToCart;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        color: const Color(0xFF5A876A),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onAddToCart,
                child: const Text(
                  'Tambahkan ke Keranjang',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5E8E6F),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onBuy,
                child: const Text(
                  'Beli',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(double? price) {
  if (price == null) {
    return 'Rp0';
  }
  final rounded = price.round();
  final digits = rounded.toString();
  final buffer = StringBuffer('Rp');
  for (var i = 0; i < digits.length; i++) {
    final indexFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buffer.write('.');
    }
  }
  return buffer.toString();
}

List<String> _resolveImages(ProductItem item) {
  final images = <String>[];
  if (item.images != null) {
    images.addAll(item.images!.where((value) => value.isNotEmpty));
  }
  if (images.isEmpty && item.thumbnailUrl != null) {
    images.add(item.thumbnailUrl!);
  }
  return images;
}

String _stripHtml(String input) {
  return input.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}

void _showFullImage(BuildContext context, String imageUrl) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.9),
    builder: (context) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.color,
    this.imageUrl,
  });

  final Color color;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    this.iconUrl,
    this.onTap,
  });

  final String label;
  final String? iconUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasIcon = iconUrl != null && iconUrl!.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: hasIcon
                ? ClipOval(
                    child: Image.network(
                      iconUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.category_outlined,
                          color: Color(0xFF5E8E6F),
                          size: 26,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.category_outlined,
                    color: Color(0xFF5E8E6F),
                    size: 26,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.tag,
    this.imageUrl,
    this.onTap,
  });

  final String title;
  final String price;
  final String? oldPrice;
  final String tag;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F0EC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                if (tag.isNotEmpty)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7FA88B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF3D3D3D),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildStar(),
              _buildStar(),
              _buildStar(),
              _buildStar(),
              _buildStar(active: false),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFF3D3D3D),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              if (oldPrice != null) ...[
                const SizedBox(width: 6),
                Text(
                  oldPrice!,
                  style: const TextStyle(
                    color: Color(0xFF9FA3A0),
                    fontSize: 10,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStar({bool active = true}) {
    return Icon(
      Icons.star,
      size: 12,
      color: active ? const Color(0xFFF2C94C) : const Color(0xFFE0E0E0),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : Colors.white70;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

enum _SortOption { newest, nameAsc, priceLow, priceHigh }

List<ProductItem> _applyFilters(
  List<ProductItem> items, {
  required String selectedCategory,
  required _SortOption sortOption,
}) {
  var filtered = items;
  if (selectedCategory != 'Semua') {
    filtered = filtered
        .where((item) => item.category?.name == selectedCategory)
        .toList();
  }

  final sorted = [...filtered];
  switch (sortOption) {
    case _SortOption.nameAsc:
      sorted.sort((a, b) => a.name.compareTo(b.name));
      break;
    case _SortOption.priceLow:
      sorted.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
      break;
    case _SortOption.priceHigh:
      sorted.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
      break;
    case _SortOption.newest:
      sorted.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
      break;
  }
  return sorted;
}
