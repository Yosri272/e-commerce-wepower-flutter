import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ready_ecommerce/components/ecommerce/app_logo.dart';
import 'package:ready_ecommerce/components/ecommerce/custom_search_field.dart';
import 'package:ready_ecommerce/config/app_color.dart';
import 'package:ready_ecommerce/config/app_constants.dart';
import 'package:ready_ecommerce/config/app_text_style.dart';
import 'package:ready_ecommerce/config/theme.dart';
import 'package:ready_ecommerce/controllers/common/master_controller.dart';
import 'package:ready_ecommerce/controllers/eCommerce/category/category_controller.dart';
import 'package:ready_ecommerce/controllers/eCommerce/dashboard/dashboard_controller.dart';
import 'package:ready_ecommerce/controllers/misc/misc_controller.dart';
import 'package:ready_ecommerce/gen/assets.gen.dart';
import 'package:ready_ecommerce/generated/l10n.dart';
import 'package:ready_ecommerce/models/eCommerce/category/category.dart';
import 'package:ready_ecommerce/models/eCommerce/dashboard/dashboard.dart';
import 'package:ready_ecommerce/models/eCommerce/order/order_model.dart';
import 'package:ready_ecommerce/models/eCommerce/product/product.dart'
    as product;
import 'package:ready_ecommerce/routes.dart';
import 'package:ready_ecommerce/services/common/hive_service_provider.dart';
import 'package:ready_ecommerce/utils/context_less_navigation.dart';
import 'package:ready_ecommerce/utils/global_function.dart';
import 'package:ready_ecommerce/views/eCommerce/categories/components/sub_categories_bottom_sheet.dart';
import 'package:ready_ecommerce/views/eCommerce/checkout/components/address_modal_bottom_sheet.dart';
import 'package:ready_ecommerce/views/eCommerce/home/components/banner_widget.dart';
import 'package:ready_ecommerce/views/eCommerce/home/components/category_card.dart';
import 'package:ready_ecommerce/views/eCommerce/home/components/deal_of_day_widget.dart';
import 'package:ready_ecommerce/views/eCommerce/home/components/popular_product_card.dart';
import 'package:ready_ecommerce/views/eCommerce/home/components/product_card.dart';
import 'package:ready_ecommerce/views/eCommerce/home/components/shop_card.dart';
import 'package:ready_ecommerce/views/eCommerce/products/layouts/product_details_layout.dart';

import '../../../../models/eCommerce/shop/shop.dart';

class EcommerceHomeViewLayout extends ConsumerStatefulWidget {
  const EcommerceHomeViewLayout({Key? key}) : super(key: key);

  @override
  ConsumerState<EcommerceHomeViewLayout> createState() =>
      _EcommerceHomeViewLayoutState();
}

