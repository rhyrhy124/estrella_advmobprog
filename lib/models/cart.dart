// This class represents one cart from the API.
class Cart {
  final int id;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  // This is the constructor for the Cart class.
  Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  // This converts the API JSON data into a Cart object.
  factory Cart.fromJson(
    Map<String, dynamic> json,
  ) {
    return Cart(
      id: json['id'] ?? 0,

      products:
          (json['products'] as List?)
                  ?.map(
                    (product) =>
                        CartProduct.fromJson(
                      product,
                    ),
                  )
                  .toList() ??
              [],

      total:
          (json['total'] as num?)
                  ?.toDouble() ??
              0.0,

      discountedTotal:
          (json['discountedTotal'] as num?)
                  ?.toDouble() ??
              0.0,

      userId: json['userId'] ?? 0,

      totalProducts:
          json['totalProducts'] ?? 0,

      totalQuantity:
          json['totalQuantity'] ?? 0,
    );
  }
}

// This class represents one product inside the cart.
class CartProduct {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedTotal;
  final String thumbnail;

  // This is the constructor for a cart product.
  CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.thumbnail,
  });

  // This converts the API JSON data into a CartProduct object.
  factory CartProduct.fromJson(
    Map<String, dynamic> json,
  ) {
    return CartProduct(
      id: json['id'] ?? 0,

      title: json['title'] ?? '',

      price:
          (json['price'] as num?)
                  ?.toDouble() ??
              0.0,

      quantity:
          json['quantity'] ?? 0,

      total:
          (json['total'] as num?)
                  ?.toDouble() ??
              0.0,

      discountPercentage:
          (json['discountPercentage'] as num?)
                  ?.toDouble() ??
              0.0,

      discountedTotal:
          (json['discountedTotal'] as num?)
                  ?.toDouble() ??
              0.0,

      thumbnail:
          json['thumbnail'] ?? '',
    );
  }
}