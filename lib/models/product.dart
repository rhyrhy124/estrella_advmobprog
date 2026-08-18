// This class stores all the information about a product.
class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final String brand;
  final String sku;
  final double weight;
  final ProductDimensions dimensions;
  final String warrantyInformation;
  final String shippingInformation;
  final String availabilityStatus;
  final List<ProductReview> reviews;
  final String returnPolicy;
  final int minimumOrderQuantity;
  final ProductMeta meta;
  final List<String> images;
  final String thumbnail;

  // This constructor is used to create a product object.
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.brand,
    required this.sku,
    required this.weight,
    required this.dimensions,
    required this.warrantyInformation,
    required this.shippingInformation,
    required this.availabilityStatus,
    required this.reviews,
    required this.returnPolicy,
    required this.minimumOrderQuantity,
    required this.meta,
    required this.images,
    required this.thumbnail,
  });

  // This factory converts JSON data into a Product object.
  factory Product.fromJson(
    Map<String, dynamic> json,
  ) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price:
          (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)
                  ?.toDouble() ??
              0.0,
      rating:
          (json['rating'] as num?)?.toDouble() ??
              0.0,
      stock: json['stock'] ?? 0,

      tags: List<String>.from(
        json['tags'] ?? [],
      ),

      brand: json['brand'] ?? '',
      sku: json['sku'] ?? '',

      weight:
          (json['weight'] as num?)?.toDouble() ??
              0.0,

      dimensions:
          ProductDimensions.fromJson(
        json['dimensions'] ?? {},
      ),

      warrantyInformation:
          json['warrantyInformation'] ?? '',

      shippingInformation:
          json['shippingInformation'] ?? '',

      availabilityStatus:
          json['availabilityStatus'] ?? '',

      // This converts each review from JSON into a ProductReview object.
      reviews:
          (json['reviews'] as List?)
                  ?.map(
                    (e) =>
                        ProductReview.fromJson(e),
                  )
                  .toList() ??
              [],

      returnPolicy:
          json['returnPolicy'] ?? '',

      minimumOrderQuantity:
          json['minimumOrderQuantity'] ?? 1,

      meta: ProductMeta.fromJson(
        json['meta'] ?? {},
      ),

      images: List<String>.from(
        json['images'] ?? [],
      ),

      thumbnail:
          json['thumbnail'] ?? '',
    );
  }
}

// This class stores the width, height, and depth of a product.
class ProductDimensions {
  final double width;
  final double height;
  final double depth;

  // This constructor creates the product dimensions.
  ProductDimensions({
    required this.width,
    required this.height,
    required this.depth,
  });

  // This converts JSON data into product dimensions.
  factory ProductDimensions.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductDimensions(
      width:
          (json['width'] as num?)?.toDouble() ??
              0.0,
      height:
          (json['height'] as num?)?.toDouble() ??
              0.0,
      depth:
          (json['depth'] as num?)?.toDouble() ??
              0.0,
    );
  }
}

// This class stores the review information of a product.
class ProductReview {
  final int rating;
  final String comment;
  final String date;
  final String reviewerName;
  final String reviewerEmail;

  // This constructor creates a product review.
  ProductReview({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  // This converts JSON data into a ProductReview object.
  factory ProductReview.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductReview(
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
      reviewerName:
          json['reviewerName'] ?? '',
      reviewerEmail:
          json['reviewerEmail'] ?? '',
    );
  }
}

// This class stores extra information about the product.
class ProductMeta {
  final String createdAt;
  final String updatedAt;
  final String barcode;
  final String qrCode;

  // This constructor creates the product metadata.
  ProductMeta({
    required this.createdAt,
    required this.updatedAt,
    required this.barcode,
    required this.qrCode,
  });

  // This converts JSON data into a ProductMeta object.
  factory ProductMeta.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProductMeta(
      createdAt:
          json['createdAt'] ?? '',
      updatedAt:
          json['updatedAt'] ?? '',
      barcode:
          json['barcode'] ?? '',
      qrCode:
          json['qrCode'] ?? '',
    );
  }
}