class _EcommerceHomeViewLayoutState
    extends ConsumerState<EcommerceHomeViewLayout> {
  final TextEditingController productSearchController = TextEditingController();
  PageController pageController = PageController();
  final ScrollController scrollController = ScrollController();
  bool isHeaderVisible = true;

  final List<SubCategory> subCategories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.refresh(currentPageController.notifier).state;
    });
    pageController.addListener(_pageListener);
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    if (mounted) scrollController.dispose();
    pageController.dispose();
    super.dispose();
  }

  void _pageListener() {
    int? newPage = pageController.page?.round();
    if (newPage != ref.read(currentPageController)) {
      setState(() {
        ref.read(currentPageController.notifier).state = newPage!;
      });
    }
  }

  void _scrollListener() {
    if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        isHeaderVisible) {
      setState(() => isHeaderVisible = false);
    } else if (scrollController.position.userScrollDirection ==
            ScrollDirection.forward &&
        !isHeaderVisible) {
      if (scrollController.position.pixels ==
          scrollController.position.minScrollExtent) {
        setState(() => isHeaderVisible = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWrapperWidget(
      isLoading: ref.watch(subCategoryControllerProvider),
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildHeaderWidget(context),
            Flexible(
              flex: 5,
              child: ref.watch(dashboardControllerProvider).when(
                    data: (dashboardData) => RefreshIndicator(
                      onRefresh: () async {
                        ref.refresh(dashboardControllerProvider).value;
                      },
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: AnimationLimiter(
                          child: Column(
                            children: AnimationConfiguration.toStaggeredList(
                              duration: const Duration(milliseconds: 375),
                              childAnimationBuilder: (widget) => SlideAnimation(
                                verticalOffset: 50.h,
                                child: FadeInAnimation(child: widget),
                              ),
                              children: [
                                Gap(20.h),
                                // _buildBannerWidget(context, dashboardData),
                                BannerWidget(dashboardData: dashboardData),
                                Gap(20.h),
                                _buildCategoriesWidget(
                                    context, dashboardData.categories),
                                Gap(20.h),
                                DealOfDayWidget(
                                    targetDate:
                                        DateTime.parse('2023-12-30T23:00:00')),
                                _buildPopularProductWidget(
                                    context, dashboardData.popularProducts),
                                if (ref
                                    .read(masterControllerProvider.notifier)
                                    .materModel
                                    .data
                                    .isMultiVendor) ...[
                                  _buildShopsWidget(
                                      context, dashboardData.shops),
                                  Divider(
                                      color: colors(context).accentColor,
                                      thickness: 2),
                                ],
                                Gap(10.h),
                                _buildBeautyProductWidget(
                                    products:
                                        dashboardData.justForYou.products),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    error: (error, stackTrace) => Center(
                      child: Text(error.toString(),
                          style: AppTextStyle(context).subTitle),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeautyProductWidget({required List<product.Product> products}) {
    return Stack(
      children: [
        GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h)
              .copyWith(top: 34.h, bottom: 80.h),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _calculateCrossAxisCount(context),
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.66,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => ProductCard(
            product: products[index],
            onTap: () => context.nav.pushNamed(
              Routes.getProductDetailsRouteName(AppConstants.appServiceName),
              arguments: products[index].id,
            ),
          ),
        ),
        Positioned(
            left: 20.w,
            child: Text(S.of(context).justForYou,
                style: AppTextStyle(context).subTitle)),
        Positioned(
          bottom: 20.h,
          left: 20.w,
          right: 20.w,
          child: _buildViewMoreButton(context, 'Just For You', 'just_for_you'),
        ),
      ],
    );
  }

  Widget _buildCategoriesWidget(
      BuildContext context, List<Category> categories) {
    return Column(
      children: [
        _buildSectionHeader(context, S.of(context).categories,
            Routes.getCategoriesViewRouteName(AppConstants.appServiceName)),
        Gap(10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Gap(10.w),
              ...categories.map(
                (category) => CategoryCard(
                  category: category,
                  onTap: () {
                    if (category.subCategories.isNotEmpty) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SubCategoriesBottomSheet(
                          category: category,
                        ),
                      );
                    } else {
                      GlobalFunction.navigatorKey.currentContext!.nav.pushNamed(
                        Routes.getProductsViewRouteName(
                          AppConstants.appServiceName,
                        ),
                        arguments: [
                          category.id,
                          category.name,
                          null,
                          null,
                          null,
                          category.subCategories,
                        ],
                      );
                    }
                  },
                ),
              ),
              Gap(10.w),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShopsWidget(BuildContext context, List<Shop> shops) {
    return Column(
      children: [
        _buildSectionHeader(context, S.of(context).shops,
            Routes.getShopsViewRouteName(AppConstants.appServiceName)),
        SizedBox(
          height: MediaQuery.of(context).size.height / 8.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            scrollDirection: Axis.horizontal,
            itemCount: shops.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: ShopCardCircle(
                callback: () => context.nav.pushNamed(
                  Routes.getShopViewRouteName(AppConstants.appServiceName),
                  arguments: shops[index].id,
                ),
                shop: shops[index],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularProductWidget(
      BuildContext context, List<product.Product> products) {
    return Container(
      decoration: BoxDecoration(color: colors(context).accentColor),
      child: Column(
        children: [
          _buildSectionHeader(context, S.of(context).popularProducts,
              Routes.getProductsViewRouteName(AppConstants.appServiceName),
              arguments: [
                null,
                'Popular',
                'popular',
                null,
                null,
                subCategories
              ]),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2.8,
            child: ListView.builder(
              padding: EdgeInsets.only(left: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) => PopularProductCard(
                product: products[index],
                onTap: () => context.nav.pushNamed(
                  Routes.getProductDetailsRouteName(
                      AppConstants.appServiceName),
                  arguments: products[index].id,
                ),
              ),
            ),
          ),
          Gap(20.h),
        ],
      ),
    );
  }

  Widget _buildBannerWidget(BuildContext context, Dashboard dashboardData) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          height: 130.h,
          width: double.infinity,
          child: PageView.builder(
            controller: pageController,
            itemCount: dashboardData.banners.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: dashboardData.banners[index].thumbnail,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16.h,
          left: 50.w,
          right: 50.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              dashboardData.banners.length,
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

  Widget _buildHeaderWidget(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h)
          .copyWith(top: !isHeaderVisible ? 20.h : 50.h),
      decoration: _buildContainerDecoration(context),
      child: ValueListenableBuilder<Box>(
        valueListenable: Hive.box(AppConstants.userBox).listenable(),
        builder: (context, userBox, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (isHeaderVisible)
                ref.read(hiveServiceProvider).userIsLoggedIn()
                    ? GestureDetector(
                        onTap: () => showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              topRight: Radius.circular(16.r),
                            ),
                          ),
                          barrierColor:
                              colors(context).accentColor!.withOpacity(0.8),
                          context: context,
                          builder: (_) => const AddressModalBottomSheet(),
                        ),
                        child: _buildHeaderRow(context),
                      )
                    : const AppLogo(isAnimation: true, centerAlign: false),
              Gap(10.h),
              GestureDetector(
                onTap: () => context.nav.pushNamed(
                  Routes.getProductsViewRouteName(AppConstants.appServiceName),
                  arguments: [
                    null,
                    'All Product',
                    null,
                    null,
                    null,
                    subCategories,
                  ],
                ),
                child: AbsorbPointer(
                  absorbing: true,
                  child: CustomSearchField(
                    name: 'product_search',
                    hintText: S.of(context).searchProduct,
                    textInputType: TextInputType.text,
                    controller: productSearchController,
                    widget: Container(
                      margin: EdgeInsets.all(10.sp),
                      child: SvgPicture.asset(Assets.svg.searchHome),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String route,
      {List<dynamic>? arguments}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.h).copyWith(right: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyle(context).buttonText),
          TextButton(
            onPressed: () => context.nav.pushNamed(route, arguments: arguments),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.of(context).viewMore,
                    style: AppTextStyle(context)
                        .bodyText
                        .copyWith(color: colors(context).primaryColor)),
                Gap(3.w),
                SvgPicture.asset(
                  Assets.svg.arrowRight,
                  colorFilter: ColorFilter.mode(
                      colors(context).primaryColor!, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMoreButton(
      BuildContext context, String title, String argument) {
    return OutlinedButton(
      onPressed: () => context.nav.pushNamed(
        Routes.getProductsViewRouteName(AppConstants.appServiceName),
        arguments: [null, title, argument, null, null, subCategories],
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: GlobalFunction.getBackgroundColor(context: context) !=
                colors(context).dark
            ? EcommerceAppColor.blueChalk
            : colors(context).accentColor,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        side: BorderSide(color: EcommerceAppColor.primary, width: 1),
        minimumSize: Size(MediaQuery.of(context).size.width, 45.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(S.of(context).viewMore,
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: colors(context).primaryColor,
                  fontWeight: FontWeight.w600)),
          Gap(3.w),
          SvgPicture.asset(
            Assets.svg.arrowRight,
            colorFilter: ColorFilter.mode(
                colors(context).primaryColor!, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }

  Decoration _buildContainerDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
      boxShadow: [
        BoxShadow(
          color: colors(context).accentColor ?? EcommerceAppColor.offWhite,
          blurRadius: 20,
          spreadRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLeftRow(context),
        Icon(Icons.expand_more, color: colors(context).hintTextColor),
      ],
    );
  }

  Widget _buildLeftRow(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          const AppLogo(withAppName: false, isAnimation: true),
          Gap(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).deliverTo,
                    style: AppTextStyle(context)
                        .bodyTextSmall
                        .copyWith(fontWeight: FontWeight.w700)),
                ValueListenableBuilder(
                  valueListenable: Hive.box(AppConstants.userBox).listenable(),
                  builder: (context, box, _) {
                    final addressData = box.get(AppConstants.defaultAddress);
                    return Text(
                      _defaultAddress(context, addressData),
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle(context)
                          .bodyText
                          .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _defaultAddress(BuildContext context, dynamic data) {
    if (data != null) {
      Map<String, dynamic> addressStringKeys = data.cast<String, dynamic>();
      Address address = Address.fromJson(addressStringKeys);
      return GlobalFunction.formatDeliveryAddress(
          context: context, address: address);
    }
    return '';
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 600 ? 3 : 2;
  }
}
