import 'product_item.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
  });

  final ProductItem product;
  final int quantity;

  double get subtotal => (product.price ?? 0) * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}
