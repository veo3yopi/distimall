import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/banner_repository.dart';
import 'data/services/api_client.dart';
import 'providers/banner_provider.dart';

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
        ChangeNotifierProvider<BannerProvider>(
          create: (context) => BannerProvider(
            repository: context.read<BannerRepository>(),
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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _categories = [
    {'label': 'Makanan', 'icon': Icons.apple},
    {'label': 'Pakaian', 'icon': Icons.checkroom},
    {'label': 'Kesehatan', 'icon': Icons.favorite},
    {'label': 'Kecantikan', 'icon': Icons.brush},
    {'label': 'Craft', 'icon': Icons.palette},
    {'label': 'Laundry', 'icon': Icons.local_laundry_service},
    {'label': 'Cellular', 'icon': Icons.phone_android},
  ];

  static const _featuredProducts = [
    {
      'title': 'Maxi Dress Rayon',
      'price': 'Rp2.500',
      'oldPrice': null,
      'tag': 'Paket Katering Sehat',
      'icon': Icons.person,
    },
    {
      'title': 'Tas Rajut',
      'price': 'Rp125.000',
      'oldPrice': 'Rp175.000',
      'tag': 'Handmade',
      'icon': Icons.shopping_bag,
    },
    {
      'title': 'Herbal Syrup',
      'price': 'Rp45.000',
      'oldPrice': null,
      'tag': 'Kesehatan',
      'icon': Icons.local_drink,
    },
    {
      'title': 'Tas Rajut Mini',
      'price': 'Rp95.000',
      'oldPrice': 'Rp120.000',
      'tag': 'Limited',
      'icon': Icons.shopping_bag_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BannerProvider>().loadBanners());
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Cari di Disty Mall..',
                        style: TextStyle(
                          color: Color(0xFF7A9D86),
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
                                title: item.title,
                                subtitle: item.subtitle,
                                imageUrl: item.imageUrl,
                                color: item.backgroundColor ??
                                    const Color(0xFF7DA283),
                                icon: Icons.local_offer,
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
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final item = _categories[index];
                          return _CategoryItem(
                            label: item['label'] as String,
                            icon: item['icon'] as IconData,
                          );
                        },
                        separatorBuilder: (_, _) => const SizedBox(width: 14),
                        itemCount: _categories.length,
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
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: _featuredProducts.length,
                        itemBuilder: (context, index) {
                          final item = _featuredProducts[index];
                          return _ProductCard(
                            title: item['title'] as String,
                            price: item['price'] as String,
                            oldPrice: item['oldPrice'] as String?,
                            tag: item['tag'] as String,
                            icon: item['icon'] as IconData,
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
          children: const [
            _BottomNavItem(icon: Icons.home_filled, label: 'Home'),
            _BottomNavItem(icon: Icons.grid_view, label: 'Kategori'),
            _BottomNavItem(icon: Icons.shopping_bag_outlined, label: 'Keranjang'),
            _BottomNavItem(icon: Icons.person_outline, label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
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
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          if (hasImage)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              Flexible(
                child: Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.1,
                  ),
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF5E8E6F), size: 26),
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
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.tag,
    required this.icon,
  });

  final String title;
  final String price;
  final String? oldPrice;
  final String tag;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FA88B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Icon(icon, size: 48, color: const Color(0xFFBFA999)),
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
  const _BottomNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }
}
