import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// Enhancement 3:
// This screen displays the saved information
// of the currently logged-in user.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  final UserService _userService =
      UserService();

  late Future<User> _userFuture;

  late Future<List<Product>>
      _productsFuture;

  @override
  void initState() {
    super.initState();

    // Enhancement 3:
    // Load the saved user information.
    _userFuture =
        _userService.getUser();

    // Load products for recommendations.
    _productsFuture =
        ProductService()
            .getAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:
          EdgeInsets.all(16.r),

      child: Column(
        children: [
          // Enhancement 3:
          // FutureBuilder loads the saved user data.
          FutureBuilder<User>(
            future: _userFuture,

            builder:
                (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Padding(
                  padding:
                      EdgeInsets.all(30),
                  child:
                      CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                final raw =
                    snapshot.error
                        .toString();

                String friendly;

                if (raw.contains(
                  'SocketException',
                ) ||
                    raw.contains(
                  'Failed host lookup',
                ) ||
                    raw.contains(
                  'Network is unreachable',
                )) {
                  friendly =
                      'No internet connection. Please try again.';
                } else if (raw
                        .contains(
                  'TimeoutException',
                ) ||
                    raw.contains(
                  'timed out',
                )) {
                  friendly =
                      'The server is taking too long. Please try again.';
                } else {
                  friendly =
                      'Unable to load user information.';
                }

                return Padding(
                  padding: EdgeInsets.all(
                    24.r,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons
                            .person_off_outlined,
                        size: 56.sp,
                        color: Colors
                            .grey
                            .shade400,
                      ),
                      SizedBox(
                          height:
                              10.h),
                      CustomText(
                        text:
                            friendly,
                        fontSize:
                            14.sp,
                        textAlign:
                            TextAlign
                                .center,
                      ),
                    ],
                  ),
                );
              }

              final user =
                  snapshot.data;

              if (user == null) {
                return const Text(
                  'No user information found.',
                );
              }

              return Column(
                children: [
                  // User image.
                  CircleAvatar(
                    radius: 45.r,

                    backgroundImage:
                        user.image.isNotEmpty
                            ? NetworkImage(
                                user.image,
                              )
                            : null,

                    child:
                        user.image.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 50.sp,
                              )
                            : null,
                  ),

                  SizedBox(
                    height: 12.h,
                  ),

                  // First name.
                  CustomText(
                    text:
                        user.firstName,
                    fontSize: 24.sp,
                    fontweight:
                        FontWeight.bold,
                  ),

                  SizedBox(
                    height: 4.h,
                  ),

                  // Full name.
                  CustomText(
                    text:
                        '${user.firstName} ${user.lastName}',
                    fontSize: 17.sp,
                    fontweight:
                        FontWeight.w600,
                  ),

                  SizedBox(
                    height: 8.h,
                  ),

                  CustomText(
                    text:
                        'Welcome',
                    fontSize: 14.sp,
                  ),

                  SizedBox(
                    height: 20.h,
                  ),

                  // User information card.
                  Container(
                    width:
                        double.infinity,

                    padding:
                        EdgeInsets.all(16.r),

                    decoration:
                        BoxDecoration(
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .surface,

                      borderRadius:
                          BorderRadius
                              .circular(
                        12.r,
                      ),
                    ),

                    child: Column(
                      children: [
                        _userInfoRow(
                          Icons.email_outlined,
                          'Email',
                          user.email,
                        ),

                        _userInfoRow(
                          Icons.person_outline,
                          'Username',
                          user.username,
                        ),

                        _userInfoRow(
                          Icons.wc,
                          'Gender',
                          user.gender,
                        ),

                        _userInfoRow(
                          Icons.badge_outlined,
                          'User ID',
                          '${user.id}',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 25.h),

          Align(
            alignment:
                Alignment.centerLeft,

            child: CustomText(
              text: 'My Items',
              fontSize: 19.sp,
              fontweight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 10.h),

          Row(
            children: [
              _orderBox(
                Icons.account_balance_wallet,
                'To Pay',
              ),

              _orderBox(
                Icons.local_shipping,
                'To Ship',
              ),

              _orderBox(
                Icons.inventory,
                'To Receive',
              ),
            ],
          ),

          SizedBox(height: 25.h),

          Align(
            alignment:
                Alignment.centerLeft,

            child: CustomText(
              text:
                  'Recommended for you',
              fontSize: 19.sp,
              fontweight:
                  FontWeight.bold,
            ),
          ),

          SizedBox(height: 12.h),

          FutureBuilder<List<Product>>(
            future:
                _productsFuture,

            builder:
                (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Text(
                  'Unable to load recommendations.',
                );
              }

              final products =
                  snapshot.data
                          ?.take(2)
                          .toList() ??
                      [];

              return Row(
                children: products
                    .map(
                      (product) =>
                          Expanded(
                        child:
                            Container(
                          margin:
                              EdgeInsets.only(
                            right: 6.w,
                          ),

                          child:
                              Column(
                            children: [
                              Image.network(
                                product.thumbnail,
                                height:
                                    90.h,

                                errorBuilder:
                                    (_, __, ___) {
                                  return SizedBox(
                                    height:
                                        90.h,
                                    child:
                                        const Icon(
                                      Icons
                                          .image_outlined,
                                    ),
                                  );
                                },
                              ),

                              CustomText(
                                text:
                                    product.title,
                                fontSize:
                                    13.sp,
                                fontweight:
                                    FontWeight.bold,
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),

                              CustomText(
                                text:
                                    '₱${product.price.toStringAsFixed(0)}',
                                fontSize:
                                    12.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // Enhancement 3:
  // This creates one row for the saved user information.
  Widget _userInfoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 7.h,
      ),

      child: Row(
        children: [
          Icon(icon),

          SizedBox(width: 10.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  label,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // This creates one order status box.
  Widget _orderBox(
    IconData icon,
    String label,
  ) {
    return Expanded(
      child: Container(
        margin:
            EdgeInsets.symmetric(
          horizontal: 3.w,
        ),

        padding:
            EdgeInsets.symmetric(
          vertical: 15.h,
        ),

        decoration:
            BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surface,

          borderRadius:
              BorderRadius.circular(
            10.r,
          ),
        ),

        child: Column(
          children: [
            Icon(icon),

            SizedBox(height: 5.h),

            CustomText(
              text: label,
              fontSize: 11.sp,
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}