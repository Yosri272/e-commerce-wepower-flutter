import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ready_ecommerce/config/theme.dart';
import 'package:ready_ecommerce/controllers/misc/misc_controller.dart';
import 'package:ready_ecommerce/models/eCommerce/dashboard/dashboard.dart';

class BannerWidget extends ConsumerStatefulWidget {
  final Dashboard dashboardData;
  const BannerWidget({super.key, required this.dashboardData});

  @override
  ConsumerState<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends ConsumerState<BannerWidget> {
  late PageController pageController;
  Timer? _timer;
  static const int maxPages = 100000; // Arbitrary large number
  static const int initialPage = maxPages ~/ 2; // Start from the middle

  @override
  void initState() {
    pageController = PageController(initialPage: initialPage);
    pageController.addListener(_pageListener);

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pageController.hasClients) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void _pageListener() {
    int? newPage = pageController.page?.round();
    if (newPage != ref.read(currentPageController)) {
      setState(() {
        ref.read(currentPageController.notifier).state =
            newPage! % widget.dashboardData.banners.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          height: 130.h,
          width: double.infinity,
          child: PageView.builder(
            controller: pageController,
            itemCount: maxPages,
            itemBuilder: (context, index) {
              int actualIndex = index % widget.dashboardData.banners.length;
              return ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  imageUrl: widget.dashboardData.banners[actualIndex].thumbnail,
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 16.h,
          left: 50.w,
          right: 50.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.dashboardData.banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: ref.read(currentPageController.notifier).state == index
                      ? colors(context).light
                      : colors(context).accentColor!.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30.sp),
                ),
                height: 8.h,
                width: 8.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
