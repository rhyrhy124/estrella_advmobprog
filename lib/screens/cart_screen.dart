import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';

// This screen displays the products that are inside the cart.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This listens for changes made to the cart.
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        // This shows a message when there are no products in the cart.
        if (cart.items.isEmpty) {
          return const Center(
            child: Text(
              'Your cart is empty.',
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              // This displays all products in the cart.
              child: ListView.builder(
                padding:
                    EdgeInsets.all(16.r),
                itemCount:
                    cart.items.length,

                itemBuilder:
                    (context, index) {
                  // This gets the product at the current index.
                  final product =
                      cart.items[index];

                  return Container(
                    margin:
                        EdgeInsets.only(
                      bottom: 10.h,
                    ),

                    padding:
                        EdgeInsets.all(10.r),

                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        12.r,
                      ),

                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .surface,
                    ),

                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            8.r,
                          ),

                          // This displays the product image.
                          child:
                              Image.network(
                            product.thumbnail,
                            width: 75.w,
                            height: 75.h,
                            fit: BoxFit.cover,

                            // This shows an icon if the image cannot load.
                            errorBuilder:
                                (_, __, ___) {
                              return Container(
                                width: 75.w,
                                height: 75.h,
                                color: Colors
                                    .grey
                                    .shade200,
                                child:
                                    const Icon(
                                  Icons
                                      .image_outlined,
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(width: 12.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              // This displays the product name.
                              CustomText(
                                text:
                                    product.title,
                                fontSize:
                                    15.sp,
                                fontweight:
                                    FontWeight.bold,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),

                              // This displays the product category.
                              CustomText(
                                text:
                                    product.category,
                                fontSize:
                                    12.sp,
                              ),

                              // This displays the product price.
                              CustomText(
                                text:
                                    '₱${product.price.toStringAsFixed(0)}',
                                fontSize:
                                    14.sp,
                                fontweight:
                                    FontWeight.bold,
                              ),
                            ],
                          ),
                        ),

                        // This button is used for the checkout action.
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger
                                .of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Checkout selected.',
                                ),
                              ),
                            );
                          },

                          child:
                              const Text(
                            'Check Out',
                          ),
                        ),

                        // This button removes the product from the cart.
                        IconButton(
                          onPressed: () {
                            cart.removeFromCart(
                              product,
                            );
                          },

                          icon:
                              const Icon(
                            Icons
                                .delete_outline,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // This displays the total price of the cart.
            Padding(
              padding:
                  EdgeInsets.all(16.r),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  CustomText(
                    text: 'Total',
                    fontSize: 18.sp,
                    fontweight:
                        FontWeight.bold,
                  ),

                  CustomText(
                    text:
                        '₱${cart.total.toStringAsFixed(2)}',
                    fontSize: 18.sp,
                    fontweight:
                        FontWeight.bold,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}