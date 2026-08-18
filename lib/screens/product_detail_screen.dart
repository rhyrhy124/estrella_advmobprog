import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';

// This class shows the details of the selected product.
class ProductDetailScreen
    extends StatelessWidget {
  // This stores the product selected by the user.
  final Product product;

  // This is the constructor for the product detail screen.
  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  // This builds the product detail screen.
  Widget build(BuildContext context) {
    return Scaffold(
      // This creates the top bar of the screen.
      appBar: AppBar(
        title:
            const Text('Product Details'),
      ),

      // This allows the user to scroll the product details.
      body: SingleChildScrollView(
        padding:
            EdgeInsets.all(16.r),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // This displays the product image.
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(16.r),

              child: Image.network(
                product.thumbnail,
                width: double.infinity,
                height: 280.h,
                fit: BoxFit.cover,

                // This shows an icon if the image cannot be loaded.
                errorBuilder:
                    (_, __, ___) {
                  return Container(
                    width: double.infinity,
                    height: 280.h,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_outlined,
                      size: 60,
                    ),
                  );
                },

                // This shows a loading icon while the image is loading.
                loadingBuilder:
                    (
                      context,
                      child,
                      loadingProgress,
                    ) {
                  if (loadingProgress ==
                      null) {
                    return child;
                  }

                  return SizedBox(
                    height: 280.h,
                    child: const Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),

            // This adds space below the product image.
            SizedBox(height: 20.h),

            // This displays the product name.
            CustomText(
              text: product.title,
              fontSize: 24.sp,
              fontweight:
                  FontWeight.bold,
            ),

            // This adds space below the product name.
            SizedBox(height: 8.h),

            // This displays the product price.
            CustomText(
              text:
                  '₱${product.price.toStringAsFixed(2)}',
              fontSize: 22.sp,
              fontweight:
                  FontWeight.bold,
            ),

            // This adds space before the rating.
            SizedBox(height: 15.h),

            // This displays the product rating.
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),

                SizedBox(width: 5.w),

                CustomText(
                  text:
                      '${product.rating} / 5',
                  fontSize: 14.sp,
                ),
              ],
            ),

            // This adds space before the description.
            SizedBox(height: 20.h),

            // This displays the description title.
            CustomText(
              text: 'Description',
              fontSize: 18.sp,
              fontweight:
                  FontWeight.bold,
            ),

            // This adds space below the description title.
            SizedBox(height: 8.h),

            // This displays the product description.
            CustomText(
              text:
                  product.description,
              fontSize: 14.sp,
            ),

            // This adds space before the product information.
            SizedBox(height: 20.h),

            // This displays the product category.
            _InfoRow(
              label: 'Category',
              value: product.category,
            ),

            // This displays the product brand.
            _InfoRow(
              label: 'Brand',
              value: product.brand,
            ),

            // This displays the available stock.
            _InfoRow(
              label: 'Stock',
              value:
                  '${product.stock}',
            ),

            // This displays the product status.
            _InfoRow(
              label: 'Status',
              value:
                  product.availabilityStatus,
            ),

            // This displays the shipping information.
            _InfoRow(
              label: 'Shipping',
              value:
                  product.shippingInformation,
            ),

            // This displays the return policy.
            _InfoRow(
              label: 'Return Policy',
              value:
                  product.returnPolicy,
            ),

            // This adds space before the button.
            SizedBox(height: 25.h),

            // This creates the Add to Cart button.
            SizedBox(
              width: double.infinity,
              height: 52.h,

              child:
                  ElevatedButton.icon(
                // This adds the product to the cart when clicked.
                onPressed: () {
                  Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).addToCart(product);

                  // This shows a message after adding the product.
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${product.title} added to cart!',
                      ),
                    ),
                  );
                },

                // This shows the shopping cart icon.
                icon: const Icon(
                  Icons.shopping_cart,
                ),

                // This shows the button text.
                label: const Text(
                  'Add to Cart',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This class displays a label and its value.
class _InfoRow
    extends StatelessWidget {
  // This stores the name of the information.
  final String label;

  // This stores the value of the information.
  final String value;

  // This is the constructor for the information row.
  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  // This builds one information row.
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 6.h,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // This gives space for the label.
          SizedBox(
            width: 105.w,

            child: Text(
              label,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          // This displays the value of the information.
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}